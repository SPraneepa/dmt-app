import 'package:flutter/material.dart';

import '../constants/app_color.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.lightBackground,
  primaryColor: AppColors.primaryMaroon,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primaryMaroon,
    primary: AppColors.primaryMaroon,
    secondary: AppColors.darkCard,
    surface: AppColors.lightBackground,
    brightness: Brightness.light,
  ),
  textTheme: ThemeData.light().textTheme.copyWith(
    headlineSmall: const TextStyle(
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    titleMedium: const TextStyle(
      fontWeight: FontWeight.bold,
      color: AppColors.primaryMaroon,
    ),
    bodyMedium: const TextStyle(color: AppColors.textSecondary),
    bodySmall: const TextStyle(color: AppColors.textSecondary),
    labelLarge: const TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryMaroon,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[100],
    hintStyle: const TextStyle(color: AppColors.textMuted),
    labelStyle: const TextStyle(color: AppColors.textDark),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryMaroon, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryMaroon,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryMaroon,
      side: const BorderSide(color: AppColors.primaryMaroon, width: 1.2),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
);

class AppTheme {
  static final ThemeData lightTheme = appTheme;
}
