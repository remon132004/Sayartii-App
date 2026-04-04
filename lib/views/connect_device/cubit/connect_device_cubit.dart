import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'connect_device_state.dart';

class ConnectDeviceCubit extends Cubit<ConnectDeviceState> {
  ConnectDeviceCubit() : super(ConnectDeviceInitial());
  String name = "Bluetooth";
  Map<String, bool> enabled = {"Bluetooth": true, "WiFi": false};
  
  changeState() {
    if (name == "Bluetooth") {
      emit(ConnectDeviceBluetoothState());
    } else if (name == "WiFi") {
      emit(ConnectDeviceWifiState());
    }
  }

  connectWifi() async {
    
  }
}
