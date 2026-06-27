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

  buttonPressed() async {
    emit(RequistDtc());

    for (int i = 0; i < dtcCodes.length; i++) {
      debugPrint(dtcCodes[i]);
      Map<String, dynamic> detailsJson =
          await Api().get(url: "$kAiUrl/dtc_code/${dtcCodes[i]}");
      DtcCodeModel details = DtcCodeModel.fromJson(detailsJson);
      // await Api().get(url: "$kAiUrl/dtc_code/$code");
      dtcDetailsList.add(details);
    }
    await Future.delayed(Duration(milliseconds: 1500));

    if (dtcCodes.isEmpty) {
      emit(DtcResultNeg());
    } else {
      emit(DtcResultPos());
      // Send notification when faults are found via manual scan
      showNotification(
        '⚠️ أعطال مكتشفة!',
        'تم اكتشاف ${dtcCodes.length} عطل: ${dtcCodes.join(", ")}',
        payload: 'dtc_scan',
      );
    }
  }
}
