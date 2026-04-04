part of 'trouble_scan_cubit.dart';

@immutable
abstract class TroubleScanState {}

class TroubleScanInitial extends TroubleScanState {}
class RequistDtc extends TroubleScanState {}
class DtcResultPos extends TroubleScanState {}
class DtcResultNeg extends TroubleScanState {}

