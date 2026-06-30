import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:sayartii/models/dtc_code_model.dart';
import 'package:sayartii/models/prediction_model.dart';
import 'package:sayartii/services/notification.dart';
import 'package:sayartii/views/notification/local_notification.dart';
import 'package:sayartii/services/prediction_sevice.dart';
import 'package:sayartii/services/api/api.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'package:sayartii/views/home/cubit/data_cubit.dart';
import 'package:sayartii/constants.dart';

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
  /// Stores the app locale (set at connection time) for notification language
  bool _isAr = false;
  /// Stores DTC details fetched from the API for notification navigation
  List<DtcCodeModel> lastDtcDetailsList = [];
  bool _isPollingParameters = false;

  bluetoothButton([DataCubit? dataCubit]) async {
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
      dataCubit?.disconnect();
      emit(BluetoothOff());
    }
  }

  connectToDevice(int index, DataCubit dataCubit,
      PredictCodesCubit predictCodesCubit, bool isAr) async {
    _isAr = isAr;
    // ✅ CRITICAL: Reset all state flags so reconnects start cleanly
    send = true;
    _isPollingParameters = false;
    emit(BluetoothConnecting());
    debugPrint("##########${obd2.connection?.isConnected.toString()}#########");
    await obd2.getConnection(devices[index], (connection) async {
      device = devices[index];
      debugPrint("connected to bluetooth device.");
      await obd2.setOnDataReceived((command, response, requestCode) {
        debugPrint("==>> $command");
        if (command == "DTC") {
          // CRITICAL FIX: Append new codes instead of overwriting.
          // The 3 DTC commands (03, 07, 0A) each return separate responses.
          // Overwriting would lose codes from earlier commands.
          List<dynamic> newCodes = json.decode(response);
          for (var code in newCodes) {
            String cleanCode = code.toString().trim().toUpperCase();
            if (cleanCode.isNotEmpty && cleanCode != "P0000" && !dtcCodes.contains(cleanCode)) {
              dtcCodes.add(cleanCode);
            }
          }
          debugPrint('[DTC] Current dtcCodes after merge: $dtcCodes');
        }
        if (command == "PARAMETER") {
          updateData(response, dataCubit, predictCodesCubit);
        }
      });
      // Initialize ELM327 device first
      int initTime = await obd2.configObdWithJSON(configJSON);
      await Future.delayed(Duration(milliseconds: initTime));
      
      // Emit BluetoothOn state for device connection status card
      emit(BluetoothOn());

      // Update DataCubit immediately so UI knows we are connected and transitions from "Please connect"
      dataCubit.updateDataBlue('speed', '0');

      // ─── Connection success notification ─────────────────────────────────
      final deviceName = devices[index].name ?? 'OBD2 Device';
      showNotification(
        isAr ? '🔗 متصل بـ OBD2' : '🔗 OBD2 Connected',
        isAr 
          ? 'سيارتي متصل الآن بـ $deviceName ويقرأ البيانات الحية.' 
          : 'Sayartii is now linked to $deviceName and reading live data.',
      );
      // ─── AUTO DTC SCAN after successful connection ───────────────────────
      // Automatically check for stored fault codes right after connecting
      _autoScanDtc(isAr);
    }, (message) {
      debugPrint("error in connecting: $message");
      buttonOn = false;
      device = null;
      send = false;
      dataCubit.disconnect();
      emit(BluetoothError(message));
      emit(BluetoothOff());
    });
  }

  /// Automatically scan for DTCs after a successful Bluetooth connection.
  /// Fires notification and fetches AI details before restarting live data.
  Future<void> _autoScanDtc(bool isAr) async {
    try {
      debugPrint('[AUTO-DTC] Starting automatic DTC scan...');
      dtcCodes = [];
      send = false;

      // Wait for any in-flight polling loop to fully exit before scanning.
      // Without this, the _isPollingParameters guard would block the restart call.
      int waited = 0;
      while (_isPollingParameters && waited < 3000) {
        await Future.delayed(const Duration(milliseconds: 100));
        waited += 100;
      }

      // Small delay to let connection settle before scanning
      await Future.delayed(const Duration(milliseconds: 500));
      await sendDtcRequiest(dtcJSON);

      // Extra wait: ensure all OBD2 response callbacks populate dtcCodes
      await Future.delayed(const Duration(milliseconds: 2000));

      debugPrint('[AUTO-DTC] Scan complete. dtcCodes=$dtcCodes');

      if (dtcCodes.isNotEmpty) {
        lastDtcDetailsList = [];
        for (var code in dtcCodes) {
          try {
            Map<String, dynamic> detailsJson =
                await Api().get(url: "$kAiUrl/dtc_code/$code");
            lastDtcDetailsList.add(DtcCodeModel.fromJson(detailsJson, isAr: isAr));
          } catch (e) {
            debugPrint('[AUTO-DTC] Failed to fetch details for $code: $e');
            lastDtcDetailsList.add(DtcCodeModel(
              dtcCode: code,
              criticalLevel: "Medium",
              description: isAr
                  ? "غير قادر على جلب الوصف — تحقق من الاتصال بالإنترنت"
                  : "Unable to fetch description — check internet connection",
            ));
          }
        }

        lastDtcDetails = List.from(lastDtcDetailsList);

        showNotification(
          isAr ? '⚠️ أعطال مكتشفة!' : '⚠️ Faults Detected!',
          isAr
              ? 'تم اكتشاف ${dtcCodes.length} عطل: ${dtcCodes.join(", ")}. اضغط لعرض التفاصيل.'
              : '${dtcCodes.length} fault(s) detected: ${dtcCodes.join(", ")}. Tap to view details.',
          payload: 'dtc_scan',
        );
      }
    } catch (e) {
      debugPrint('[AUTO-DTC] Error during auto scan: $e');
    } finally {
      // Always restart live data — whether scan succeeded or failed.
      // _isPollingParameters is guaranteed false here since we waited above.
      send = true;
      sendParameterRequiest(paramJSON);
      debugPrint('[AUTO-DTC] Live data polling restarted.');
    }
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
    if (_isPollingParameters) {
      debugPrint('[OBD2] Parameter polling is already running. Skipping duplicate call.');
      return;
    }
    _isPollingParameters = true;
    try {
      while (send) {
        try {
          await Future.delayed(
              Duration(milliseconds: await obd2.getParamsFromJSON(parameters)));
        } catch (e) {
          debugPrint('[OBD2] sendParameterRequiest error: $e');
          // Brief pause before retrying to avoid busy-spinning on persistent errors
          await Future.delayed(const Duration(seconds: 2));
          if (!send) break;
        }
      }
    } finally {
      _isPollingParameters = false;
      debugPrint('[OBD2] Parameter polling loop exited.');
    }
  }

  updateData(response, DataCubit dataCubit,
      PredictCodesCubit predictCodesCubit) async {
    List<dynamic> responseData = json.decode(response);
    String? resp;
    bool gotValidData = false;
    for (var data in responseData) {
      resp = data["response"]?.toString();
      if (resp == null || resp.isEmpty || resp == "null") {
        continue;
      }
      if (resp == "Err" || resp == "NODATA" || resp == "?") {
        // Sensor not supported by this vehicle — skip, keep last known value
        continue;
      }
      // Filter out obviously bad hex strings (non-numeric, not yet calculated)
      if (resp.length > 10 || resp.toUpperCase().contains('NO') || resp.toUpperCase().contains('UNABLE')) {
        continue;
      }
      if (resp.contains('.')) {
        try {
          resp = double.parse(resp).toStringAsFixed(1);
        } catch (e) {
          continue; // Skip non-parseable values
        }
      }

      String name = mapRespNameToRequistedData(data["title"]);
      if (name.isNotEmpty) {
        requistedData[name] = resp; // Write directly to the global map
        dataCubit.updateDataBlue(name, resp);
        gotValidData = true;
      }
    }
    // If all sensors were skipped (NODATA from all), still emit to keep UI alive
    if (!gotValidData) {
      dataCubit.updateDataBlue('speed', requistedData['speed'] ?? '0');
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
            predictNotification(predictedCodesList!, _isAr);
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
    // Only disconnect when app is fully killed — NOT when user switches apps.
    // This keeps the OBD2 connection alive during demo (e.g. opening camera/WhatsApp).
    if (state == AppLifecycleState.detached) {
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
