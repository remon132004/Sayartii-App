import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<Locale> {
  LanguageCubit() : super(const Locale('en')) {
    _loadLanguage();
  }

  void _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      emit(Locale(languageCode));
    }
  }

  void toggleLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (state.languageCode == 'en') {
      emit(const Locale('ar'));
      await prefs.setString('language_code', 'ar');
    } else {
      emit(const Locale('en'));
      await prefs.setString('language_code', 'en');
    }
  }
}
