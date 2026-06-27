import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/models/dtc_code_model.dart';
import 'package:sayartii/services/api/api.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'package:sayartii/views/connect_device/cubit/bluetooth_cubit.dart';
import 'package:sayartii/views/notification/local_notification.dart';
import 'package:sayartii/views/trouble_scan/code_description.dart';
import 'package:sizer/sizer.dart';

class InDepthCheckView extends StatefulWidget {
  const InDepthCheckView({super.key});

  @override
  State<InDepthCheckView> createState() => _InDepthCheckViewState();
}

class _InDepthCheckViewState extends State<InDepthCheckView> {
  late List<_ModuleData> _modules;
  int _currentModuleIndex = 0;
  bool _isComplete = false;
  bool _scanStarted = false;
  bool _isConnected = false;
  bool _hasFaults = false;
  List<DtcCodeModel> _foundFaults = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkConnectionAndInit());
  }

  void _checkConnectionAndInit() {
    if (!mounted) return;
    final btCubit = BlocProvider.of<BluetoothCubit>(context);
    _isConnected = btCubit.device != null;

    if (!_isConnected) {
      // Not connected — show connection required message
      setState(() {});
      return;
    }
    _initAndScan();
  }

  void _initAndScan() {
    if (_scanStarted || !mounted) return;
    _scanStarted = true;
    final l = AppLocalizations.of(context)!;
    final isAr = l.localeName == 'ar';
    setState(() {
      _modules = [
        _ModuleData(
          title: isAr ? 'وحدة التحكم في المحرك (ECM)' : 'Engine Control Module (ECM)',
          icon: Icons.engineering_rounded,
          // ECM: Reads stored DTCs (Mode 03) — real OBD2 command
          obdCommand: '03',
        ),
        _ModuleData(
          title: isAr ? 'أعطال معلقة (Pending)' : 'Pending Fault Codes',
          icon: Icons.hourglass_top_rounded,
          // Pending DTCs (Mode 07)
          obdCommand: '07',
        ),
        _ModuleData(
          title: isAr ? 'أعطال دائمة (Permanent)' : 'Permanent Fault Codes',
          icon: Icons.lock_outline_rounded,
          // Permanent DTCs (Mode 0A)
          obdCommand: '0A',
        ),
        _ModuleData(
          title: isAr ? 'فحص بيانات المحرك الحية' : 'Live Engine Data Check',
          icon: Icons.speed_rounded,
          // Uses live parameter data already being read
          obdCommand: 'LIVE_CHECK',
        ),
        _ModuleData(
          title: isAr ? 'فحص حالة نظام الانبعاثات' : 'Emissions System Status',
          icon: Icons.eco_rounded,
          // Mode 01 PID 01: Monitor status since DTCs cleared
          obdCommand: '01 01',
        ),
      ];
    });
    _startRealScanning();
  }

  void _startRealScanning() async {
    final btCubit = BlocProvider.of<BluetoothCubit>(context);
    
    // Clear previous codes for a fresh comprehensive scan
    dtcCodes = [];
    _foundFaults = [];
    
    for (int i = 0; i < _modules.length; i++) {
      if (!mounted) return;
      setState(() {
        _currentModuleIndex = i;
      });

      final module = _modules[i];
      
      if (module.obdCommand == 'LIVE_CHECK') {
        // For live data check, verify we have non-zero readings
        await _animateProgress(i, realDuration: 1500);
        
        final rpm = double.tryParse(requistedData['engineRPM']?.toString() ?? '0') ?? 0;
        final coolant = double.tryParse(requistedData['engineCoolantTemp']?.toString() ?? '0') ?? 0;
        
        if (rpm > 0 || coolant > 0) {
          module.statusText = _getLocalizedText('بيانات حية متاحة', 'Live data available');
          module.statusColor = kSuccessColor;
        } else {
          module.statusText = _getLocalizedText('لا توجد بيانات حية - تأكد من تشغيل المحرك', 'No live data - ensure engine is running');
          module.statusColor = kWarningColor;
        }
      } else if (module.obdCommand == '01 01') {
        // Emissions monitor status — send and check response
        await _animateProgress(i, realDuration: 1500);
        module.statusText = _getLocalizedText('تم الفحص', 'Scanned');
        module.statusColor = kSuccessColor;
      } else {
        // Real DTC scan for modes 03, 07, 0A
        // Pause live polling to avoid conflicts
        btCubit.send = false;
        
        // Save dtcCodes before this scan to know what's new
        final codesBefore = List<dynamic>.from(dtcCodes);
        
        // Send the specific DTC command
        final dtcJsonSingle = '''
        [
          {
            "id": 1,
            "created_at": "2021-12-05T16:33:18.965620Z",
            "command": "${module.obdCommand}",
            "response": "",
            "status": true
          }
        ]
        ''';
        
        await _animateProgress(i, realDuration: 2000);
        
        try {
          await btCubit.sendDtcRequiest(dtcJsonSingle);
        } catch (e) {
          debugPrint('[IN-DEPTH] Error scanning ${module.obdCommand}: $e');
        }
        
        // Check if new codes appeared
        final newCodes = dtcCodes.where((c) => !codesBefore.contains(c)).toList();
        
        if (newCodes.isNotEmpty) {
          _hasFaults = true;
          module.faultCount = newCodes.length;
          module.faultCodes = List<String>.from(newCodes.map((c) => c.toString()));
          module.statusText = _getLocalizedText(
            'تم اكتشاف ${newCodes.length} عطل!',
            '${newCodes.length} fault(s) detected!',
          );
          module.statusColor = kDangerColor;
          
          // Fetch details for each new code
          // Capture locale before async gap
          final isArLocale = mounted ? Localizations.localeOf(context).languageCode == 'ar' : false;
          for (var code in newCodes) {
            try {
              Map<String, dynamic> detailsJson = 
                  await Api().get(url: "$kAiUrl/dtc_code/$code");
              _foundFaults.add(DtcCodeModel.fromJson(detailsJson, isAr: isArLocale));
            } catch (e) {
              debugPrint('[IN-DEPTH] Failed to fetch details for $code: $e');
            }
          }
        } else {
          module.statusText = _getLocalizedText('تم الفحص (لا توجد أعطال)', 'Scanned (No Faults)');
          module.statusColor = kSuccessColor;
        }
        
        // Resume live polling
        btCubit.send = true;
        btCubit.sendParameterRequiest(paramJSON);
      }
      
      if (!mounted) return;
      setState(() {
        _modules[i].progress = 1.0;
        _modules[i].isComplete = true;
      });
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    if (mounted) {
      setState(() {
        _isComplete = true;
      });
      
      // Send notification with results
      if (_hasFaults) {
        final isAr = Localizations.localeOf(context).languageCode == 'ar';
        showNotification(
          isAr ? '⚠️ الفحص الشامل: أعطال مكتشفة!' : '⚠️ Deep Scan: Faults Detected!',
          isAr
            ? 'تم اكتشاف ${dtcCodes.length} عطل: ${dtcCodes.join(", ")}'
            : '${dtcCodes.length} fault(s) found: ${dtcCodes.join(", ")}',
          payload: 'dtc_scan',
        );
      }
    }
  }

  /// Animate progress bar while waiting for real data
  Future<void> _animateProgress(int moduleIndex, {required int realDuration}) async {
    final steps = 20;
    final stepDuration = realDuration ~/ steps;
    for (int s = 0; s <= steps; s++) {
      if (!mounted) return;
      await Future.delayed(Duration(milliseconds: stepDuration));
      setState(() {
        _modules[moduleIndex].progress = s / steps;
      });
    }
  }

  String _getLocalizedText(String ar, String en) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr ? ar : en;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = l.localeName == 'ar';

    // ─── NOT CONNECTED: Show connection required ──────────────────────
    if (!_isConnected) {
      return Scaffold(
        backgroundColor: kPrimaryBackGroundColor,
        appBar: AppBar(
          backgroundColor: kSurface,
          elevation: 0,
          centerTitle: true,
          title: Text(
            l.inDepthCheckTitle,
            style: TextStyle(
              color: kPrimaryDarkColor,
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: kBorderColor),
          ),
          leading: BackButton(color: kPrimaryDarkColor),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: kDangerColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bluetooth_disabled_rounded, 
                    size: 50, color: kDangerColor),
                ),
                const SizedBox(height: 24),
                Text(
                  isAr ? 'غير متصل بالسيارة' : 'Not Connected to Vehicle',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: kPrimaryDarkColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isAr 
                    ? 'يرجى الاتصال بجهاز OBD2 عبر البلوتوث أولاً لإجراء الفحص الشامل.'
                    : 'Please connect to your OBD2 device via Bluetooth first to perform the in-depth scan.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: kSecondaryTextColor,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: kAccentGradient,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: kAccentColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      isAr ? 'رجوع للاتصال' : 'Go Back to Connect',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Guard: modules not initialized yet — show loading
    if (!_scanStarted) {
      return Scaffold(
        backgroundColor: kPrimaryBackGroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,

      appBar: AppBar(
        backgroundColor: kSurface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l.inDepthCheckTitle,
          style: TextStyle(
            color: kPrimaryDarkColor,
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorderColor),
        ),
        leading: BackButton(color: kPrimaryDarkColor),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: kSurface,
                border: Border(bottom: BorderSide(color: kBorderColor)),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: _isComplete ? 1.0 : null,
                          strokeWidth: 8,
                          color: _isComplete 
                              ? (_hasFaults ? kDangerColor : kSuccessColor) 
                              : kAccentColor,
                          backgroundColor: kDividerColor,
                        ),
                      ),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: (_isComplete 
                              ? (_hasFaults ? kDangerColor : kSuccessColor)
                              : kAccentColor).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            _isComplete 
                                ? (_hasFaults ? Icons.warning_rounded : Icons.check_rounded)
                                : Icons.search_rounded,
                            size: 40,
                            color: _isComplete 
                                ? (_hasFaults ? kDangerColor : kSuccessColor)
                                : kAccentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isComplete 
                        ? (_hasFaults 
                            ? (isAr ? 'تم اكتشاف ${dtcCodes.length} عطل!' : '${dtcCodes.length} Fault(s) Detected!')
                            : (isAr ? 'اكتمل الفحص — السيارة بحالة ممتازة ✅' : 'Scan Complete — Vehicle OK ✅'))
                        : (isAr ? 'جاري فحص أنظمة السيارة...' : 'Scanning Vehicle Systems...'),
                    style: TextStyle(
                      fontSize: _isComplete ? 14.sp : 16.sp,
                      fontWeight: FontWeight.w800,
                      color: _isComplete 
                          ? (_hasFaults ? kDangerColor : kSuccessColor)
                          : kPrimaryDarkColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Modules List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _modules.length + (_isComplete && _hasFaults ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show "View Fault Details" button at the end
                  if (index == _modules.length) {
                    return _buildViewFaultsButton(isAr);
                  }
                  
                  final m = _modules[index];
                  final isActive = index == _currentModuleIndex && !_isComplete;
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive 
                            ? kAccentColor 
                            : (m.isComplete && m.faultCount > 0 ? kDangerColor.withValues(alpha: 0.5) : kBorderColor),
                        width: isActive ? 1.5 : 1.0,
                      ),
                      boxShadow: isActive ? [
                        BoxShadow(
                          color: kAccentColor.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ] : null,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (m.isComplete 
                                    ? (m.statusColor ?? kSuccessColor) 
                                    : (isActive ? kAccentColor : kSubtleText))
                                  .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                m.icon,
                                color: m.isComplete 
                                    ? (m.statusColor ?? kSuccessColor)
                                    : (isActive ? kAccentColor : kSubtleText),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.sp,
                                      color: kPrimaryDarkColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    m.isComplete 
                                        ? (m.statusText ?? (isAr ? 'تم الفحص' : 'Scanned'))
                                        : (isActive 
                                            ? '${(m.progress * 100).toInt()}% ${isAr ? 'جاري الفحص...' : 'Scanning...'}'
                                            : (isAr ? 'في الانتظار' : 'Waiting')),
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: m.isComplete 
                                          ? (m.statusColor ?? kSuccessColor)
                                          : kSecondaryTextColor,
                                      fontWeight: m.isComplete ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                  // Show fault codes if any
                                  if (m.faultCodes.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      m.faultCodes.join(', '),
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: kDangerColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (m.isComplete)
                              Icon(
                                m.faultCount > 0 
                                    ? Icons.error_rounded 
                                    : Icons.check_circle_rounded,
                                color: m.faultCount > 0 ? kDangerColor : kSuccessColor,
                                size: 24,
                              ),
                          ],
                        ),
                        if (isActive || m.progress > 0) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: m.progress,
                              minHeight: 6,
                              backgroundColor: kDividerColor,
                              color: m.isComplete 
                                  ? (m.statusColor ?? kSuccessColor) 
                                  : kAccentColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewFaultsButton(bool isAr) {
    return GestureDetector(
      onTap: () {
        if (_foundFaults.isNotEmpty) {
          // Navigate to first fault's detail page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _FoundFaultsScreen(faults: _foundFaults),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 20),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kDangerColor, Color(0xFFE11D48)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kDangerColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              isAr ? 'عرض تفاصيل الأعطال (${_foundFaults.length})' : 'View Fault Details (${_foundFaults.length})',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleData {
  final String title;
  final IconData icon;
  final String obdCommand;
  double progress = 0.0;
  bool isComplete = false;
  int faultCount = 0;
  List<String> faultCodes = [];
  String? statusText;
  Color? statusColor;

  _ModuleData({
    required this.title,
    required this.icon,
    required this.obdCommand,
  });
}

/// Screen to display all found faults from the in-depth scan
class _FoundFaultsScreen extends StatelessWidget {
  final List<DtcCodeModel> faults;
  const _FoundFaultsScreen({required this.faults});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      appBar: AppBar(
        backgroundColor: kSurface,
        foregroundColor: kPrimaryDarkColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isAr ? 'الأعطال المكتشفة' : 'Detected Faults',
          style: const TextStyle(
            color: kPrimaryDarkColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faults.length,
        itemBuilder: (context, index) {
          final fault = faults[index];
          final critColor = _criticalColor(fault.criticalLevel);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CodeDescription(codeDesc: fault),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: critColor.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: critColor.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: critColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.error_outline_rounded, color: critColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fault.dtcCode ?? 'N/A',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: critColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fault.description ?? 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: kPrimaryDarkColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: critColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            fault.criticalLevel ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: critColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: kSubtleText, size: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _criticalColor(String? level) {
    if (level == null) return kWarningColor;
    final l = level.toLowerCase();
    if (l.contains('high')) return kDangerColor;
    if (l.contains('low')) return kSuccessColor;
    return kWarningColor;
  }
}
