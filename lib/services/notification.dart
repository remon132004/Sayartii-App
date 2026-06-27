import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'package:sayartii/views/notification/local_notification.dart';
import 'package:sayartii/constants.dart';

double _toDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is double) return val;
  if (val is int) return val.toDouble();
  return double.tryParse(val.toString()) ?? 0.0;
}

Future<void> predictNotification() async {
  // Skip prediction if not connected to car (all values still 0)
  final rpm = _toDouble(requistedData["engineRPM"]);
  final speed = _toDouble(requistedData["speed"]);
  final coolant = _toDouble(requistedData["engineCoolantTemp"]);
  if (rpm == 0 && speed == 0 && coolant == 0) {
    debugPrint('predictNotification: skipped — no car data available yet.');
    return;
  }

  // enginePower: estimated from RPM and engine load (PID not directly available)
  final engineLoad = _toDouble(requistedData["engineLoad"]);
  final estimatedEnginePower = (rpm * engineLoad) / 5000.0;

  String url = '$kAiUrl/predict';
  Map<String, dynamic> data = {
    "engine_power": estimatedEnginePower,
    "engine_coolant_temp": coolant,
    "engine_load": engineLoad,
    "engine_rpm": rpm,
    "air_intake_temp": _toDouble(requistedData["airintakeTemp"]),
    "speed": speed,
    "short_term_fuel_trim": _toDouble(requistedData["shortTermFuelBank1"]),
    "throttle_pos": _toDouble(requistedData["throttlePosition"]),
    "timing_advance": _toDouble(requistedData["timingAdvance"]),
  };

  try {
    debugPrint('Sending prediction request to $url with data: $data');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      debugPrint('Prediction response: $responseData');
      var prediction = responseData['prediction'];
      var troubleCode = responseData['trouble_code'];

      debugPrint('Prediction: $prediction, Code: $troubleCode');

      if (prediction == 'Problem Detected') {
        showNotification(
          'Issue Detected 🚗',
          'Your car may have a problem: $troubleCode. Open Sayartii for details.',
          payload: 'prediction',
        );
      }
    } else {
      debugPrint('Prediction failed: ${response.statusCode} — ${response.body}');
    }
  } catch (e) {
    debugPrint('predictNotification error: $e');
  }
}
