import 'package:shared_preferences/shared_preferences.dart';

class Helper {

  static bool? isLogged;
  static String userLoggedInKey = "USERLOGGEDINKEY";

  static saveUserLoggedInSharedPreference(bool isUserLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(userLoggedInKey, isUserLoggedIn);
  }

  static getUserLoggedInSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLogged = prefs.getBool(userLoggedInKey);
  }
}
