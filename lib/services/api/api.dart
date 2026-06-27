import 'dart:convert';

import 'package:http/http.dart' as http;

const _kTimeout = Duration(seconds: 15);

class Api {
  Future<dynamic> get({required String url, String? token}) async {
    Map<String, String> headers = {};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(_kTimeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'GET failed — status: ${response.statusCode}, url: $url');
    }
  }

  Future<dynamic> post(
      {required dynamic url, required dynamic body, String? token}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http
        .post(Uri.parse(url), body: body, headers: headers)
        .timeout(_kTimeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'POST failed — status: ${response.statusCode}, body: ${response.body}');
    }
  }

  Future<dynamic> put(
      {required dynamic url, required dynamic body, String? token}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http
        .put(Uri.parse(url), body: body, headers: headers)
        .timeout(_kTimeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'PUT failed — status: ${response.statusCode}, body: ${response.body}');
    }
  }
}
