import 'package:flutter/material.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:sayartii/views/app_center_view.dart';
import 'package:sayartii/views/home/home_view.dart';
import 'package:sayartii/views/my_info_view.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import '../nav_bar_icons.dart';

class NavContainer extends StatefulWidget {
  const NavContainer({
    super.key,
  });
  @override
  State<NavContainer> createState() => _NavContainerState();
}

class _NavContainerState extends State<NavContainer> {
  int currentIndex = 0;
  List<Widget> pages = [const HomeView(), AppCenterView(),  MyInfoView()];
  @override
  Widget build(BuildContext context) {
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    var myTabs = [
      TabData(iconData: MyFlutterApp.home, title: AppLocalizations.of(context)!.home),
      TabData(iconData: MyFlutterApp.menu, title: AppLocalizations.of(context)!.applicationCenter),
      TabData(iconData: MyFlutterApp.user, title: AppLocalizations.of(context)!.myInfo)
    ];

    if (isAr) {
      myTabs = myTabs.reversed.toList();
    }

    int visualIndex = isAr ? (myTabs.length - 1 - currentIndex) : currentIndex;

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.ltr,
        child: FancyBottomNavigation(
          key: ValueKey(Localizations.localeOf(context).languageCode),
          initialSelection: visualIndex,
          tabs: myTabs,
          inactiveIconColor: Colors.black54,
          onTabChangedListener: (vIndex) {
            int actualIndex = isAr ? (myTabs.length - 1 - vIndex) : vIndex;
            setState(() {
              currentIndex = actualIndex;
            });
          },
        ),
      ),
    );
  }
}
