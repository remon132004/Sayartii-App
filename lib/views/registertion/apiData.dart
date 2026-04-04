import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sayartii/constants.dart';

class ApiService {
  final Dio _dio = Dio();
  
  static const String baseUrl = '$kBackendUrl/api/Account';

  // For Login
  Future<Response<dynamic>> loginUser(
      String username, String password, bool rememberMe) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {'email': username, 'password': password, 'rememberMe': rememberMe},
      );

      // Save token securely if the login is successful
      if (response.statusCode == 200 && response.data != null && response.data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', response.data['token']);
      }

      return response;
    } on DioException catch (error) {
      if (error.response != null) {
        // إذا كان السيرفر أرجع خطأ (مثل: الإيميل خطأ) نرجعه
        throw Exception(error.response?.data['message'] ?? error.response?.data ?? 'Invalid credentials');
      } else {
        throw Exception('Network error, please try again.');
      }
    }
  }

  // Get the locally saved JWT token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Logout / clear token
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // For Registration
  Future<Response<dynamic>> signupUser(
      String email,
      String password,
      String confirmPassword,
      String name,
      String carName,
      String carYear) async {
    try {
      final response = await _dio.post(
        '$baseUrl/register',
        data: {
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'name': name
        },
      );
      return response;
    } on DioException catch (error) {
      if (error.response != null) {
        throw Exception(error.response?.data['message'] ?? error.response?.data ?? 'Registration failed');
      } else {
        throw Exception('Network error, please try again.');
      }
    }
  }

  // For Forget Password
  Future<Response<dynamic>> forgetPassword(String email) async {
    try {
      final response = await _dio.post(
        '$baseUrl/forgetpassword',
        data: {'email': email},
      );
      return response;
    } on DioException catch (error) {
      if (error.response != null) {
        throw Exception(error.response?.data['message'] ?? error.response?.data ?? 'Request failed');
      } else {
        throw Exception('Network error, please try again.');
      }
    }
  }
}
