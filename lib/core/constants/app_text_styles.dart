import 'package:flutter/material.dart';

import 'app_color.dart';
import 'app_sizes.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle heading = TextStyle(
    fontSize: AppSizes.textHeadline,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle title = TextStyle(
    fontSize: AppSizes.textTitle,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: AppSizes.textLabel,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontSize: AppSizes.textBody,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: AppSizes.textBody,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle label = TextStyle(
    fontSize: AppSizes.textLabel,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: AppSizes.textCaption,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontSize: AppSizes.textLabel,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
    height: 1.4,
  );

  static const TextTheme textTheme = TextTheme(
    displayLarge: heading,
    displayMedium: heading,
    headlineLarge: heading,
    headlineMedium: title,
    headlineSmall: title,
    titleLarge: title,
    titleMedium: title,
    titleSmall: subtitle,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: bodySecondary,
    labelLarge: label,
    labelMedium: label,
    labelSmall: caption,
  );
}
