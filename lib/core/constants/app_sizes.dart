import 'package:flutter/material.dart';

class AppSizes {
  const AppSizes._();

  // Spacing Scale
  static const double xxs = 6;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;

  // Border Radii
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXL = 24;

  // Border Radii Aliases
  static const double radiusSm = radiusSmall;
  static const double radiusMd = radiusMedium;
  static const double radiusLg = radiusLarge;

  // Icon Sizes
  static const double iconSmall = 16;
  static const double iconMedium = 20;
  static const double iconLarge = 24;

  // Font Sizes
  static const double textCaption = 12;
  static const double textBody = 14;
  static const double textLabel = 16;
  static const double textSubtitle = 18;
  static const double textTitle = 18;
  static const double textHeadline = 24;

  // Text Accessibility Scaling
  static const double textScaleMin = 0.9;
  static const double textScaleMax = 1.2;

  // Component Specific Dimensions
  static const double buttonHeight = 50;
  static const double inputHeight = 48;
  static const double indicatorDotSize = 8;
  static const double indicatorActiveWidth = 24;

  // Pre-defined Insets
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: AppSizes.xl,
    vertical: AppSizes.xxl,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(AppSizes.lg);
  static const EdgeInsets fieldPadding = EdgeInsets.symmetric(
    horizontal: AppSizes.lg,
    vertical: AppSizes.md,
  );
}
