import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:sayartii/models/prediction_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/cubit/language_cubit.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:sayartii/utils/login_helper.dart';
import 'package:sayartii/views/registertion/storeToken.dart';
import 'package:sayartii/views/registertion/login_package.dart';
import 'package:sayartii/views/registertion/apiData.dart';
import 'package:sayartii/views/notification/local_notification.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'connect_device/cubit/bluetooth_cubit.dart';

class MyInfoView extends StatefulWidget {
  const MyInfoView({super.key});
  @override
  State<MyInfoView> createState() => _MyInfoViewState();
}

class _MyInfoViewState extends State<MyInfoView> {
  bool _predict = false;
  String _name = '';
  String _email = '';
  String _car = '';
  String _carYear = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // ── Step 1: Show local cache instantly (no waiting) ──────────────────────
    final p = await ApiService.getProfile();
    if (mounted) {
      setState(() {
        _name    = (p['name']?.trim().isNotEmpty    == true) ? p['name']!    : 'Sayartii User';
        _email   = (p['email']?.trim().isNotEmpty   == true) ? p['email']!   : '';
        _car     = (p['car']?.trim().isNotEmpty     == true) ? p['car']!     : '';
        _carYear = (p['carYear']?.trim().isNotEmpty == true) ? p['carYear']! : '';
      });
    }

