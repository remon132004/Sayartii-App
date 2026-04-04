import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayartii/services/api/api.dart';
import 'package:sayartii/utils/initialize_car_data.dart';

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
      print(dtcCodes[i]);
      Map<String, dynamic> detailsJson =
          await Api().get(url: "https://ai.sayartii.live/dtc_code/${dtcCodes[i]}");
      DtcCodeModel details = DtcCodeModel.fromJson(detailsJson);
      // await Api().get(url: "https://ai.sayartii.live/dtc_code/$code");
      dtcDetailsList.add(details);
    }
    await Future.delayed(Duration(milliseconds: 1500));

    if (dtcCodes.isEmpty) {
      emit(DtcResultNeg());
    } else {
      emit(DtcResultPos());
    }
  }
}
