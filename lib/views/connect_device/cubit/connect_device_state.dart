part of 'connect_device_cubit.dart';

@immutable
abstract class ConnectDeviceState {}

class ConnectDeviceInitial extends ConnectDeviceState {}

class ConnectDeviceBluetoothState extends ConnectDeviceState {}

class ConnectDeviceWifiState extends ConnectDeviceState {}

class WifiConnectButton extends ConnectDeviceState {}
