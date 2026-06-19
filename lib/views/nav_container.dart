import 'package:flutter/material.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/views/app_center_view.dart';
import 'package:sayartii/views/home/home_view.dart';
import 'package:sayartii/views/my_info_view.dart';
import 'package:sayartii/l10n/app_localizations.dart';

class NavContainer extends StatefulWidget {
  const NavContainer({super.key});
  @override
  State<NavContainer> createState() => _NavContainerState();
}

class _NavContainerState extends State<NavContainer> {
  int _index = 0;

  final List<Widget> _screens = const [
    HomeView(),
    AppCenterView(),
    MyInfoView(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    final items = <_TabItem>[
      _TabItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: l.home,
      ),
      _TabItem(
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
        label: l.applicationCenter,
      ),
      _TabItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: l.myInfo,
      ),
    ];

    final displayItems = isAr ? items.reversed.toList() : items;
    final int displayIndex = isAr ? (items.length - 1 - _index) : _index;

    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _FloatingNavBar(
        items: displayItems,
        activeIndex: displayIndex,
        isAr: isAr,
        itemCount: items.length,
        onTap: (i) {
          final int actualIndex = isAr ? (items.length - 1 - i) : i;
          setState(() => _index = actualIndex);
        },
      ),
    );
  }
}

// ─── Floating Pill Nav Bar ────────────────────────────────────────────────────
class _FloatingNavBar extends StatelessWidget {
  final List<_TabItem> items;
  final int activeIndex;
  final bool isAr;
  final int itemCount;
  final void Function(int) onTap;

  const _FloatingNavBar({
    required this.items,
    required this.activeIndex,
    required this.isAr,
    required this.itemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        border: Border(top: BorderSide(color: kBorderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = activeIndex == i;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? kAccentSoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: isActive ? 36 : 0,
                          height: isActive ? 3 : 0,
                          margin: EdgeInsets.only(bottom: isActive ? 4 : 0),
                          decoration: BoxDecoration(
                            color: kAccentColor,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive ? kAccentColor : kSubtleText,
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isActive ? kAccentColor : kSubtleText,
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
