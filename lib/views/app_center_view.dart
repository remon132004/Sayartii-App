import 'package:flutter/material.dart';
import 'package:sayartii/views/in_depth_check_view.dart';
import 'package:sayartii/views/live_data_view.dart';
import 'package:sayartii/views/trouble_scan/trouble_scan.dart';
import 'package:sayartii/widgets/app_center_container.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'predicted_codes/predicted_codes.dart';

class AppCenterView extends StatelessWidget {
  AppCenterView({super.key});


  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> containerData = [
      {
        'name': AppLocalizations.of(context)!.predictedIssues,
        'image': "assets/icons/comp_test.svg",
        "rout": const PredictedCodes()
      },
      {
        'name': AppLocalizations.of(context)!.liveData,
        'image': "assets/icons/live_data2.svg",
        "rout": const LiveData()
      },
      {
        'name': AppLocalizations.of(context)!.troubleScan,
        'image': "assets/icons/trouble_scan2.svg",
        "rout": const TroubleScan()
      },
      {
        'name': AppLocalizations.of(context)!.inDepthCheck,
        'image': "assets/icons/in_depth2.svg",
        "rout": const InDepthCheckView()
      },
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.applicationCenterTitle,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
          child: Column(
            children: [
              AppCenterContainer(
                isTap: false,
                isSvg: false,
                image: 'assets/images/center_car.png',
                lable: "",
                imgSize: 18,
                hight: 25.1.h,
                width: double.maxFinite,
              ),
              SizedBox(
                height: 3.h,
              ),
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.myTools,
                    style: TextStyle(
                      color: const Color(0xff042877),
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 3.h,
              ),
              GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 25),
                  itemCount: containerData.length,
                  itemBuilder: (context, index) {
                    return AppCenterContainer(
                      rout: containerData[index]['rout'],
                      image: containerData[index]['image']!,
                      lable: containerData[index]['name']!,
                      imgSize: 8,
                      hight: 15.h,
                      width: 40.w,
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
