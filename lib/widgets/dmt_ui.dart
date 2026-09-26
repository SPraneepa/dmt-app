import 'package:flutter/material.dart';

import '../core/constants/app_color.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';

/// Shared, UI-only building blocks for the DMT app.
/// Nothing in here touches providers, models, validation or navigation.

// Input outline colour with >= 3:1 contrast against white (WCAG 1.4.11).
const Color kDmtFieldBorder = Color(0xFFB08A8A);

/// Returns Duration.zero when the user has turned animations off.
Duration dmtMotion(
  BuildContext context, [
  Duration duration = const Duration(milliseconds: 220),
]) {
  return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}

const List<String> kBookingSteps = [
  'Personal Info',
  'Service Selection',
  'Date/Time',
  'Confirmation',
];

/// Segmented progress header for the 4 booking steps.
class DmtStepHeader extends StatelessWidget {
  const DmtStepHeader({super.key, required this.currentStep});

  final int currentStep; // 0-indexed

  @override
  Widget build(BuildContext context) {
    final title = kBookingSteps[currentStep];
    final total = kBookingSteps.length;

    return Semantics(
      container: true,
      label: 'Step ${currentStep + 1} of $total: $title',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppSizes.textBody,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryMaroon,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  'Step ${currentStep + 1} of $total',
                  style: const TextStyle(
                    fontSize: AppSizes.textCaption,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: List.generate(total, (index) {
                final reached = index <= currentStep;
                return Expanded(
                  child: Container(
                    height: 5,
                    margin: EdgeInsets.only(right: index == total - 1 ? 0 : 6),
                    decoration: BoxDecoration(
                      color: reached
                          ? AppColors.primaryMaroon
                          : AppColors.border.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient banner at the top of each step. The one bold moment per screen.
class DmtHeroBanner extends StatelessWidget {
  const DmtHeroBanner({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primarySoft],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.textLight, size: 26),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppSizes.textSubtitle,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                      height: 1.25,
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: AppSizes.textCaption,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// White rounded surface with a soft, brand-tinted shadow.
class DmtCard extends StatelessWidget {
  const DmtCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class DmtFieldLabel extends StatelessWidget {
  const DmtFieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm, left: 2),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: AppSizes.textBody,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

InputDecoration dmtInputDecoration(
  String hintText, {
  Widget? suffixIcon,
  IconData? prefixIcon,
}) {
  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSizes.radiusMd + 2),
    borderSide: BorderSide(color: color, width: width),
  );

  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: AppColors.textMuted,
      fontSize: AppSizes.textBody,
    ),
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSizes.md,
      vertical: AppSizes.md,
    ),
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, size: 20, color: AppColors.primarySoft),
    suffixIcon: suffixIcon,
    enabledBorder: border(kDmtFieldBorder, 1),
    focusedBorder: border(AppColors.primaryMaroon, 2),
    errorBorder: border(AppColors.error, 1.4),
    focusedErrorBorder: border(AppColors.error, 2),
    errorMaxLines: 2,
    errorStyle: const TextStyle(
      color: AppColors.error,
      fontSize: AppSizes.textCaption,
      height: 1.3,
    ),
  );
}

/// Pinned bottom bar with BACK + a primary action.
/// Pass your existing CustomButton as [primary].
class DmtActionBar extends StatelessWidget {
  const DmtActionBar({
    super.key,
    required this.onBack,
    required this.primary,
    this.backLabel = 'BACK',
  });

  final VoidCallback onBack;
  final Widget primary;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.md,
            AppSizes.lg,
            AppSizes.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: AppSizes.buttonHeight,
                  child: OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.primaryMaroon,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    child: Text(
                      backLabel,
                      style: const TextStyle(
                        color: AppColors.primaryMaroon,
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizes.textBody,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(child: primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Curved maroon header for Log In / Sign Up.
class DmtAuthHeader extends StatelessWidget {
  const DmtAuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSizes.xl,
        topInset + AppSizes.xxxl,
        AppSizes.xl,
        AppSizes.xxxl,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primarySoft],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppSizes.radiusXL + 8),
        ),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.directions_car_outlined,
                  color: AppColors.textLight,
                  size: 26,
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                subtitle,
                style: AppTextStyles.bodySecondary.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
