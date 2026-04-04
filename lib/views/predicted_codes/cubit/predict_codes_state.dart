part of 'predict_codes_cubit.dart';

@immutable
abstract class PredictCodesState {}

class PredictCodesInitial extends PredictCodesState {}
class ShowPredictedCodes extends PredictCodesState {}
class NoPrediction extends PredictCodesState {}
