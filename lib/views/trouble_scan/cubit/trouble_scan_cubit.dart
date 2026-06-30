import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/services/api/api.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'package:sayartii/views/notification/local_notification.dart';

import '../../../models/dtc_code_model.dart';

part 'trouble_scan_state.dart';

class TroubleScanCubit extends Cubit<TroubleScanState> {
  TroubleScanCubit() : super(TroubleScanInitial());
  List<DtcCodeModel> dtcDetailsList = [];
  initialState() {
    if (dtcCodes.isEmpty) {
      emit(TroubleScanInitial());
    }
  }

  buttonPressed({bool isAr = false}) async {
    emit(RequistDtc());
    dtcDetailsList.clear();

    for (int i = 0; i < dtcCodes.length; i++) {
      debugPrint(dtcCodes[i]);
      try {
        Map<String, dynamic> detailsJson =
            await Api().get(url: "$kAiUrl/dtc_code/${dtcCodes[i]}");
        DtcCodeModel details = DtcCodeModel.fromJson(detailsJson, isAr: isAr);
        dtcDetailsList.add(details);
      } catch (e) {
        debugPrint('[MANUAL-DTC] Failed to fetch details for ${dtcCodes[i]}: $e');
        dtcDetailsList.add(DtcCodeModel(
          dtcCode: dtcCodes[i],
          criticalLevel: "Medium",
          description: isAr ? "غير قادر على جلب الوصف (فشل الاتصال بالسيرفر)" : "Unable to fetch description (Server Error)",
        ));
      }
    }
    await Future.delayed(const Duration(milliseconds: 1500));

    // Sync to global cache so notification tap can access without BlocProvider
    lastDtcDetails = List.from(dtcDetailsList);

    if (dtcCodes.isEmpty) {
      emit(DtcResultNeg());
    } else {
      emit(DtcResultPos());
      // Send notification when faults are found via manual scan
      showNotification(
        isAr ? '⚠️ أعطال مكتشفة!' : '⚠️ Faults Detected!',
        isAr
          ? 'تم اكتشاف ${dtcCodes.length} عطل: ${dtcCodes.join(", ")}'
          : '${dtcCodes.length} fault(s) found: ${dtcCodes.join(", ")}',
        payload: 'dtc_scan',
      );
    }
  }
}
