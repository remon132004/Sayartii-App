import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'package:sizer/sizer.dart';
import 'home/cubit/data_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LiveData extends StatefulWidget {
  const LiveData({super.key});

  @override
  State<LiveData> createState() => _LiveDataState();
}

class _LiveDataState extends State<LiveData> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoSwipeTimer;
  bool _hasSwipedToMetrics = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<DataCubit>().state;
      if (state is BlueData || state is WifiData) {
        _startAutoSwipeTimer();
      }
    });
  }

  void _startAutoSwipeTimer() {
    if (_hasSwipedToMetrics) return;
    _autoSwipeTimer?.cancel();
    _autoSwipeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _pageController.hasClients && _currentPage == 0) {
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
        setState(() {
          _hasSwipedToMetrics = true;
        });
      }
    });
  }

  void _cancelAutoSwipeTimer() {
    _autoSwipeTimer?.cancel();
    _autoSwipeTimer = null;
    _hasSwipedToMetrics = false;
  }

  @override
  void dispose() {
    _autoSwipeTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEF2FA),
        foregroundColor: kPrimaryDarkColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.obdLiveData,
          style: TextStyle(
            color: kPrimaryDarkColor,
            fontWeight: FontWeight.w800,
            fontSize: 15.sp,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: BlocConsumer<DataCubit, DataState>(
        listener: (context, state) {
          final connected = state is BlueData || state is WifiData;
          if (connected) {
            _startAutoSwipeTimer();
          } else {
            _cancelAutoSwipeTimer();
            if (_currentPage != 0 && _pageController.hasClients) {
              _pageController.jumpToPage(0);
            }
          }
        },
        builder: (context, state) {
          final connected = state is BlueData || state is WifiData;

          if (!connected) {
            // ─── Not connected: show initial car screen ─────────────────
            return _buildInitialScreen(context);
          }

          // ─── Connected: two-page swipe view ────────────────────────────
          return Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildInitialConnectedScreen(context),
                    _buildMetricsScreen(context, state),
                  ],
                ),
              ),
              // ─── Page indicator dots ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (i) {
                    final active = _currentPage == i;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 20 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: active ? kAccentColor : kBorderColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Screen 1 (not connected) ─────────────────────────────────────────────
  Widget _buildInitialScreen(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/home_car.png',
                  height: MediaQuery.of(context).size.height * 0.38,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: kAccentColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)!.connectToDevice,
                      style: TextStyle(
                        color: kAccentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  // ─── Screen 1 (connected) — car + "Reading..." ────────────────────────────
  Widget _buildInitialConnectedScreen(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/live_data_car.svg',
                  height: MediaQuery.of(context).size.height * 0.40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: kAccentColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l.readingLiveData,
                      style: TextStyle(
                        color: kAccentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Swipe hint
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.swipeForSensorData,
                      style: TextStyle(
                        color: kSubtleText,
                        fontSize: 10.sp,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                      color: kSubtleText,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Screen 2 — metrics + car side view ───────────────────────────────────
  Widget _buildMetricsScreen(BuildContext context, DataState state) {
    final l = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Stack(
      children: [
        // Car image (mirrored and placed on left for RTL, right for LTR)
        Positioned(
          left: isRtl ? -MediaQuery.of(context).size.width * 0.08 : null,
          right: isRtl ? null : -MediaQuery.of(context).size.width * 0.08,
          top: 0,
          bottom: 0,
          child: Opacity(
            opacity: 0.92,
            child: Transform.scale(
              scaleX: isRtl ? -1.0 : 1.0,
              child: SvgPicture.asset(
                'assets/images/live_data_car.svg',
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        // Metrics list
        Positioned.fill(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              isRtl ? MediaQuery.of(context).size.width * 0.45 : 28,
              30,
              isRtl ? 28 : MediaQuery.of(context).size.width * 0.45,
              30,
            ),
            child: Column(
              crossAxisAlignment: isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _dataRow(context,
                    data: requistedData["speed"] ?? "0",
                    unit: "km/h",
                    icon: "assets/icons/live_data_current_speed.svg",
                    name: l.currentSpeedLabel,
                    isRtl: isRtl),
                _dataRow(context,
                    data: requistedData["engineCoolantTemp"] ?? "0",
                    unit: "%",
                    icon: "assets/icons/live_data_coolant.svg",
                    name: l.engineCoolantLabel,
                    isRtl: isRtl),
                _dataRow(context,
                    data: requistedData["engineRPM"] ?? "0",
                    unit: "rpm",
                    icon: "assets/icons/live_data_battery.svg",
                    name: l.engineRpmLabel,
                    isRtl: isRtl),
                _dataRow(context,
                    data: requistedData["engineCoolantTemp"] ?? "0",
                    unit: "°C",
                    icon: "assets/icons/live_data_temperature.svg",
                    name: l.engineCoolantLabel,
                    isRtl: isRtl),
                _dataRow(context,
                    data: requistedData["shortTermFuelBank1"] ?? "0",
                    unit: "%",
                    icon: "assets/icons/live_data_fuel.svg",
                    name: l.fuelTrimLabel,
                    isRtl: isRtl),
                _dataRow(context,
                    data: requistedData["engineLoad"] ?? "0",
                    unit: "%",
                    icon: "assets/icons/live_data_load.svg",
                    name: l.engineLoadLabel,
                    isRtl: isRtl),
                _dataRow(context,
                    data: requistedData["airintakeTemp"] ?? "0",
                    unit: "°C",
                    icon: "assets/icons/live_data_temperature.svg",
                    name: l.airIntakeLabel,
                    isRtl: isRtl),
                _dataRow(context,
                    data: requistedData["throttlePosition"] ?? "0",
                    unit: "%",
                    icon: "assets/icons/live_data_baseline-speed.svg",
                    name: l.throttleLabel,
                    isRtl: isRtl),
                _dataRow(context,
                    data: requistedData["timingAdvance"] ?? "0",
                    unit: "kPa",
                    icon: "assets/icons/live_data_pressure.svg",
                    name: l.timingAdvanceLabel,
                    isRtl: isRtl),
                const SizedBox(height: 12),
                // "Check more sensor data" link
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isRtl) ...[
                        Icon(Icons.arrow_back_rounded,
                            color: kAccentColor, size: 14),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        l.checkMoreSensors,
                        style: TextStyle(
                          color: kAccentColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: kAccentColor,
                        ),
                      ),
                      if (!isRtl) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            color: kAccentColor, size: 14),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dataRow(BuildContext context,
      {required data, required unit, required icon, required name, required bool isRtl}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: "$data ",
                style: TextStyle(
                    color: kPrimaryDarkColor,
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5),
              ),
              TextSpan(
                text: unit,
                style: TextStyle(
                    color: kSecondaryTextColor,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600),
              ),
            ]),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRtl) ...[
                Text(
                  name,
                  style: TextStyle(
                      color: kSecondaryTextColor,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 5),
                SvgPicture.asset(icon,
                    width: 13,
                    height: 13,
                    colorFilter:
                        const ColorFilter.mode(kAccentColor, BlendMode.srcIn)),
              ] else ...[
                SvgPicture.asset(icon,
                    width: 13,
                    height: 13,
                    colorFilter:
                        const ColorFilter.mode(kAccentColor, BlendMode.srcIn)),
                const SizedBox(width: 5),
                Text(
                  name,
                  style: TextStyle(
                      color: kSecondaryTextColor,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
