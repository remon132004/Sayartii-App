import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:sayartii/constants.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InDepthCheckView extends StatefulWidget {
  const InDepthCheckView({super.key});

  @override
  State<InDepthCheckView> createState() => _InDepthCheckViewState();
}

class _InDepthCheckViewState extends State<InDepthCheckView> {
  late List<_ModuleData> _modules;
  int _currentModuleIndex = 0;
  bool _isComplete = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l = AppLocalizations.of(context)!;
    final isAr = l.localeName == 'ar';
    _modules = [
      _ModuleData(
        title: isAr ? 'وحدة التحكم في المحرك (ECM)' : 'Engine Control Module (ECM)',
        icon: Icons.engineering_rounded,
        progress: 0.0,
      ),
      _ModuleData(
        title: isAr ? 'وحدة التحكم في ناقل الحركة (TCM)' : 'Transmission Control Module (TCM)',
        icon: Icons.settings_rounded,
        progress: 0.0,
      ),
      _ModuleData(
        title: isAr ? 'نظام الفرامل المانعة للانغلاق (ABS)' : 'Anti-lock Braking System (ABS)',
        icon: Icons.car_crash_rounded,
        progress: 0.0,
      ),
      _ModuleData(
        title: isAr ? 'نظام الوسائد الهوائية (SRS)' : 'Supplemental Restraint System (SRS)',
        icon: Icons.airline_seat_recline_normal_rounded,
        progress: 0.0,
      ),
      _ModuleData(
        title: isAr ? 'وحدة التحكم في الجسم (BCM)' : 'Body Control Module (BCM)',
        icon: Icons.directions_car_rounded,
        progress: 0.0,
      ),
    ];
    _startScanning();
  }

  void _startScanning() async {
    for (int i = 0; i < _modules.length; i++) {
      if (!mounted) return;
      setState(() {
        _currentModuleIndex = i;
      });

      // Animate progress from 0.0 to 1.0
      for (double p = 0.0; p <= 1.0; p += 0.05) {
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 50));
        setState(() {
          _modules[i].progress = p;
        });
      }
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = l.localeName == 'ar';

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
                          color: _isComplete ? kSuccessColor : kAccentColor,
                          backgroundColor: kDividerColor,
                        ),
                      ),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: (_isComplete ? kSuccessColor : kAccentColor).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            _isComplete ? Icons.check_rounded : Icons.search_rounded,
                            size: 40,
                            color: _isComplete ? kSuccessColor : kAccentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isComplete 
                        ? (isAr ? 'اكتمل الفحص بنجاح' : 'Scan Completed Successfully')
                        : (isAr ? 'جاري فحص أنظمة السيارة...' : 'Scanning Vehicle Systems...'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: _isComplete ? kSuccessColor : kPrimaryDarkColor,
                    ),
                  ),
                ],
              ),
            ),

            // Modules List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _modules.length,
                itemBuilder: (context, index) {
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
                        color: isActive ? kAccentColor : kBorderColor,
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
                                color: (m.isComplete ? kSuccessColor : (isActive ? kAccentColor : kSubtleText)).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                m.icon,
                                color: m.isComplete ? kSuccessColor : (isActive ? kAccentColor : kSubtleText),
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
                                        ? (isAr ? 'تم الفحص (لا توجد أعطال)' : 'Scanned (No Faults)')
                                        : (isActive 
                                            ? '${(m.progress * 100).toInt()}% ${isAr ? 'جاري الفحص...' : 'Scanning...'}'
                                            : (isAr ? 'في الانتظار' : 'Waiting')),
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: m.isComplete ? kSuccessColor : kSecondaryTextColor,
                                      fontWeight: m.isComplete ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (m.isComplete)
                              Icon(Icons.check_circle_rounded, color: kSuccessColor, size: 24),
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
                              color: m.isComplete ? kSuccessColor : kAccentColor,
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
}

class _ModuleData {
  final String title;
  final IconData icon;
  double progress;
  bool isComplete;

  _ModuleData({
    required this.title,
    required this.icon,
    this.progress = 0.0,
    this.isComplete = false,
  });
}
