import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.onPressed,
      required this.title,
      required this.color,
      this.width = 59});
  final String title;
  final Color color;
  final int width;
  final Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 5.h,
      width: width.w,
      child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
              //surfaceTintColor: MaterialStateProperty.all(color),
              backgroundColor: MaterialStatePropertyAll(color),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)))),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          )),
    );
  }
}
