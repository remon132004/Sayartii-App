import 'package:flutter/material.dart';
import 'package:sayartii/models/dtc_code_model.dart';
import 'package:sayartii/widgets/dtc_card.dart';

class CodeDescription extends StatelessWidget {
  const CodeDescription({super.key, required this.codeDesc});
  final DtcCodeModel codeDesc;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Code description"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        child: Column(
          children: [
            DtcCard(
              code: codeDesc.dtcCode ?? "N/A",
              title: codeDesc.description ?? "N/A",
              criticalLevel: codeDesc.criticalLevel ?? "N/A",
            ),
            textPara(
                header: "Code description", body: codeDesc.longDescription),
            textPara(header: "Reasons for fault", body: codeDesc.reason),
            textPara(header: "Repairing suggestions", body: codeDesc.repair),
          ],
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
