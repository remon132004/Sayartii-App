import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:sayartii/services/notification.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'package:sayartii/views/trouble_scan/trouble_scan.dart';
import 'package:sayartii/widgets/home_container.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../connect_device/connect_device_view.dart';
import '../live_data_view.dart';
import '../in_depth_check_view.dart';
import 'cubit/data_cubit.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Timer fires every 60s but predictNotification() internally
    // skips if no car data is available (rpm == 0 && speed == 0).
    // We additionally guard here by checking connection state.
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (!mounted) return;
      final state = context.read<DataCubit>().state;
      if (state is BlueData || state is WifiData) {
        predictNotification();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),



              const SizedBox(height: 6),

              Align(
                alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                  l.aboutSayartii,
                  style: const TextStyle(fontSize: 13, color: kSecondaryTextColor),
                ),
              ),

              const SizedBox(height: 20),

              // ─── Connect button (pill shape) ───────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ConnectDeviceView())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: kAccentGradient,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: kAccentColor.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bluetooth_searching_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            l.activatePairedDevice,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ─── Car image ─────────────────────────────────────────────
              Container(
                height: 19.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      kAccentSofter,
                      kSurface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: kBorderColor),
                  boxShadow: [
                    BoxShadow(
                      color: kAccentColor.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset('assets/images/home_car.png', fit: BoxFit.contain),
                ),
              ),

              const SizedBox(height: 16),

              // ─── Quick actions ─────────────────────────────────────────
              Container(
                decoration: cardDecoration(radius: 20),
                child: Row(
                  children: [
                    _Action(
                      svg: 'assets/icons/live_data2.svg',
                      label: l.liveData,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const LiveData())),
                    ),
                    _VDivider(),
                    _Action(
                      svg: 'assets/icons/in_depth.svg',
                      label: l.inDepthCheck,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const InDepthCheckView())),
                    ),
                    _VDivider(),
                    _Action(
                      svg: 'assets/icons/trouble_scan.svg',
                      label: l.troubleScan,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const TroubleScan())),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Section title ─────────────────────────────────────────
              Align(
                alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                  l.drivingData,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: kPrimaryDarkColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ─── Data cards ────────────────────────────────────────────
              BlocBuilder<DataCubit, DataState>(
                builder: (_, state) {
                  final ok = state is BlueData || state is WifiData;
                  // '––' is shown when no car is connected — cleaner than fake '0'
                  const dash = '––';
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: HomeContainer(
                              data: ok ? (requistedData['speed'] ?? dash) : dash,
                              text1: ok ? ' km/h' : '',
                              text2: l.currentSpeed,
                              text3: l.realTimeSpeed,
                              icon: Icons.speed_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: HomeContainer(
                              data: ok ? (requistedData['engineRPM'] ?? dash) : dash,
                              text1: ok ? ' rpm' : '',
                              text2: l.engineRpm,
                              text3: l.realTimeRpm,
                              icon: Icons.rotate_right_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: HomeContainer(
                              data: ok ? (requistedData['mileage'] ?? dash) : dash,
                              text1: ok ? ' Km' : '',
                              text2: l.mileage,
                              text3: l.totalDistance,
                              icon: Icons.route_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: HomeContainer(
                              data: ok ? (requistedData['avgFuel'] ?? dash) : dash,
                              text1: ok ? ' L/100' : '',
                              text2: l.avgFuel,
                              text3: l.estimatedConsumption,
                              icon: Icons.local_gas_station_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),


              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub widgets ───────────────────────────────────────────────────────────────

class _Action extends StatelessWidget {
  final String svg;
  final String label;
  final VoidCallback onTap;
  const _Action({required this.svg, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kAccentSofter,
                  shape: BoxShape.circle,
                  border: Border.all(color: kAccentSoft),
                ),
                child: Center(
                  child: SvgPicture.asset(svg, height: 22,
                      colorFilter: const ColorFilter.mode(kAccentColor, BlendMode.srcIn)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: kSecondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 48, color: kBorderColor);
}
