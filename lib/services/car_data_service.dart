import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sayartii/constants.dart';
import '../models/car_data.dart';
import '../views/registertion/apiData.dart';

class CarDataService {
  static const String baseUrl = '$kBackendUrl/api/CarData/CarData';

  Future<bool> postCarData(CarDataModel data) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('User is not authenticated.');
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to post car data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
