import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/views/intro_screen.dart';
import 'package:sayartii/views/nav_container.dart';

import '../utils/login_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    // Artificial tiny delay just to ensure smooth rendering transition from native splash
    await Future.delayed(const Duration(milliseconds: 300));
    await Helper.getUserLoggedInSharedPreference();
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return Helper.isLogged == true ? const NavContainer() : const OnBoarding();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This perfectly matches the native Android splash screen to prevent any jumping/flickering.
    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      body: Center(
        child: Image.asset(
          'assets/images/perfect_splash_icon_hq.png',
          width: 130, // Adjusted to match the high-res native scaled down size
        ),
      ),
    );
  }
}
