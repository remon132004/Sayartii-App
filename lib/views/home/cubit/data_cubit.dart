import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sayartii/utils/initialize_car_data.dart';

part 'data_state.dart';

class DataCubit extends Cubit<DataState> {
  DataCubit() : super(DataInitial());

  void updateDataWifi(String name, dynamic value) {
    requistedData[name] = value;
    emit(WifiData());
  }

  void updateDataBlue(String name, dynamic value) {
    requistedData[name] = value;

    emit(BlueData());
  }
}
