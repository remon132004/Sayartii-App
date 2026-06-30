import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'package:sayartii/views/notification/local_notification.dart';
import 'package:sayartii/constants.dart';

import 'package:sayartii/models/prediction_model.dart';

Future<void> predictNotification(PredictionModel predictionRsp, bool isAr) async {
  if (predictionRsp.prediction == 'Problem Detected') {
    String troubleCode = predictionRsp.troubleCode ?? 'Unknown';
    String desc = '';
    
    if (predictionRsp.openAiResponse != null && predictionRsp.openAiResponse is Map) {
      desc = isAr 
        ? predictionRsp.openAiResponse['description_ar']?.toString() ?? ''
        : predictionRsp.openAiResponse['description_en']?.toString() ?? '';
    }

    showNotification(
      isAr ? '⚠️ تنبيه مبكر: عطل وشيك' : '⚠️ Early Warning: Issue Predicted',
      isAr 
        ? 'تشير الحساسات لاحتمالية حدوث عطل $troubleCode قريباً. $desc'
        : 'Sensors indicate a high probability of fault $troubleCode. $desc',
      payload: 'prediction',
    );
  }
}
