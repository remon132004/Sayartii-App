import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:sayartii/cubit/language_cubit.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/utils/login_helper.dart';
import 'package:sayartii/widgets/custom_button.dart';
import 'package:sizer/sizer.dart';
import 'package:sayartii/views/registertion/storeToken.dart';
import 'package:sayartii/views/registertion/login_package.dart';

import 'connect_device/cubit/bluetooth_cubit.dart';

class MyInfoView extends StatefulWidget {
  
  MyInfoView({super.key});

  @override
  State<MyInfoView> createState() => _MyInfoViewState();
}

class _MyInfoViewState extends State<MyInfoView> {
 

  bool status = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 25.h,
            width: double.maxFinite,
            child: SvgPicture.asset(
              'assets/images/info_app_bar.svg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 4.h,
                ),
                Container(
                  height: 13.h,
                  width: 22.w,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xffcfdcfd),
                        Color(0xff5985f9),
                      ],
                    ),
                    //  color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    "assets/images/app_icon.png",
                    fit: BoxFit.contain,
                    // width: 23.w,
                  ),
                ),
                Container(
                  height: 15.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xffd7e2ff),
                        Color(0xffffffff),
                      ],
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: const Color(0xff042877), width: 0.3.sp),
                    boxShadow: [boxShadow()],
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/info_car.png",
                        width: 45.w,
                      ),
                      Text(
                        AppLocalizations.of(context)!.carName,
                        style: TextStyle(
                          fontFamily: "inter",
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Container(
                    // height: 30.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/icons/forecast.png",
                                height: 4.h,
                              ),
                              SizedBox(width: 4.5.w),
                              Text(
                                AppLocalizations.of(context)!.startPrediction,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                ),
                              ),
                              const Spacer(
                                flex: 1,
                              ),
                              FlutterSwitch(
                                activeColor: kPrimaryBlueColor,
                                width: 65,
                                height: 30,
                                valueFontSize: 15.0,
                                toggleSize: 18.0,
                                value: status,
                                borderRadius: 15.0,
                                padding: 4.0,
                                showOnOff: true,
                                onToggle: (val) {
                                  setState(() {
                                    //predictIssue();
                                    status = val;
                                       status = val;
                                    if (status) {
                                      BlocProvider.of<BluetoothCubit>(context)
                                          .predict = true;
                                    } else {
                                      BlocProvider.of<BluetoothCubit>(context)
                                          .predict = false;
                                    }
                                  
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.language, size: 8.w),
                          title: Text(AppLocalizations.of(context)!.changeLanguage),
                          trailing: GestureDetector(
                            onTap: () {
                              context.read<LanguageCubit>().toggleLanguage();
                            },
                            child: const Icon(Icons.swap_horiz_rounded),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.info_outline_rounded, size: 8.w),
                          title: Text(AppLocalizations.of(context)!.aboutUs),
                          trailing: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  surfaceTintColor: Colors.white,
                                  backgroundColor: Colors.white,
                                  title: Text(AppLocalizations.of(ctx)!.aboutUsTitle),
                                  content: Text(AppLocalizations.of(ctx)!.aboutUsDesc),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: Text(AppLocalizations.of(ctx)!.backBtn),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Icon(Icons.arrow_forward_ios_sharp),
                          ),
                        ),
                      ],
                    )),
                SizedBox(
                  height: 5.h,
                ),
                GestureDetector(
                  onTap: () {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        surfaceTintColor: Colors.white,
                        backgroundColor: Colors.white,
                        title: Text(AppLocalizations.of(context)!.logOut),
                        actionsOverflowButtonSpacing: 10,
                        actions: [
                          CustomButton(
                            onPressed: () async {
                              await deleteAccessToken();
                              await Helper.saveUserLoggedInSharedPreference(false);
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  (route) => false,
                                );
                              }
                            },
                            title: AppLocalizations.of(context)!.continueBtn,
                            color: kPrimaryBlueColor,
                            width: 32,
                          ),
                          CustomButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            title: AppLocalizations.of(context)!.backBtn,
                            color: kPrimaryBlueColor,
                            width: 25,
                          ),
                        ],
                        content:
                            Text(AppLocalizations.of(context)!.areYouSureLogOut),
                      ),
                    );
                  },
                  child: Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kPrimaryBlueColor, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                          child: Text(
                        AppLocalizations.of(context)!.logOut,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          color: kPrimaryBlueColor,
                        ),
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget customTile(
  //     {required icon1, required title, required icon2, nav, context}) {
  //   return ListTile(
  //     leading: Image.asset(icon1),
  //     title: Text(title),
  //     trailing: GestureDetector(
  //       onTap: () => Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => nav)),
  //       child: Icon(icon2),
  //     ),
  //   );
  // }
}