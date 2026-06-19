import 'package:flutter/material.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'package:sayartii/widgets/dtc_card.dart';
import 'package:sizer/sizer.dart';

class PredictedCodeDescription extends StatelessWidget {
  const PredictedCodeDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryBackGroundColor,
        foregroundColor: kPrimaryDarkColor,
        title: const Text(
          "AI Diagnosis Report",
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
              title: predictedCodesList?.prediction ?? 'Unknown',
              code: predictedCodesList?.troubleCode ?? 'None',
              criticalLevel: "High",
            ),
            _textPara(
                header: "Estimated hours to failure",
                body: predictedCodesList?.estimatedTimeRemaining?.toString() ??
                    "Wait for update"),
            _textPara(
                header: "OpenAI GPT-4o Detailed Response",
                body: predictedCodesList?.openAiResponse ?? "No data from AI."),
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
