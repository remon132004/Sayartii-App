import 'dart:convert';
import 'dart:ffi';

import 'package:sayartii/services/api/api.dart';

import '../models/prediction_model.dart';

class PredictService {
  Future<dynamic> predict(
      {required double engine_power,
      required double engine_coolant_temp,
      required double engine_load,
      required double engine_rpm,
      required double air_intake_temp,
      required double speed,
      required double short_term_fuel_trim,
      required double throttle_pos,
      required double timing_advance}) async {
    Map<String, dynamic> data =
        await Api().post(url: "http://54.236.94.229:5050/predict", body:jsonEncode({
      "engine_power": engine_power,
      "engine_coolant_temp": engine_coolant_temp,
      "engine_load": engine_load,
      "engine_rpm": engine_rpm,
      "air_intake_temp": air_intake_temp,
      "speed": speed,
      "short_term_fuel_trim": short_term_fuel_trim,
      "throttle_pos": throttle_pos,
      "timing_advance": timing_advance
    }));

    return PredictionModel.fromJson(data);
  }

  
}
