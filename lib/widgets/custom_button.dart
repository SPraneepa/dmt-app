import 'package:flutter/material.dart';

import '../core/constants/app_color.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.width,
    this.height = AppSizes.buttonHeight,
    this.borderRadius = AppSizes.radiusMedium,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final double? width;
  final double height;
  final double borderRadius;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bool enabled = !isLoading && onPressed != null;

    final Color backgroundColor = isPrimary
        ? AppColors.primary
        : AppColors.surface;

    final Color foregroundColor = isPrimary
        ? AppColors.textLight
        : AppColors.primary;

    final Color borderColor = AppColors.primary;

    Widget buildButtonContent(Color textAndIconColor) {
      if (isLoading) {
        return SizedBox(
          width: AppSizes.iconMedium,
          height: AppSizes.iconMedium,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textAndIconColor),
          ),
        );
      }

      if (icon != null) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizes.iconMedium, color: textAndIconColor),
            const SizedBox(width: AppSizes.xs),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.button.copyWith(color: textAndIconColor),
            ),
          ],
        );
      }

      return Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.button.copyWith(color: textAndIconColor),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isPrimary
          ? ElevatedButton(
              onPressed: enabled ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                disabledBackgroundColor: AppColors.disabled,
                disabledForegroundColor: AppColors.textLight,
                elevation: 0,
                padding: EdgeInsets.zero,
                minimumSize: Size(width ?? double.infinity, height),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: buildButtonContent(foregroundColor),
            )
          : OutlinedButton(
              onPressed: enabled ? onPressed : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: foregroundColor,
                backgroundColor: backgroundColor,
                side: BorderSide(color: borderColor, width: 1.5),
                disabledForegroundColor: AppColors.disabled,
                disabledBackgroundColor: AppColors.surface,
                padding: EdgeInsets.zero,
                minimumSize: Size(width ?? double.infinity, height),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: buildButtonContent(foregroundColor),
            ),
    );
  }
}
