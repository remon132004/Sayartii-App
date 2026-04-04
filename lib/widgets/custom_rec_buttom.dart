import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomRecButton extends StatelessWidget {
  const CustomRecButton(
      {super.key,
      required this.outerColor,
      required this.inerColor,
      required this.child, required this.onTap});

  final Widget child;
  final Color outerColor;
  final Color inerColor;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            gradient: RadialGradient(
              colors: [inerColor, outerColor],
              radius: 9.0,
            ),
            // border: Border.all(color: kPrimaryBlueColor, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
            // style: TextStyle(
            //   fontWeight: FontWeight.w600,
            //   fontSize: 12.sp,
            //   color: Colors.white,
            // ),
          )),
    );
  }
}
