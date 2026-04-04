import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'package:sayartii/views/trouble_scan/code_description.dart';
import 'package:sayartii/views/trouble_scan/cubit/trouble_scan_cubit.dart';
import 'package:sizer/sizer.dart';

import '../../models/dtc_code_model.dart';
import '../../widgets/dtc_card.dart';

class DtcDetailsScreen extends StatefulWidget {
  const DtcDetailsScreen({super.key});

  @override
  State<DtcDetailsScreen> createState() => _DtcDetailsScreenState();
}

class _DtcDetailsScreenState extends State<DtcDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    List<DtcCodeModel> dtcDetailsList =
        BlocProvider.of<TroubleScanCubit>(context).dtcDetailsList;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dtc Codes"),
        centerTitle: true,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: ListView.builder(
            itemCount: dtcCodes.length,
            itemBuilder: (context, index) {
              return DtcCard(
                title: dtcDetailsList[index].description ?? "N/A",
                code: dtcDetailsList[index].dtcCode ?? "N/A",
                criticalLevel: dtcDetailsList[index].criticalLevel ?? "N/A",
                icon: GestureDetector(
                  child: SizedBox(
                      width: 5.w,
                      child: const Icon(Icons.arrow_forward_ios_rounded)),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CodeDescription(codeDesc: dtcDetailsList[index]),
                        ));
                  },
                ),
              );
            },
          )),
    );
  }
}
