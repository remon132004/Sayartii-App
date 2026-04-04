import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'package:sayartii/views/notification/local_notification.dart';

Future<void> predictNotification() async {
  String url = 'http://54.236.94.229:5050/predict';
  Map<String, dynamic> data = {
    "engine_power": requistedData["enginePower"],
    "engine_coolant_temp": requistedData["engineCoolantTemp"],
    "engine_load": requistedData["engineLoad"],
    "engine_rpm": requistedData["engineRPM"],
    "air_intake_temp": requistedData["airintakeTemp"],
    "speed": requistedData["speed"],
    "short_term_fuel_trim": requistedData["shortTermFuelBank1"],
    "throttle_pos": requistedData["throttlePosition"],
    "timing_advance": requistedData["timingAdvance"]
  };

  try {
    debugPrint('Sending request to $url with data: $data');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data), // Use the json.encode method from dart:convert
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(
          response.body); // Use the json.decode method from dart:convert
      debugPrint('Response received: $responseData');
      var prediction = responseData['prediction'];
      var troubleCode = responseData['trouble_code'];

      debugPrint('Prediction: $prediction, Code: $troubleCode');

      if (prediction == 'Problem Detected') {
        showNotification('Issue Detected',
            'Your car reports a problem: $troubleCode. Check the app for details.');
      }
    } else {
      debugPrint('Failed to get prediction: ${response.statusCode}');
      debugPrint('Response data: ${response.body}');
    }
  } catch (e) {
    debugPrint('Error: $e');
  }
}
