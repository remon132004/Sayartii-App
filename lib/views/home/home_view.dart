import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayartii/services/notification.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'package:sayartii/views/trouble_scan/trouble_scan.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:sayartii/widgets/custom_button.dart';
import 'package:sayartii/widgets/home_container.dart';
import 'package:sayartii/constants.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../connect_device/connect_device_view.dart';
import '../live_data_view.dart';
import 'cubit/data_cubit.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Timer? _predictionTimer;

  @override
  void initState() {
    super.initState();
    // Send car data to AI every 60 seconds to detect high-severity faults
    _predictionTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      predictNotification();
    });
  }

  @override
  void dispose() {
    _predictionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20.h,
              width: double.maxFinite,
              child: SvgPicture.asset(
                'assets/images/app_bar2.svg',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomButton(
                  onPressed: () {
                    //BlocProvider.of<ConnectDeviceCubit>(context).changeState();

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ConnectDeviceView()));
                  },
                  title: AppLocalizations.of(context)!.activatePairedDevice,
                  color: kPrimaryBlueColor),
            ),
            SizedBox(
              height: 20.h,
              width: double.infinity,
              child: Image.asset(
                'assets/images/home_car.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    decoration: boxDecoration(),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 2.w,
                        ),
                        customIconButtom(
                          onPressed: () {
                            // BlocProvider.of<BluetoothCubit>(context).send =
                            //     false;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const TroubleScan()));
                          },
                          image: "assets/icons/trouble_scan.svg",
                          text: AppLocalizations.of(context)!.troubleScan,
                        ),
                        const Spacer(
                          flex: 2,
                        ),
                        customIconButtom(
                          onPressed: () {},
                          image: "assets/icons/in_depth.svg",
                          text: AppLocalizations.of(context)!.inDepthCheck,
                        ),
                        const Spacer(
                          flex: 3,
                        ),
                        customIconButtom(
                          isSvg: false,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LiveData()));
                          },
                          image: "assets/icons/cloud.png",
                          text: AppLocalizations.of(context)!.liveData,
                        ),
                        SizedBox(
                          width: 5.w,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.drivingData,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  BlocBuilder<DataCubit, DataState>(
                    builder: (context, state) {
                      if (state is BlueData || state is WifiData) {
                        // print("====>>>>$requistedData");
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            HomeContainer(
                              data: requistedData['speed'],
                              text1: "",
                              text2: AppLocalizations.of(context)!.currentSpeed,
                              text3: AppLocalizations.of(context)!.realTimeSpeed,
                            ),
                            HomeContainer(
                              data: requistedData['engineRPM'],
                              text1: "",
                              text2: AppLocalizations.of(context)!.engineRpm,
                              text3: AppLocalizations.of(context)!.realTimeRpm,
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            HomeContainer(
                              data: AppLocalizations.of(context)!.notAvailable,
                              text1: "",
                              text2: AppLocalizations.of(context)!.currentSpeed,
                              text3: AppLocalizations.of(context)!.realTimeSpeed,
                            ),
                            HomeContainer(
                              data: AppLocalizations.of(context)!.notAvailable,
                              text1: "",
                              text2: AppLocalizations.of(context)!.engineRpm,
                              text3: AppLocalizations.of(context)!.realTimeRpm,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  // Row(
                  //   children: [
                  //     Text(
                  //       "Trip data",
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.w600,
                  //         fontSize: 16.sp,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: 2.h,
                  // ),
                  // Container(
                  //   height: 15.h,
                  //   width: double.maxFinite,
                  //   decoration: boxDecoration(),
                  //   child: Image.asset(
                  //     "assets/images/Data.png",
                  //     scale: 1.4,
                  //   ),
                  // )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget customIconButtom(
      {required void Function()? onPressed,
      required String image,
      required String text,
      bool isSvg = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SizedBox(
          child: Column(
        children: [
          IconButton(
            onPressed: onPressed,
            icon: isSvg
                ? SvgPicture.asset(
                    image,
                    height: 4.h,
                  )
                : Image.asset(
                    image,
                    height: 4.h,
                  ),
          ),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
        ],
      )),
    );
  }
}
