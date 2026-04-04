import 'package:flutter/material.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'package:sayartii/widgets/dtc_card.dart';

class PredictedCodeDescription extends StatelessWidget {
  const PredictedCodeDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Code description"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DtcCard(
                title: predictedCodesList?.prediction ?? 'Unknown',
                code: predictedCodesList?.troubleCode ?? 'None',
                criticalLevel: "High",
              ),
              textPara(
                  header: "Estimated hours to failure", 
                  body: predictedCodesList?.estimatedTimeRemaining?.toString() ?? "Wait for update"),
              textPara(
                  header: "OpenAI GPT-4o Detailed Response", 
                  body: predictedCodesList?.openAiResponse ?? "No data from AI."),
            ],
          ),
        ),
      ),
    );
  }

  Widget textPara({required String header, required String? body}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child:
              Text(header, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Text(
          body ?? "N/A",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }
}
