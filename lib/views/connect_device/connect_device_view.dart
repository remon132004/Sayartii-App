import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:sayartii/views/connect_device/bluetooth.dart';
import 'package:sayartii/views/connect_device/cubit/connect_device_cubit.dart';
import 'package:sayartii/views/connect_device/wifi.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custon_choice_chip.dart';

class ConnectDeviceView extends StatelessWidget {
  const ConnectDeviceView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryBackGroundColor,
        foregroundColor: kPrimaryDarkColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l.connectivity,
          style: TextStyle(
            color: kPrimaryDarkColor,
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Connection type selector ──────────────────────────
            const CustomChoiceChip(),
            const SizedBox(height: 20),

            // ─── Connection panel ──────────────────────────────────
            BlocBuilder<ConnectDeviceCubit, ConnectDeviceState>(
              builder: (context, state) {
                final isBluetooth = state is! ConnectDeviceWifiState;
                return isBluetooth ? const Bluetooth() : const WiFi();
              },
            ),

            const SizedBox(height: 32),

            // ─── How-to guide ──────────────────────────────────────
            _HowToGuide(isAr: isAr),
          ],
        ),
      ),
    );
  }
}

// ─── How To Connect Guide ──────────────────────────────────────────────────────
class _HowToGuide extends StatelessWidget {
  final bool isAr;
  const _HowToGuide({required this.isAr});

  @override
  Widget build(BuildContext context) {
    final steps = isAr
        ? [
            _Step(
              step: '01',
              icon: Icons.power_outlined,
              title: 'شغّل المحرك',
              desc: 'ابدأ تشغيل المحرك أو ضع مفتاح الإشعال على وضع ON.',
            ),
            _Step(
              step: '02',
              icon: Icons.usb_rounded,
              title: 'وصّل الجهاز',
              desc: 'أدخل جهاز ELM327 في منفذ OBD2 (تحت لوحة التحكم).',
            ),
            _Step(
              step: '03',
              icon: Icons.bluetooth_searching_rounded,
              title: 'اضغط "بحث"',
              desc: 'اضغط على زر البحث واختر جهازك من القائمة.',
            ),
            _Step(
              step: '04',
              icon: Icons.check_circle_outline_rounded,
              title: 'ابدأ القراءة',
              desc: 'بعد الاتصال، ستبدأ سيارتي في قراءة بيانات سيارتك فوراً.',
            ),
          ]
        : [
            _Step(
              step: '01',
              icon: Icons.power_outlined,
              title: 'Start the Engine',
              desc: 'Turn on the engine or set the ignition to the ON position.',
            ),
            _Step(
              step: '02',
              icon: Icons.usb_rounded,
              title: 'Plug in the Adapter',
              desc: 'Insert your ELM327 OBD2 adapter under the dashboard.',
            ),
            _Step(
              step: '03',
              icon: Icons.bluetooth_searching_rounded,
              title: 'Tap Search',
              desc: 'Press the search button and pick your device from the list.',
            ),
            _Step(
              step: '04',
              icon: Icons.check_circle_outline_rounded,
              title: 'Start Reading',
              desc: 'Once connected, Sayartii instantly reads your car\'s live data.',
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          isAr ? 'كيفية الاتصال' : 'How to Connect',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: kPrimaryDarkColor,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),

        // Steps list
        ...List.generate(steps.length, (i) {
          final s = steps[i];
          final isLast = i == steps.length - 1;
          return _StepRow(step: s, isLast: isLast, isAr: isAr);
        }),
      ],
    );
  }
}

class _Step {
  final String step, title, desc;
  final IconData icon;
  const _Step({required this.step, required this.icon, required this.title, required this.desc});
}

class _StepRow extends StatelessWidget {
  final _Step step;
  final bool isLast;
  final bool isAr;
  const _StepRow({required this.step, required this.isLast, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: step indicator + connector line
          Column(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: kAccentSofter,
                  shape: BoxShape.circle,
                  border: Border.all(color: kAccentSoft, width: 1.5),
                ),
                child: Center(
                  child: Icon(step.icon, color: kAccentColor, size: 18),
                ),
              ),
              if (!isLast) ...[
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: kBorderColor,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(width: 14),

          // Right: text content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: kAccentColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          step.step,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        step.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: kPrimaryDarkColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.desc,
                    style: const TextStyle(
                      fontSize: 12,
                      color: kSecondaryTextColor,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
