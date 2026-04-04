import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:meta/meta.dart';
import 'package:sayartii/models/prediction_model.dart';
import 'package:sayartii/services/notification.dart';
import 'package:sayartii/services/prediction_sevice.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'package:sayartii/views/home/cubit/data_cubit.dart';

import '../../../services/bluetooth/obd2_plugin.dart';
import '../../predicted_codes/cubit/predict_codes_cubit.dart';

part 'bluetooth_state.dart';

class BluetoothCubit extends Cubit<BluetoothState> {
  BluetoothCubit() : super(BluetoothInitial());
  bool buttonOn = false;
  final obd2 = Obd2Plugin();
  List<BluetoothDevice> devices = [];
  BluetoothDevice? device;
  bool send = true;
  bool predict = false;
  int count = 0;
  List<String> codes = [];

  bluetoothButton() async {
    if (!buttonOn) {
      buttonOn = !buttonOn;
      obd2.permitions;
      if (!(await obd2.isBluetoothEnable)) {
        await obd2.enableBluetooth;
      }
      if (!(await obd2.hasConnection)) {
        emit(WaitingForDevices()); // أظهر اللودينج للمستخدم أثناء البحث
        devices = await obd2.getNearbyAndPairedDevices; // ابحث بجدية في المكان
        if (devices.isNotEmpty) {
          emit(ShowBluetoothList(devices));
        } else {
          buttonOn = false; // إيقاف الزر إذا لم يجد شيئاً
          emit(BluetoothOff()); // أوقف اللودينج وأعد الزر كما كان
        }
      }
    } else {
      buttonOn = !buttonOn;
      device = null;
      send = false;
      obd2.disconnect();
      emit(BluetoothOff());
    }
  }

  connectToDevice(int index, DataCubit dataCubit,
      PredictCodesCubit predictCodesCubit) async {
    debugPrint("##########${obd2.connection?.isConnected.toString()}#########");
    await obd2.getConnection(devices[index], (connection) async {
      device = devices[index];
      debugPrint("connected to bluetooth device.");
      await obd2.setOnDataReceived((command, response, requestCode) {
        debugPrint("==>> $command");
        if (command == "DTC") {
          dtcCodes = json.decode(response);
          //dtcCodes = ["P0111", "P0327"];
        }
        if (command == "PARAMETER") {
          updateData(response, dataCubit, predictCodesCubit);
        }
      });
      sendParameterRequiest(paramJSON);
      emit(BluetoothOn());
    }, (message) {
      debugPrint("error in connecting: $message");
    });
  }

  Future<int> sendDtcRequiest(parameters) async {
    int delayTime = await obd2.getDTCFromJSON(parameters);

    await Future.delayed(Duration(milliseconds: delayTime), () {});
    return delayTime;
  }

  sendfreezeFrameRequiest(parameters) async {
    await Future.delayed(
        Duration(milliseconds: await obd2.getDTCFromJSON(parameters)), () {});
  }

  sendParameterRequiest(parameters) async {
    while (send) {
      await Future.delayed(
          Duration(milliseconds: await obd2.getParamsFromJSON(parameters)),
          () {});
    }
  }

  updateData(response, DataCubit dataCubit,
      PredictCodesCubit predictCodesCubit) async {
    List<dynamic> responseData = json.decode(response);
    String resp;
    for (var data in responseData) {
      resp = data["response"];
      if (resp == "0.0") {
        continue;
      }
      if (resp.contains('.')) {
        resp = double.parse(resp).toStringAsFixed(1);
      }

      String name = mapRespNameToRequistedData(data["title"]),
          value = resp; //+ data["unit"]
      dataCubit.updateDataBlue(name, value);
    }
    if (predict) {
      debugPrint("=--=-=---=-=-=-=-=-$count");
      if (count == 6) {
        PredictionModel predictionRsp = await PredictService().predict(
          engine_power:
              double.parse(requistedData[mapDataToApi('engine_power')]),
          engine_coolant_temp:
              double.parse(requistedData[mapDataToApi('engine_coolant_temp')]),
          engine_load: double.parse(requistedData[mapDataToApi('engine_load')]),
          engine_rpm: double.parse(requistedData[mapDataToApi('engine_rpm')]),
          air_intake_temp:
              double.parse(requistedData[mapDataToApi('air_intake_temp')]),
          speed: double.parse(requistedData[mapDataToApi('speed')]),
          short_term_fuel_trim:
              double.parse(requistedData[mapDataToApi('short_term_fuel_trim')]),
          throttle_pos:
              double.parse(requistedData[mapDataToApi('throttle_pos')]),
          timing_advance:
              double.parse(requistedData[mapDataToApi('timing_advance')]),
        );
        predictedCodesList = predictionRsp;
               debugPrint(predictionRsp.toString());
        debugPrint(predictionRsp.toString());

        // Track the current trouble code if not empty
        bool comp =
             predictedCodesList!.troubleCode == null || codes.contains(predictedCodesList!.troubleCode!);
        if (predict &&
            predictedCodesList!.prediction == "Problem Detected" &&
            comp == false) {
          predictNotification();
          codes.add(predictedCodesList!.troubleCode!);
        }
        // predictCodesCubit.pageState();
        count = 0;
      } else {
        count += 1;
      }
    }
  }

  String mapRespNameToRequistedData(String name) {
    switch (name) {
      case 'Engine Coolant Temp':
        return 'engineCoolantTemp';
      case 'Engine Load':
        return 'engineLoad';
      case 'Engine RPM':
        return 'engineRPM';
      case 'Air Intake Temp':
        return 'airintakeTemp';
      case 'Speed':
        return 'speed';
      case 'Short Term Fuel Bank':
        return 'shortTermFuelBank1';
      case 'Throttle Position':
        return 'throttlePosition';
      case 'Timing Advance':
        return 'timingAdvance';
    }

    return "";
  }

  String mapDataToApi(String name) {
    switch (name) {
      case 'engine_power':
        return 'enginePower';
      case 'engine_coolant_temp':
        return 'engineCoolantTemp';
      case 'engine_load':
        return 'engineLoad';
      case 'engine_rpm':
        return 'engineRPM';
      case 'air_intake_temp':
        return 'airintakeTemp';
      case 'speed':
        return 'speed';
      case 'short_term_fuel_trim':
        return 'shortTermFuelBank1';
      case 'throttle_pos':
        return 'throttlePosition';
      case 'timing_advance':
        return 'timingAdvance'; // Corrected this line
      default:
        return "";
    }
  }
}
