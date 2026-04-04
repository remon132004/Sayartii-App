import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sayartii/views/intro_screen.dart';
import 'package:sayartii/views/nav_container.dart';

import '../utils/login_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double opacity = 0;

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.fadeIn(
      backgroundColor: Colors.white,
      onInit: () {
        debugPrint("On Init");
      },
      onEnd: () {
        debugPrint("On End");
      },
      childWidget: Center(
        child: SvgPicture.asset(
          'assets/images/icon.svg',
        ),
      ),
      onAnimationEnd: () => debugPrint("On Fade In End"),
      nextScreen: FutureBuilder(
        future: Helper.getUserLoggedInSharedPreference(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(); // Show container while waiting for future to complete
          } else {
            return Helper.isLogged == true
                ? const NavContainer()
              //  : const NavContainer();
            : const OnBoarding();
          }
        },
      ),
      //  Helper.isLogged == true
      //               ? const NavContainer()
      //               : const OnBoarding(),
      duration: const Duration(milliseconds: 5000),
    );
  }
}
