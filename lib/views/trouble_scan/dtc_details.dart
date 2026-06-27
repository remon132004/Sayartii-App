import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/views/connect_device/cubit/bluetooth_cubit.dart';
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
    // Try TroubleScanCubit first (manual scan), fall back to BluetoothCubit (auto-scan / notification)
    List<DtcCodeModel> dtcDetailsList =
        BlocProvider.of<TroubleScanCubit>(context).dtcDetailsList;
    
    // If the manual scan list is empty, use the auto-scan results from BluetoothCubit
    if (dtcDetailsList.isEmpty) {
      dtcDetailsList = BlocProvider.of<BluetoothCubit>(context).lastDtcDetailsList;
    }

    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryBackGroundColor,
        foregroundColor: kPrimaryDarkColor,
        title: Text(
          isAr ? "أكواد الأعطال" : "DTC Codes",
          style: const TextStyle(color: kPrimaryDarkColor, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: dtcDetailsList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, 
                    size: 64, color: kSuccessColor.withValues(alpha: 0.6)),
                  const SizedBox(height: 16),
                  Text(
                    isAr ? 'لا توجد أعطال مسجلة' : 'No Faults Recorded',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: kSecondaryTextColor,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
              child: ListView.builder(
                itemCount: dtcDetailsList.length,
                itemBuilder: (context, index) {
                  return DtcCard(
                    title: dtcDetailsList[index].description ?? "N/A",
                    code: dtcDetailsList[index].dtcCode ?? "N/A",
                    criticalLevel: dtcDetailsList[index].criticalLevel ?? "N/A",
                    icon: GestureDetector(
                      child: SizedBox(
                          width: 5.w,
                          child: const Icon(Icons.arrow_forward_ios_rounded,
                              color: kAccentColor)),
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
              ),
            ),
    );
  }
}
