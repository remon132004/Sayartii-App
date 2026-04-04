import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sayartii/utils/initialize_car_data.dart';

part 'predict_codes_state.dart';

class PredictCodesCubit extends Cubit<PredictCodesState> {
  PredictCodesCubit() : super(PredictCodesInitial());
  pageState() {
    //debugPrint((predictedCodesList != null).toString());
    if (predictedCodesList != null && predictedCodesList!.troubleCode != null) {
      emit(ShowPredictedCodes());
    } else {
      emit(NoPrediction());
    }
  }
}
