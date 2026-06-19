import 'dart:io';
import 'dart:typed_data';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'dart:async';
import '../views/home/cubit/data_cubit.dart'; // Import required for Completer

String lastSentMessage = '';
Socket? socket;

Future<Socket> connectToServer({required String ip, required int port}) async {
  try {
    ConnectionTask<Socket> socketConnectionTask =
        await Socket.startConnect(ip, port);
    socket = await socketConnectionTask.socket;
    print(
        'Connected to: ${socket!.remoteAddress.address}:${socket!.remotePort}');
  } on SocketException catch (e) {
    print('SocketException: $e');
  } catch (e) {
    print('General exception: $e');
  }
  return socket!;
}

String parseObdValue(String pid, String hexValue) {
  // Clean up hexValue by removing spaces and non-hex chars
  String cleanHex = hexValue.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
  if (cleanHex.isEmpty) return '0';

  // Split cleanHex into 2-character bytes
  List<int> bytes = [];
  for (int i = 0; i < cleanHex.length; i += 2) {
    if (i + 2 <= cleanHex.length) {
      String byteStr = cleanHex.substring(i, i + 2);
      int? val = int.tryParse(byteStr, radix: 16);
      if (val != null) {
        bytes.add(val);
      }
    }
  }

  if (bytes.isEmpty) return '0';

  try {
    switch (pid) {
      case '05': // Engine Coolant Temp: [0] - 40
        return (bytes[0] - 40).toString();
      case '04': // Engine Load: [0] * 100 / 255
        return ((bytes[0] * 100) / 255).toStringAsFixed(1);
      case '0C': // Engine RPM: (( [0] * 256) + [1] ) / 4
        if (bytes.length >= 2) {
          return (((bytes[0] * 256) + bytes[1]) / 4).toStringAsFixed(1);
        }
        break;
      case '0F': // Air Intake Temp: [0] - 40
        return (bytes[0] - 40).toString();
      case '0D': // Speed: [0]
        return bytes[0].toString();
      case '06': // Short Term Fuel Bank 1: ([0] - 128) * 100 / 128
        return (((bytes[0] - 128) * 100) / 128).toStringAsFixed(1);
      case '11': // Throttle Position: [0] * 100 / 255
        return ((bytes[0] * 100) / 255).toStringAsFixed(1);
      case '0E': // Timing Advance: ([0] - 128) * 0.5
        return ((bytes[0] - 128) * 0.5).toStringAsFixed(1);
    }
  } catch (e) {
    print('Error parsing PID $pid value $hexValue: $e');
  }

  return '0';
}

Future<void> reciveData(DataCubit dataCubit) async {
  socket!.listen(
    (Uint8List data) {
      final serverResponse = String.fromCharCodes(data);
      // Split the response into lines
      List<String> lines = serverResponse.split('\n');

      // Iterate over each line
      for (String line in lines) {
        // Remove spaces for consistent parsing
        String cleanLine = line.replaceAll(' ', '').trim();

        // Check if the line is a response to a current data request
        if (cleanLine.length >= 6 && (cleanLine.startsWith('41') || cleanLine.startsWith('43'))) {
          // 410D3C... -> 41 (mode), 0D (pid), 3C... (value)
          String pid = cleanLine.substring(2, 4);
          String rawValue = cleanLine.substring(4);
          String parsedValue = parseObdValue(pid, rawValue);
          
          // Update the latest data
          dataCubit.updateDataWifi(mapPidToName(pid), parsedValue);
        }
      }
    },
    onError: (error) {
      print(error);
      socket!.destroy();
    },
    onDone: () {
      print('Server left.');
      socket!.destroy();
    },
  );
  sendMessage(socket!);
}

Future<void> sendMessage(Socket socket) async {
  try {
    while (true) {
      for (var key in requistData.keys) {
        String message = requistData[key] + '\r\n\r\n';
        print(key);
        print('Client: $message');
        socket.write(message);
        // lastSentMessage = message; // Update the last sent message
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  } on SocketException catch (e) {
    print('SocketException in sendMessage: $e');
  } catch (e) {
    print('General exception in sendMessage: $e');
  }
}

String mapPidToName(pid) {
  switch (pid) {
    case '00':
      return 'troubleCode';
    case '05':
      return 'engineCoolantTemp';
    case '04':
      return 'engineLoad';
    case '0C':
      return 'engineRPM';
    case '0F':
      return 'airintakeTemp';
    case '0D':
      return 'speed';
    case '06':
      return 'shortTermFuelBank1';
    case '11':
      return 'throttlePosition';
    case '0E':
      return 'timingAdvance';
  }

  return "";
}

// void main() {
//   connectToServer(ip: "192.168.1.6", port: 35000);
// }