    // ── Step 2: Refresh from server in background ─────────────────────────────
    try {
      final token = await ApiService.getToken();
      if (token == null || !mounted) return;

      final dio = Dio();
      final response = await dio.get(
        '$kBackendUrl/api/account/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null && mounted) {
        final d = response.data as Map<String, dynamic>;
        final serverName    = d['name']?.toString().trim()    ?? '';
        final serverEmail   = d['email']?.toString().trim()   ?? '';
        final serverCar     = d['carName']?.toString().trim() ?? '';

        // Only update if server returned richer data
        if (serverName.isNotEmpty || serverCar.isNotEmpty) {
          setState(() {
            if (serverName.isNotEmpty)  _name  = serverName;
            if (serverEmail.isNotEmpty) _email = serverEmail;
            if (serverCar.isNotEmpty)   _car   = serverCar;
          });
        }
      }
    } catch (_) {
      // Server unavailable — local cache is already displayed, no action needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  children: [
                    // ─── Avatar ────────────────────────────────────────
                    Container(
                      width: 92, height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: kAccentGradient,
                        boxShadow: [
                          BoxShadow(
                            color: kAccentColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: kAccentSofter,
                        ),
                        child: Icon(Icons.person_rounded,
                            color: kAccentColor, size: 44),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      _name.isNotEmpty ? _name : 'User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kPrimaryDarkColor,
                      ),
                    ),
                    if (_email.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(_email,
                          style: const TextStyle(
                              color: kSecondaryTextColor, fontSize: 12.5)),
                    ],


                    const SizedBox(height: 28),

                    // ─── Settings Card ──────────────────────────────────
                    Container(
                      decoration: cardDecoration(radius: 20),
                      child: Column(
                        children: [
                          _Tile(
                            icon: Icons.directions_car_rounded,
                            iconColor: kAccentColor,
                            title: l.carName,
                            trailing: BlocBuilder<BluetoothCubit, dynamic>(
                              builder: (context, state) {
                                final isConnected = BlocProvider.of<BluetoothCubit>(context).device != null;
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_car.isNotEmpty) ...[
                                      Text(
                                        _carYear.isNotEmpty ? '$_car  •  $_carYear' : _car,
                                        style: const TextStyle(
                                            color: kSecondaryTextColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 10),
                                    ],
                                    Container(
                                      width: 7, height: 7,
                                      decoration: BoxDecoration(
                                        color: isConnected ? kSuccessColor : kSubtleText,
                                        shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      isConnected ? l.connected : l.disconnected,
                                      style: TextStyle(
                                          color: isConnected ? kSuccessColor : kSubtleText,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                  ],
                                );
                              },
                            ),
                          ),

                          _Sep(),

                          _Tile(
                            icon: Icons.query_stats_rounded,
                            iconColor: kAccentColor,
                            title: l.startPrediction,
                            trailing: FlutterSwitch(
                              activeColor: kAccentColor,
                              width: 52,
                              height: 26,
                              valueFontSize: 12,
                              toggleSize: 18,
                              value: _predict,
                              borderRadius: 13,
                              padding: 4,
                              showOnOff: false,
                              onToggle: (v) {
                                if (v && BlocProvider.of<BluetoothCubit>(context).device == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l.localeName == 'ar' ? 'يرجى الاتصال بالسيارة أولاً عبر البلوتوث لتفعيل الذكاء الاصطناعي.' : 'Please connect to the car first to enable AI prediction.'),
                                      backgroundColor: kDangerColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                    )
                                  );
                                  return;
                                }
                                setState(() => _predict = v);
                                BlocProvider.of<BluetoothCubit>(context).predict = v;
                                if (v) {
                                  showNotification(l.localeName == 'ar' ? 'التنبؤ الذكي' : 'Smart Prediction', l.localeName == 'ar' ? 'تم تفعيل التنبؤ الذكي بنجاح' : 'Smart Prediction Enabled Successfully');
                                } else {
                                  showNotification(l.localeName == 'ar' ? 'التنبؤ الذكي' : 'Smart Prediction', l.localeName == 'ar' ? 'تم إيقاف التنبؤ الذكي' : 'Smart Prediction Disabled');
                                }
                              },
                            ),
                          ),

                          _Sep(),

                          GestureDetector(
                            onTap: () => _showDemoSheet(context, l),
                            child: _Tile(
                              icon: Icons.science_rounded,
                              iconColor: kWarningColor,
                              title: l.localeName == 'ar' ? 'محاكاة عطل - Demo Mode' : 'Demo Mode — Simulate Error',
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: kWarningColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: kWarningColor.withValues(alpha: 0.35)),
                                ),
                                child: Text('DEMO',
                                    style: TextStyle(
                                        color: kWarningColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1)),
                              ),
                            ),
                          ),
                          _Sep(),

                          GestureDetector(
                            onTap: () =>
                                BlocProvider.of<LanguageCubit>(context).toggleLanguage(),
                            child: _Tile(
                              icon: Icons.language_rounded,
                              iconColor: kAccentColor,
                              title: l.localeName == 'ar' ? 'تغيير اللغة' : 'Change Language',
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: kAccentColor
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      color: kAccentColor
                                          .withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  l.localeName == 'ar' ? 'EN' : 'AR',
                                  style: const TextStyle(
                                      color: kAccentColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1),
                                ),
                              ),
                            ),
                          ),


                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ─── Logout ─────────────────────────────────────────
                    GestureDetector(
                      onTap: () => _confirmLogout(context, l),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: kDangerColor.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                              color: kDangerColor.withValues(alpha: 0.25)),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.logout_rounded,
                                  color: kDangerColor, size: 17),
                              const SizedBox(width: 8),
                              Text(
                                l.logOut,
                                style: const TextStyle(
                                  color: kDangerColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDemoSheet(BuildContext context, AppLocalizations l) {
    final isAr = l.localeName == 'ar';
    final scenarios = [
      _DemoScenario(
        code: 'P0101',
        title: isAr ? 'خلل في جهاز قياس تدفق الهواء' : 'Mass Air Flow Sensor Out of Range',
        severity: isAr ? 'عالية' : 'High',
        severityColor: kDangerColor,
        icon: Icons.air_rounded,
        description: isAr
            ? 'تعذّر على حساس تدفق الهواء (MAF) توليد قراءة دقيقة. قد يؤدي ذلك إلى زيادة استهلاك الوقود.'
            : 'The MAF sensor failed to produce an accurate reading. This may cause poor fuel economy.',
      ),
      _DemoScenario(
        code: 'P0217',
        title: isAr ? 'ارتفاع حرارة المحرك' : 'Engine Coolant Over Temperature',
        severity: isAr ? 'حرجة' : 'Critical',
        severityColor: const Color(0xFFFF5C00),
        icon: Icons.thermostat_rounded,
        description: isAr
            ? 'تجاوزت درجة حرارة سائل التبريد الحد الأقصى الآمن. أوقف المحرك فوراً لتفادي الأضرار.'
            : 'Engine coolant temperature exceeded safe limits. Stop the engine immediately to prevent damage.',
      ),
      _DemoScenario(
        code: 'C0300',
        title: isAr ? 'خلل في نظام إدارة الإطارات' : 'Rear Wheel Speed Sensor Fault',
        severity: isAr ? 'متوسطة' : 'Medium',
        severityColor: kWarningColor,
        icon: Icons.tire_repair_rounded,
        description: isAr
            ? 'اكتشف الذكاء الاصطناعي شذوذاً في بيانات سرعة عجلة خلفية. يُنصح بفحص نظام ABS.'
            : 'AI detected anomaly in rear wheel speed data. Recommend inspecting the ABS module.',
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DemoModeSheet(scenarios: scenarios, isAr: isAr),
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l.logOut,
            style: const TextStyle(
                color: kPrimaryDarkColor, fontWeight: FontWeight.w800),
            textAlign: TextAlign.right),
        content: Text(l.areYouSureLogOut,
            style: const TextStyle(color: kSecondaryTextColor, height: 1.5),
            textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.backBtn,
                style: const TextStyle(color: kSecondaryTextColor)),
          ),
          TextButton(
            onPressed: () async {
              await deleteAccessToken();
              await Helper.saveUserLoggedInSharedPreference(false);
              if (ctx.mounted) {
                Navigator.of(ctx).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (r) => false,
                );
              }
            },
            child: Text(l.continueBtn,
                style: const TextStyle(
                    color: kDangerColor, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable tile (light theme) ─────────────────────────────────────────────
class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget? trailing;
  const _Tile(
      {required this.icon,
      required this.iconColor,
      required this.title,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          color: kPrimaryDarkColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _Sep extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      height: 1, color: kDividerColor,
      margin: const EdgeInsets.symmetric(horizontal: 16));
}

// ─── Demo Mode Data Model ─────────────────────────────────────────────────────
class _DemoScenario {
  final String code;
  final String title;
  final String severity;
  final Color severityColor;
  final IconData icon;
  final String description;
  const _DemoScenario({
    required this.code,
    required this.title,
    required this.severity,
    required this.severityColor,
    required this.icon,
    required this.description,
  });
}

// ─── Professional Demo Mode Bottom Sheet (Light Theme) ────────────────────────
class _DemoModeSheet extends StatefulWidget {
  final List<_DemoScenario> scenarios;
  final bool isAr;
  const _DemoModeSheet({required this.scenarios, required this.isAr});

  @override
  State<_DemoModeSheet> createState() => _DemoModeSheetState();
}

class _DemoModeSheetState extends State<_DemoModeSheet>
    with SingleTickerProviderStateMixin {
  int? _selected;
  bool _fired = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulse = Tween(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _fire() async {
    if (_selected == null) return;
    final s = widget.scenarios[_selected!];
    if (!dtcCodes.contains(s.code)) dtcCodes.add(s.code);

    // ── Populate global predictedCodesList so the details page has data ──
    predictedCodesList = PredictionModel(
      prediction: s.title,
      troubleCode: s.code,
      estimatedTimeRemaining: null,
      openAiResponse: s.description,
    );

    await showNotification(
      widget.isAr ? '⚠️ تحذير: عطل مكتشف' : '⚠️ Issue Detected by AI',
      widget.isAr
          ? 'سيارتك تبلغ عن مشكلة (${s.code}). راجع تفاصيل الفحص.'
          : 'Your car reports: ${s.code} — ${s.title}. Open app for details.',
    );
    setState(() => _fired = true);
    // Close the bottom sheet immediately so the delayed pop doesn't
    // accidentally dismiss the details page if the user taps the notification.
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isAr;
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: kAccentColor.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: kBorderColor,
                borderRadius: BorderRadius.circular(100)),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: isAr ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isAr) ...[
                ScaleTransition(
                  scale: _pulse,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: kWarningColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.science_rounded,
                        color: kWarningColor, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Column(
                crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'وضع المحاكاة — Demo Mode' : 'Demo Mode — Simulation',
                    style: const TextStyle(
                        color: kPrimaryDarkColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800),
                  ),
                  Text(
                    isAr
                        ? 'اختر سيناريو لإرسال عطل وهمي'
                        : 'Select a scenario to fire a mock fault',
                    style: const TextStyle(
                        color: kSecondaryTextColor, fontSize: 12),
                  ),
                ],
              ),
              if (isAr) ...[
                const SizedBox(width: 12),
                ScaleTransition(
                  scale: _pulse,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: kWarningColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.science_rounded,
                        color: kWarningColor, size: 18),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 18),

          // Scenario cards
          ...widget.scenarios.asMap().entries.map((e) {
            final idx = e.key;
            final s = e.value;
            final selected = _selected == idx;
            return GestureDetector(
              onTap: () => setState(() {
                _selected = selected ? null : idx;
                _fired = false;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected
                      ? s.severityColor.withValues(alpha: 0.05)
                      : kPrimaryBackGroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? s.severityColor.withValues(alpha: 0.5)
                        : kBorderColor,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: s.severityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(s.icon, color: s.severityColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isAr
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Row(
                            textDirection: isAr
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            children: [
                              Text(s.code,
                                  style: TextStyle(
                                      color: s.severityColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      fontFamily: 'monospace')),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: s.severityColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(s.severity,
                                    style: TextStyle(
                                        color: s.severityColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(s.title,
                              style: const TextStyle(
                                  color: kPrimaryDarkColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          if (selected) ...[
                            const SizedBox(height: 4),
                            Text(s.description,
                                style: const TextStyle(
                                    color: kSecondaryTextColor,
                                    fontSize: 11,
                                    height: 1.5)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected ? s.severityColor : kSubtleText,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Fire button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _selected == null || _fired ? null : _fire,
              icon: _fired
                  ? const Icon(Icons.check_rounded, size: 20)
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                _fired
                    ? (isAr ? 'تم الإرسال بنجاح!' : 'Sent Successfully!')
                    : _selected == null
                        ? (isAr ? 'اختر سيناريو أولاً' : 'Select a scenario first')
                        : (isAr ? 'أرسل الإشعار الآن' : 'Fire Notification Now'),
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _fired
                    ? kSuccessColor
                    : _selected == null
                        ? kDividerColor
                        : kWarningColor,
                foregroundColor: _fired || _selected == null
                    ? kSubtleText
                    : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}