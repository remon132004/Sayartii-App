import 'package:flutter/material.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/models/dtc_code_model.dart';
import 'package:sayartii/widgets/dtc_card.dart';
import 'package:sizer/sizer.dart';

class CodeDescription extends StatelessWidget {
  const CodeDescription({super.key, required this.codeDesc});
  final DtcCodeModel codeDesc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryBackGroundColor,
        foregroundColor: kPrimaryDarkColor,
        title: const Text(
          "Code Description",
          style: TextStyle(color: kPrimaryDarkColor, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DtcCard(
              code: codeDesc.dtcCode ?? "N/A",
              title: codeDesc.description ?? "N/A",
              criticalLevel: codeDesc.criticalLevel ?? "N/A",
            ),
            _textPara(header: "Code description", body: codeDesc.longDescription),
            _textPara(header: "Reasons for fault", body: codeDesc.reason),
            _textPara(header: "Repairing suggestions", body: codeDesc.repair),
          ],
        ),
      ),
    );
  }

  Widget _textPara({required String header, required String? body}) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: glassDecoration(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              color: kAccentColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body ?? "N/A",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: kSecondaryTextColor,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}
