import 'package:flutter/material.dart';
import 'package:sayartii/constants.dart';

class HomeContainer extends StatefulWidget {
  const HomeContainer({
    super.key,
    required this.data,
    required this.text1,
    required this.text2,
    required this.text3,
    this.icon,
  });
  final String data, text1, text2, text3;
  final IconData? icon;

  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(HomeContainer old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data && widget.data != '0' && widget.data.isNotEmpty) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [kSurface, kAccentSofter],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: kBorderColor),
        boxShadow: [
          BoxShadow(
            color: kAccentColor.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          if (widget.icon != null) ...[
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: kAccentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: kAccentColor, size: 17),
            ),
            const SizedBox(height: 10),
          ],

          // Value + unit — animated on data change
          FadeTransition(
            opacity: _fadeAnim,
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: widget.data,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    color: kAccentColor,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: widget.text1,
                  style: const TextStyle(
                    fontSize: 11,
                    color: kSubtleText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.text2,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kPrimaryDarkColor,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            widget.text3,
            style: const TextStyle(
              fontSize: 10.5,
              color: kSubtleText,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
