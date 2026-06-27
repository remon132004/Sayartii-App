part of 'predict_codes_cubit.dart';

@immutable
abstract class PredictCodesState {}

class PredictCodesInitial extends PredictCodesState {}
class PredictCodesLoading extends PredictCodesState {}
class ShowPredictedCodes extends PredictCodesState {}
class NoPrediction extends PredictCodesState {}
class PredictCodesError extends PredictCodesState {
  final String message;
  PredictCodesError(this.message);
}
