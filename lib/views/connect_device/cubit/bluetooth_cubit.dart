import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:sayartii/models/prediction_model.dart';
import 'package:sayartii/services/notification.dart';
import 'package:sayartii/views/notification/local_notification.dart';
import 'package:sayartii/services/prediction_sevice.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'package:sayartii/views/home/cubit/data_cubit.dart';

import '../../../services/bluetooth/obd2_plugin.dart';
import '../../predicted_codes/cubit/predict_codes_cubit.dart';

part 'bluetooth_state.dart';

class BluetoothCubit extends Cubit<BluetoothState> with WidgetsBindingObserver {
  BluetoothCubit() : super(BluetoothInitial()) {
    WidgetsBinding.instance.addObserver(this);
  }
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
        
        // OPTIMIZATION: Fetch only paired devices to avoid 12-second discovery delay.
        // OBD2 adapters (like ELM327) must be paired in Android settings first anyway.
        devices = await obd2.getPairedDevices; 
        
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
      resetComputedMetrics();
      emit(BluetoothOff());
    }
  }

  connectToDevice(int index, DataCubit dataCubit,
      PredictCodesCubit predictCodesCubit) async {
    emit(BluetoothConnecting());
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
      // ─── Connection success notification ─────────────────────────────────
      final deviceName = devices[index].name ?? 'OBD2 Device';
      showNotification(
        '🔗 OBD2 Connected',
        'Sayartii is now linked to $deviceName and reading live data.',
      );
    }, (message) {
      debugPrint("error in connecting: $message");
      emit(BluetoothError(message));
      emit(BluetoothOff());
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
    String? resp;
    for (var data in responseData) {
      resp = data["response"]?.toString();
      if (resp == null || resp.isEmpty || resp == "null") {
        continue;
      }
      if (resp.contains('.')) {
        try {
          resp = double.parse(resp).toStringAsFixed(1);
        } catch (e) {
          // ignore parsing error
        }
      }

      String name = mapRespNameToRequistedData(data["title"]);
      if (name.isNotEmpty) {
        dataCubit.updateDataBlue(name, resp);
      }
    }

    // Update computed metrics (mileage + avg fuel) after each data cycle
    final speedKmh =
        double.tryParse(requistedData['speed']?.toString() ?? '0') ?? 0.0;
    final fuelTrim =
        double.tryParse(requistedData['shortTermFuelBank1']?.toString() ?? '0') ?? 0.0;
    updateComputedMetrics(speedKmh, fuelTrim);
    // Emit to refresh cards
    dataCubit.updateDataBlue('mileage', requistedData['mileage']);
    dataCubit.updateDataBlue('avgFuel', requistedData['avgFuel']);

    if (predict) {
      debugPrint("=--=-=---=-=-=-=-=-$count");
      if (count == 6) {
        try {
          PredictionModel predictionRsp = await PredictService().predict(
            engine_power:
                double.tryParse(requistedData[mapDataToApi('engine_power')]?.toString() ?? '0') ?? 0.0,
            engine_coolant_temp:
                double.tryParse(requistedData[mapDataToApi('engine_coolant_temp')]?.toString() ?? '0') ?? 0.0,
            engine_load:
                double.tryParse(requistedData[mapDataToApi('engine_load')]?.toString() ?? '0') ?? 0.0,
            engine_rpm:
                double.tryParse(requistedData[mapDataToApi('engine_rpm')]?.toString() ?? '0') ?? 0.0,
            air_intake_temp:
                double.tryParse(requistedData[mapDataToApi('air_intake_temp')]?.toString() ?? '0') ?? 0.0,
            speed:
                double.tryParse(requistedData[mapDataToApi('speed')]?.toString() ?? '0') ?? 0.0,
            short_term_fuel_trim:
                double.tryParse(requistedData[mapDataToApi('short_term_fuel_trim')]?.toString() ?? '0') ?? 0.0,
            throttle_pos:
                double.tryParse(requistedData[mapDataToApi('throttle_pos')]?.toString() ?? '0') ?? 0.0,
            timing_advance:
                double.tryParse(requistedData[mapDataToApi('timing_advance')]?.toString() ?? '0') ?? 0.0,
          );
          predictedCodesList = predictionRsp;
          debugPrint(predictionRsp.toString());

          // Track the current trouble code if not empty
          bool comp = predictedCodesList!.troubleCode == null ||
              codes.contains(predictedCodesList!.troubleCode!);
          if (predict &&
              predictedCodesList!.prediction == "Problem Detected" &&
              comp == false) {
            predictNotification();
            codes.add(predictedCodesList!.troubleCode!);
          }
        } catch (e) {
          debugPrint("Prediction error: $e");
          emit(BluetoothError("Prediction API Error: $e"));
          emit(BluetoothOn()); // Resume UI state
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
      case 'Short Term Fuel Bank 1':
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      obd2.disconnect();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    obd2.disconnect();
    return super.close();
  }
}
