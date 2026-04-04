import 'package:flutter/material.dart';
import 'package:sayartii/models/buildIntroPage.dart';
import 'package:sayartii/views/registertion/login_package.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<StatefulWidget> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  String urlImage = '';
  String title = '';
  String subtitle = '';
  final controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/onboarding.png',
            fit: BoxFit.cover,
          ),
        ),
        PageView(
          controller: controller,
          onPageChanged: (index) {
            setState(() => isLastPage = index == 2);
          },
          children: const [
            BuildPage(
              urlImage: 'assets/images/onboarding.png',
              title: 'Welcome To',
              subtitle: 'Nabd',
            ),
            BuildPage(
              urlImage: 'assets/images/onboarding.png',
              title: 'Staying safe is important to us.',
              subtitle: '',
            ),
            BuildPage(
              urlImage: 'assets/images/onboarding.png',
              title: "We'll keep your car running ;)",
              subtitle: '',
            ),
          ],
        ),
        Positioned(
            bottom: 40,
            left: 0.0,
            right: 0.0,
            child: isLastPage
                ? TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF235DFF),
                      // minimumSize: const Size.fromWidth(300),
                      maximumSize: const Size.fromHeight(60),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool('showChoose', true);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Register',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //skip
                        TextButton(
                            onPressed: () => controller.jumpToPage(2),
                            child: const Text(
                              'SKIP',
                              style: TextStyle(
                                  color: Color(0xFF235DFF),
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            )),
                        //dots
                        Center(
                          child: SmoothPageIndicator(
                            controller: controller,
                            count: 3,
                            effect: const WormEffect(
                              spacing: 20,
                              dotColor: Colors.black26,
                              activeDotColor: Color(0xFF235DFF),
                            ),
                            //to click on dots and move
                            onDotClicked: (index) => controller.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.ease,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
      ]),
    );
  }
}
