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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      appBar: AppBar(
        backgroundColor: kSurface,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorderColor),
        ),
      ),
      body: BlocBuilder<DataCubit, DataState>(builder: (context, state) {
        final connected = state is BlueData || state is WifiData;
        return Column(
          children: [
            // ─── Connection Banner ───────────────────────────────────
            Container(
              color: kSurface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: connected ? kAccentSofter : kDividerColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.wifi_tethering_rounded,
                          color: connected ? kAccentColor : kSubtleText, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)!.liveDataStream,
                      style: TextStyle(
                          color: kPrimaryDarkColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp),
                    ),
                  ]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: connected
                          ? kSuccessColor.withValues(alpha: 0.08)
                          : kDividerColor,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: connected
                            ? kSuccessColor.withValues(alpha: 0.35)
                            : kBorderColor,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            color: connected ? kSuccessColor : kSubtleText,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          connected
                              ? AppLocalizations.of(context)!.connected
                              : AppLocalizations.of(context)!.disconnected,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: connected ? kSuccessColor : kSubtleText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: kBorderColor),

            if (connected)
              Expanded(
                child: Stack(
                  children: [
                    // Right aligned car background
                    Positioned(
                      right: -MediaQuery.of(context).size.width * 0.1,
                      top: 10,
                      bottom: 10,
                      child: Opacity(
                        opacity: 0.9,
                        child: SvgPicture.asset(
                          'assets/images/live_data_car.svg',
                          height: MediaQuery.of(context).size.height,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    // Left aligned data
                    Positioned.fill(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 30, 20, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _dataRow(context,
                                data: requistedData["speed"] ?? "0", unit: "km/h",
                                icon: "assets/icons/live_data_current_speed.svg",
                                name: AppLocalizations.of(context)!.currentSpeedLabel),
                            _dataRow(context,
                                data: requistedData["engineRPM"] ?? "0", unit: "RPM",
                                icon: "assets/icons/live_data_battery.svg",
                                name: AppLocalizations.of(context)!.engineRpmLabel),
                            _dataRow(context,
                                data: requistedData["engineCoolantTemp"] ?? "0", unit: "°C",
                                icon: "assets/icons/live_data_coolant.svg",
                                name: AppLocalizations.of(context)!.engineCoolantLabel),
                            _dataRow(context,
                                data: requistedData["shortTermFuelBank1"] ?? "0", unit: "%",
                                icon: "assets/icons/live_data_fuel.svg",
                                name: AppLocalizations.of(context)!.fuelTrimLabel),
                            _dataRow(context,
                                data: requistedData["engineLoad"] ?? "0", unit: "%",
                                icon: "assets/icons/live_data_load.svg",
                                name: AppLocalizations.of(context)!.engineLoadLabel),
                            _dataRow(context,
                                data: requistedData["throttlePosition"] ?? "0", unit: "%",
                                icon: "assets/icons/live_data_baseline-speed.svg",
                                name: AppLocalizations.of(context)!.throttleLabel),
                            _dataRow(context,
                                data: requistedData["airintakeTemp"] ?? "0", unit: "°C",
                                icon: "assets/icons/live_data_temperature.svg",
                                name: AppLocalizations.of(context)!.airIntakeLabel),
                            _dataRow(context,
                                data: requistedData["timingAdvance"] ?? "0", unit: "°",
                                icon: "assets/icons/live_data_pressure.svg",
                                name: AppLocalizations.of(context)!.timingAdvanceLabel),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          gradient: kAccentGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kAccentColor.withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.bluetooth_searching_rounded,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.connectToDevice,
                        style: TextStyle(
                            color: kSecondaryTextColor, fontSize: 13.sp,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _dataRow(BuildContext context,
      {required data, required unit, required icon, required name}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: "$data",
                style: TextStyle(
                    color: kPrimaryDarkColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5),
              ),
              TextSpan(
                text: unit,
                style: TextStyle(
                    color: kSecondaryTextColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600),
              ),
            ]),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(icon, width: 14, height: 14,
                  colorFilter: const ColorFilter.mode(
                      kAccentColor, BlendMode.srcIn)),
              const SizedBox(width: 6),
              Text(
                name,
                style: TextStyle(
                    color: kSecondaryTextColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
