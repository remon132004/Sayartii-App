import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'package:sizer/sizer.dart';
import 'home/cubit/data_cubit.dart';

class LiveData extends StatefulWidget {
  const LiveData({super.key});

  @override
  State<LiveData> createState() => _LiveDataState();
}

class _LiveDataState extends State<LiveData> {
  List<Map<String, dynamic>> dataInformation = [
    {
      "data": requistedData["speed"],
      "unit": "km/h",
      "icon": "assets/icon/live_data_current_speed.svg",
      "name": "Current speed"
    },
    {"data": requistedData["engineRPM"], "unit": "RPM", "icon": "", "name": ""},
    {
      "data": requistedData["engineCoolantTemp"],
      "unit": "°C",
      "icon": "assets/icons/live_data_coolant.svg",
      "name": "Engine coolant temp"
    },
    {
      "data": requistedData["shortTermFuelBank1"],
      "unit": "%",
      "icon": "assets/icons/live_data_fuel.svg",
      "name": "Short term fuel bank1"
    },
    {
      "data": requistedData["engineLoad"],
      "unit": "%",
      "icon": "assets/icons/live_data_load.svg",
      "name": "Engine load"
    },
    {
      "data": requistedData["throttlePosition"],
      "unit": "%",
      "icon": "assets/icons/live_data_baseline-speed.svg",
      "name": "Throttle position"
    },
    {
      "data": requistedData["airintakeTemp"],
      "unit": "°C",
      "icon": "assets/icons/live_data_temperature.svg",
      "name": "Airintake temp"
    },
    {
      "data": requistedData["timingAdvance"],
      "unit": "°",
      "icon": "assets/icons/live_data_pressure.svg",
      "name": "Timing advance"
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.obdLiveData),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<DataCubit, DataState>(builder: (context, state) {
            if (state is BlueData || state is WifiData) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      dataContainer(
                        data: requistedData["speed"],
                        unit: "km/h",
                        icon: "assets/icons/live_data_current_speed.svg",
                        name: AppLocalizations.of(context)!.currentSpeedLabel,
                      ),
                      dataContainer(
                        data: requistedData["engineRPM"],
                        unit: "RPM",
                        icon: "assets/icons/live_data_battery.svg",
                        name: AppLocalizations.of(context)!.engineRpmLabel,
                      ),
                      dataContainer(
                        data: requistedData["engineCoolantTemp"],
                        unit: "°C",
                        icon: "assets/icons/live_data_coolant.svg",
                        name: AppLocalizations.of(context)!.engineCoolantLabel,
                      ),
                      dataContainer(
                        data: requistedData["shortTermFuelBank1"] ?? "0",
                        unit: "%",
                        icon: "assets/icons/live_data_fuel.svg",
                        name: AppLocalizations.of(context)!.fuelTrimLabel,
                      ),
                      dataContainer(
                        data: requistedData["engineLoad"],
                        unit: "%",
                        icon: "assets/icons/live_data_load.svg",
                        name: AppLocalizations.of(context)!.engineLoadLabel,
                      ),
                      dataContainer(
                        data: requistedData["throttlePosition"],
                        unit: "%",
                        icon: "assets/icons/live_data_baseline-speed.svg",
                        name: AppLocalizations.of(context)!.throttleLabel,
                      ),
                      dataContainer(
                        data: requistedData["airintakeTemp"],
                        unit: "°C",
                        icon: "assets/icons/live_data_temperature.svg",
                        name: AppLocalizations.of(context)!.airIntakeLabel,
                      ),
                      dataContainer(
                        data: requistedData["timingAdvance"],
                        unit: "°",
                        icon: "assets/icons/live_data_pressure.svg",
                        name: AppLocalizations.of(context)!.timingAdvanceLabel,
                      ),
                    ],
                  ),
                  SvgPicture.asset("assets/images/live_data_car.svg"),
                ],
              );
            } else {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: kPrimaryBlueColor,
                    ),
                    const SizedBox(height: 12),
                    Text(AppLocalizations.of(context)!.connectToDevice),
                  ],
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget dataContainer(
      {required data, required unit, required icon, required name}) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w600),
              children: [
                TextSpan(text: data, style: TextStyle(fontSize: 16.sp)),
                TextSpan(
                    text: unit,
                    style: TextStyle(fontSize: 8.sp, color: Colors.black54)),
              ],
            ),
          ),
          Row(
            children: [
              SvgPicture.asset(icon),
              Text(name,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  )),
            ],
          )
        ],
      ),
    );
  }
}
