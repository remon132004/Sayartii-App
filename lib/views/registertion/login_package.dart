import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:sayartii/utils/login_helper.dart';
import 'package:sayartii/views/nav_container.dart';
import 'package:sayartii/views/registertion/storeToken.dart';
import 'package:sayartii/views/registertion/apiData.dart';
import 'package:sayartii/constants.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 1500);

  Future<String?> _authUser(LoginData data) async {
    try {
      final res = await ApiService().loginUser(data.name, data.password, true);
      if (res.statusCode == 200) {
        // احفظ التوكن الحقيقي القادم من السيرفر!
        await setAccessToken(res.data['token'] ?? 'fake_token_for_demo_nabd');
        return null; // null تعني الموافقة والسماح بالدخول
      }
      return 'Unknown error occurred.';
    } catch (err) {
      // إرجاع رسالة الخطأ الدقيقة (مثل رقم سري خاطئ)
      return err.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> _signupUser(SignupData data) async {
    try {
      // استخراج الحقول الإضافية
      final name = data.additionalSignupData?['Name'] ?? 'No Name';
      final carName = data.additionalSignupData?['Car Name'] ?? '';
      final carYear = data.additionalSignupData?['Car Year'] ?? '';

      final res = await ApiService().signupUser(
        data.name!,
        data.password!,
        data.password!, // تأكيد الباسورد
        name,
        carName,
        carYear,
      );

      if (res.statusCode == 200) {
        return null; // تم الحساب بنجاح
      }
      return 'Unknown error occurred.';
    } catch (err) {
      return err.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> _forgetPassword(String name) async {
    try {
      await ApiService().forgetPassword(name);
      return null;
    } catch (err) {
      return err.toString().replaceAll('Exception: ', '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Sayartii',
      hideForgotPasswordButton: false, // فعلنا زر نسيان الباسورد ليعمل
      logo: const AssetImage('assets/images/signin.png'),
      theme: LoginTheme(
        primaryColor: kPrimaryBackGroundColor,
        accentColor: kAccentColor,
        errorColor: kDangerColor,
        switchAuthTextColor: kAccentColor,
        cardTheme: const CardTheme(
          color: Colors.white,
          elevation: 8,
          shadowColor: Color(0x334F46E5), // faint indigo shadow
        ),
        titleStyle: const TextStyle(
          fontFamily: 'Quicksand',
          color: kPrimaryDarkColor,
          fontWeight: FontWeight.w800,
          letterSpacing: 4,
          fontSize: 34,
        ),
        bodyStyle: const TextStyle(
          color: kSecondaryTextColor,
        ),
        textFieldStyle: const TextStyle(
          color: kPrimaryDarkColor,
        ),
        buttonTheme: LoginButtonTheme(
          splashColor: kAccentColor,
          backgroundColor: kAccentColor,
          highlightColor: kAccentColor,
          elevation: 9.0,
          highlightElevation: 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        inputTheme: InputDecorationTheme(
          filled: true,
          fillColor: kSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kAccentColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kDangerColor),
          ),
          hintStyle: const TextStyle(color: kSubtleText),
        ),
      ),
      loginAfterSignUp: true,
      onLogin: _authUser,
      onSignup: _signupUser,
      additionalSignupFields: const [
        UserFormField(keyName: 'Name', displayName: 'Full Name'),
        UserFormField(keyName: 'Car Name', displayName: 'Vehicle Model'),
        UserFormField(keyName: 'Car Year', displayName: 'Model Year'),
      ],
      onSubmitAnimationCompleted: () {
        Helper.saveUserLoggedInSharedPreference(true);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const NavContainer(),
        ));
      },
      onRecoverPassword: _forgetPassword,
    );
  }
}