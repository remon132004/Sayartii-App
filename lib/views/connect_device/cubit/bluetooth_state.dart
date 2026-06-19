part of 'bluetooth_cubit.dart';

@immutable
abstract class BluetoothState {}

class BluetoothInitial extends BluetoothState {}

class BluetoothConnecting extends BluetoothState {}

class BluetoothOn extends BluetoothState {}

class BluetoothOff extends BluetoothState {}

class BluetoothError extends BluetoothState {
  final String message;
  BluetoothError(this.message);
}

class ShowBluetoothList extends BluetoothState {
  final List<BluetoothDevice> devices;
  ShowBluetoothList(this.devices);
}

class WaitingForDevices extends BluetoothState {}
