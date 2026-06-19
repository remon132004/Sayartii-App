import 'package:flutter/material.dart';

// ─── Sayartii Professional Teal Theme ────────────────────────────────────────

// Backgrounds
const kPrimaryBackGroundColor = Color(0xFFF7F9FC); // Warm light slate
const kSurface             = Color(0xFFFFFFFF);     // Pure white cards

// Accent — Deep Teal (premium, automotive, professional)
const kAccentColor         = Color(0xFF0D9488);     // Teal 600
const kAccentDark          = Color(0xFF0F766E);     // Teal 700
const kAccentSoft          = Color(0xFFCCFBF1);     // Teal 100
const kAccentSofter        = Color(0xFFF0FDFA);     // Teal 50

// Text
const kPrimaryDarkColor    = Color(0xFF0F172A);     // Slate 900
const kSecondaryTextColor  = Color(0xFF64748B);     // Slate 500
const kSubtleText          = Color(0xFF94A3B8);     // Slate 400

// Status colors
const kSuccessColor        = Color(0xFF10B981);     // Emerald
const kDangerColor         = Color(0xFFF43F5E);     // Rose
const kWarningColor        = Color(0xFFF59E0B);     // Amber

// Borders & dividers
const kBorderColor         = Color(0xFFE2E8F0);     // Slate 200
const kDividerColor        = Color(0xFFF1F5F9);     // Slate 100

// Legacy aliases (kept for backward compat)
const kPrimaryBlueColor    = kAccentColor;
const kCardColor           = kSurface;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ─── Card decoration ─────────────────────────────────────────────────────────
BoxDecoration cardDecoration({double radius = 20}) {
  return BoxDecoration(
    color: kSurface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: kBorderColor, width: 1.0),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF0D9488).withValues(alpha: 0.05),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.03),
        blurRadius: 4,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

// Legacy aliases
BoxDecoration glassDecoration({double radius = 20}) => cardDecoration(radius: radius);
BoxDecoration boxDecoration({double radius = 20}) => cardDecoration(radius: radius);

BoxShadow boxShadow() {
  return BoxShadow(
    color: const Color(0xFF000000).withValues(alpha: 0.05),
    spreadRadius: 0,
    blurRadius: 12,
    offset: const Offset(0, 4),
  );
}

// ─── Accent gradient ─────────────────────────────────────────────────────────
const LinearGradient kAccentGradient = LinearGradient(
  colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─── API Configuration ────────────────────────────────────────────────────────
const String kBackendUrl = "https://remon132004-sayartii-api.hf.space";
const String kAiUrl      = "https://remon132004-sayartii-ai.hf.space";
