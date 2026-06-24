import 'dart:convert';
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
        data: {'email': username.trim(), 'password': password, 'rememberMe': rememberMe},
      );

      // Save token securely if the login is successful
      if (response.statusCode == 200 && response.data != null && response.data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        final token = response.data['token'].toString();
        await prefs.setString('jwt_token', token);
        
        // 1. Try extracting name/email from the JWT token (Standard .NET Core Identity Claims)
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = parts[1];
            // Pad base64url if needed
            String normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
            switch (normalized.length % 4) {
              case 2: normalized += '=='; break;
              case 3: normalized += '='; break;
            }
            final respStr = utf8.decode(base64Decode(normalized));
            final decoded = json.decode(respStr);
            
            String? jwtName = decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ?? decoded['name'] ?? decoded['unique_name'];
            String? jwtEmail = decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] ?? decoded['email'];
            
            if (jwtName != null && jwtName.trim().isNotEmpty) {
              await prefs.setString('user_name', jwtName);
            }
            if (jwtEmail != null && jwtEmail.trim().isNotEmpty) {
              await prefs.setString('user_email', jwtEmail);
            }
          }
        } catch (e) {
          // Ignore JWT decode errors
        }

        // 2. Overwrite with explicit response data if backend provides it
        if (response.data['name'] != null && response.data['name'].toString().trim().isNotEmpty) {
          await prefs.setString('user_name', response.data['name'].toString());
        }
        if (response.data['email'] != null && response.data['email'].toString().trim().isNotEmpty) {
          await prefs.setString('user_email', response.data['email'].toString());
        } else if (prefs.getString('user_email') == null) {
          // 3. Fallback: Save the email the user just typed to login
          await prefs.setString('user_email', username.trim());
        }
        if (response.data['carName'] != null && response.data['carName'].toString().trim().isNotEmpty) {
          await prefs.setString('user_car', response.data['carName'].toString());
        }
      }

      return response;
    } on DioException catch (error) {
      throw Exception(_parseError(error.response, 'Invalid credentials'));
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
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_car');
  }

  // Get locally stored profile info
  static Future<Map<String, String?>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name'),
      'email': prefs.getString('user_email'),
      'car': prefs.getString('user_car'),
    };
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
          'email': email.trim(),
          'password': password,
          'confirmPassword': confirmPassword,
          'name': name,
          'carName': carName,
          'carYear': carYear
        },
      );
      if (response.statusCode == 200) {
        // Save the entered name & car locally for the profile display
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', name.trim());
        await prefs.setString('user_email', email.trim());
        if (carName.trim().isNotEmpty) {
          await prefs.setString('user_car', carName.trim());
        }
      }
      return response;
    } on DioException catch (error) {
      throw Exception(_parseError(error.response, 'Registration failed'));
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
      throw Exception(_parseError(error.response, 'Request failed'));
    }
  }

  String _parseError(Response? response, String defaultMsg) {
    if (response == null) return 'Network error, please try again.';
    if (response.statusCode == 401) return 'Invalid email or password.';
    if (response.statusCode == 500) return 'Server error. Please try again later.';
    final data = response.data;
    
    // Safety check to avoid showing raw SQL or technical errors
    String parseMsg(String msg) {
      final m = msg.toLowerCase();
      if (m.contains('sqlite') || m.contains('sql') || m.contains('exception') || m.contains('connection refused') || m.contains('no such table')) {
        return 'Server connection error. Please contact support or try again later.';
      }
      return msg;
    }

    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) return parseMsg(data['message'].toString());
      if (data.containsKey('Email')) return parseMsg(data['Email'][0].toString());
      if (data.containsKey('title') && !data['title'].toString().contains('validation')) return parseMsg(data['title'].toString());
      if (data.containsKey('errors')) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          return parseMsg(errors.values.first[0].toString());
        }
      }
    }
    
    if (data is String) {
      return parseMsg(data);
    }
    
    return defaultMsg;
  }
}
