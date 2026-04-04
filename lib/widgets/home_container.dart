import 'package:flutter/material.dart';
import 'package:sayartii/constants.dart';
import 'package:sizer/sizer.dart';

class HomeContainer extends StatefulWidget {
  const HomeContainer(
      {super.key,
      required this.data,
      required this.text1,
      required this.text2,
      required this.text3});
  final String data, text1, text2, text3;

  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: boxDecoration(),
        height: 19.h,
        width: 43.w,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data + widget.text1,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(
                height: 1.h,
              ),
              Text(
                widget.text2,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(
                height: 1.h,
              ),
              Text(
                widget.text3,
                style: TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              )
            ],
          ),
        ));
  }
}
