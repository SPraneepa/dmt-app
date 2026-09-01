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
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final double? width;
  final double height;
  final double borderRadius;

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
              child: isLoading
                  ? const SizedBox(
                      width: AppSizes.iconMedium,
                      height: AppSizes.iconMedium,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textLight,
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.button,
                      ),
                    ),
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
              child: isLoading
                  ? const SizedBox(
                      width: AppSizes.iconMedium,
                      height: AppSizes.iconMedium,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.button.copyWith(
                          color: foregroundColor,
                        ),
                      ),
                    ),
            ),
    );
  }
}
