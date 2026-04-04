// secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

Future<String?> getAccessToken() async {
  return await storage.read(key: 'accessToken');
}

Future<void> setAccessToken(String token) async {
  await storage.write(key: 'accessToken', value: token);
}

Future<void> deleteAccessToken() async {
  await storage.delete(key: 'accessToken');
}
