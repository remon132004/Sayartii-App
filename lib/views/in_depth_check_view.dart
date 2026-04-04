import 'package:flutter/material.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:sayartii/constants.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InDepthCheckView extends StatelessWidget {
  const InDepthCheckView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l.inDepthCheckTitle,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.sp),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/in_depth.svg',
                height: 18.h,
                colorFilter: ColorFilter.mode(
                  kPrimaryBlueColor.withOpacity(0.5),
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                l.inDepthCheckTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                  color: kPrimaryBlueColor,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                l.inDepthCheckSoon,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
