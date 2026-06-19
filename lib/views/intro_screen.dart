import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/cubit/language_cubit.dart';
import 'package:sayartii/views/registertion/login_package.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});
  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final int _pageCount = 3;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    setState(() => _currentPage = i);
    _fadeCtrl.forward(from: 0);
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('showChoose', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isLast = _currentPage == _pageCount - 1;
    final size = MediaQuery.of(context).size;

    final pages = [
      _PageData(
        title: isAr ? 'اتصل بسيارتك' : 'Connect Your Car',
        body: isAr
            ? 'وصّل جهاز OBD-II بسيارتك وشاهد بيانات المحرك الحية فوراً بضغطة واحدة'
            : 'Plug in your OBD-II adapter and instantly monitor live engine data in one tap.',
        icon: Icons.bluetooth_searching_rounded,
        iconColor: kAccentColor,
        badge: 'OBD-II',
      ),
      _PageData(
        title: isAr ? 'تنبؤ ذكي بالأعطال' : 'AI Fault Prediction',
        body: isAr
            ? 'الذكاء الاصطناعي يحلل بيانات محركك ويكتشف الأعطال قبل أن تتفاقم وتكلفك أكثر'
            : 'Our AI analyzes your engine continuously and flags issues before they become expensive.',
        icon: Icons.query_stats_rounded,
        iconColor: const Color(0xFF7C3AED),
        badge: 'AI',
      ),
      _PageData(
        title: isAr ? 'دائماً معك' : 'Always With You',
        body: isAr
            ? 'سيارتي يعمل في الخلفية ويرسل إشعارات فورية لحظة اكتشاف أي مشكلة'
            : 'Sayartii runs silently and sends you instant alerts the moment anything unusual is detected.',
        icon: Icons.notifications_active_rounded,
        iconColor: kSuccessColor,
        badge: isAr ? 'ذكي' : 'Smart',
      ),
    ];

    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      body: Stack(
        children: [

          // ─── TOP: Full onboarding image (58% of height) ──────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: size.height * 0.58,
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/onboarding.png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Bottom gradient fade
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          kPrimaryBackGroundColor.withValues(alpha: 0.3),
                          kPrimaryBackGroundColor,
                        ],
                        stops: const [0.4, 0.72, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── BOTTOM: Sliding text content ────────────────────────────
          Positioned(
            top: size.height * 0.52,
            left: 0, right: 0, bottom: 0,
            child: PageView.builder(
              controller: _controller,
              itemCount: _pageCount,
              onPageChanged: _onPageChanged,
              itemBuilder: (_, i) => FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
                  child: Column(
                    crossAxisAlignment: isAr
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        pages[i].title,
                        textAlign: isAr ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: kPrimaryDarkColor,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        pages[i].body,
                        textAlign: isAr ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.65,
                          color: kSecondaryTextColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── TOP BAR: lang toggle + skip ─────────────────────────────
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BlocBuilder<LanguageCubit, Locale>(
                    builder: (ctx, locale) => GestureDetector(
                      onTap: () =>
                          ctx.read<LanguageCubit>().toggleLanguage(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language_rounded,
                                color: Colors.white70, size: 13),
                            const SizedBox(width: 5),
                            Text(
                              locale.languageCode == 'ar' ? 'EN' : 'AR',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    GestureDetector(
                      onTap: () => _controller.jumpToPage(_pageCount - 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          isAr ? 'تخطي' : 'Skip',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─── BOTTOM CONTROLS: dots + CTA button ──────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  24,
                  0,
                  24,
                  MediaQuery.of(context).padding.bottom + 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pageCount,
                    effect: ExpandingDotsEffect(
                      dotWidth: 8,
                      dotHeight: 8,
                      spacing: 6,
                      radius: 100,
                      expansionFactor: 3.5,
                      dotColor: kBorderColor,
                      activeDotColor: kAccentColor,
                    ),
                    onDotClicked: (i) => _controller.animateToPage(i,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLast
                          ? _finish
                          : () => _controller.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: kAccentGradient,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: kAccentColor.withValues(alpha: 0.4),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            isLast
                                ? (isAr ? 'ابدأ الآن' : 'Get Started')
                                : (isAr ? 'التالي' : 'Continue'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageData {
  final String title, body, badge;
  final IconData icon;
  final Color iconColor;
  const _PageData({
    required this.title,
    required this.body,
    required this.icon,
    required this.iconColor,
    required this.badge,
  });
}
