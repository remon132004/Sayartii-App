import 'package:flutter/material.dart';
import 'package:sayartii/constants.dart';

class HomeContainer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
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
          if (icon != null) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: kAccentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: kAccentColor, size: 17),
            ),
            const SizedBox(height: 10),
          ],

          // Value + unit
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: data,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: kAccentColor,
                  height: 1,
                ),
              ),
              TextSpan(
                text: text1,
                style: const TextStyle(
                  fontSize: 11,
                  color: kSubtleText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]),
          ),

          const SizedBox(height: 8),

          Text(
            text2,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kPrimaryDarkColor,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            text3,
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
