import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Primary Theme Colors
  static const Color primary = Color(0xFF670000);
  static const Color primaryDark = Color(0xFF4A0000);
  static const Color primarySoft = Color(0xFF8E1E1E);

  // Surface & Background Colors
  static const Color background = Color(0xFFF8F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF3F4F6);
  static const Color card = Color(0xFFFFFFFF);

  // Form Controls & Borders
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color inputFill = Color(0xFFFFFFFF);
  static const Color inputBorder = border;
  static const Color inactiveDot = Color(0xFFE0E0E0);

  // Typography Colors
  static const Color textDark = Color(0xFF121212);
  static const Color textPrimary = Color(0xFF1B2536);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textMuted = Color(0xFF666666);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFFA0A0A0);

  // Feedback & States
  static const Color disabled = Color(0xFFB7BEC9);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE7A32E);
  static const Color error = Color(0xFFD32F2F);

  // Overlays & Effects
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x33000000);

  // Backward compatibility aliases
  static const Color primaryMaroon = primary;
  static const Color darkCard = primaryDark;
  static const Color lightBackground = background;
  static const Color cardBorder = border;
  static const Color cardSurface = surface;
}
