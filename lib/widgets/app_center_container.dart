import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/views/predicted_codes/cubit/predict_codes_cubit.dart';
import 'package:sizer/sizer.dart';

class AppCenterContainer extends StatelessWidget {
  const AppCenterContainer(
      {super.key,
      required this.image,
      required this.lable,
      required this.imgSize,
      required this.hight,
      required this.width,
      this.isSvg = true,
      this.isTap = true,
      this.rout});
  final String image;
  final String lable;
  final int imgSize;
  final double hight;
  final double width;
  final bool isSvg;
  final bool isTap;
  final Widget? rout;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isTap) {
          if (lable == "Predicted issues") {
            BlocProvider.of<PredictCodesCubit>(context).pageState();
          }
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => rout!));
        }
      },
      child: Container(
        height: hight,
        width: width,
        decoration: boxDecoration(radius: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: imgSize.h,
              width: double.infinity,
              child: isSvg
                  ? SvgPicture.asset(
                      image,
                      // fit: BoxFit.cover,
                    )
                  : Image.asset(
                      image,
                      // fit: BoxFit.cover,
                    ),
            ),
            Text(
              lable,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
