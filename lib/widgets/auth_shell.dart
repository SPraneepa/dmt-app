import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_color.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';

/// Shared layout for Log In / Sign Up (UI only, no logic).
///
/// A maroon branded header with the DMT mark, and a rounded sheet that
/// overlaps it and holds the form. Self-contained: it does not depend on
/// any other new file.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  static const double _overlap = 28;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final animDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 550);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              // ---------- Header ----------
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primary,
                      AppColors.primarySoft,
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ExcludeSemantics(
                        child: CustomPaint(
                          painter: _HeaderPatternPainter(bottomGap: _overlap),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSizes.xl,
                        topInset + AppSizes.xl,
                        AppSizes.xl,
                        _overlap + AppSizes.xxxl,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                label: 'Department of Motor Traffic, Sri Lanka',
                                child: ExcludeSemantics(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomPaint(
                                        size: const Size(150, 56),
                                        painter: _DmtMarkPainter(),
                                      ),
                                      const SizedBox(height: AppSizes.sm),
                                      const Text(
                                        'DEPARTMENT OF MOTOR TRAFFIC',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSizes.xxxl),
                              Semantics(
                                header: true,
                                child: Text(
                                  title,
                                  style: AppTextStyles.heading.copyWith(
                                    color: AppColors.textLight,
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSizes.sm),
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
                    ),
                  ],
                ),
              ),

              // ---------- Overlapping form sheet ----------
              Transform.translate(
                offset: const Offset(0, -_overlap),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: animDuration,
                  curve: Curves.easeOutCubic,
                  builder: (context, t, sheet) => Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, (1 - t) * 20),
                      child: sheet,
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.xl,
                      AppSizes.xxl + AppSizes.xs,
                      AppSizes.xl,
                      AppSizes.xl,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          children: [
                            child,
                            const SizedBox(height: AppSizes.xl),
                            const Text(
                              'GOVERNMENT OF SRI LANKA',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: bottomInset),
            ],
          ),
        ),
      ),
    );
  }
}

/// "—— or sign up with ——" divider.
class AuthDividerLabel extends StatelessWidget {
  const AuthDividerLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Text(text, style: AppTextStyles.caption),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}

/// Same button as before, restyled. Pass your existing onPressed.
class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(
          'assets/images/google_logo.png',
          height: AppSizes.iconSmall + 2,
          width: AppSizes.iconSmall + 2,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.g_mobiledata, size: AppSizes.iconMedium),
        ),
        label: const Text('Continue with Google'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          side: const BorderSide(color: Color(0xFFB08A8A)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium + 2),
          ),
        ),
      ),
    );
  }
}

/// "Don't have an account?  Sign Up" with a comfortable tap target.
class AuthTextLink extends StatelessWidget {
  const AuthTextLink({
    super.key,
    required this.prefix,
    required this.action,
    required this.onTap,
  });

  final String prefix;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(prefix, style: AppTextStyles.bodySecondary),
        InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.xs,
              vertical: AppSizes.md,
            ),
            child: Text(
              action,
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Painters
// ---------------------------------------------------------------------------

/// Very quiet background motif: soft rings + a dashed road lane.
class _HeaderPatternPainter extends CustomPainter {
  _HeaderPatternPainter({required this.bottomGap});

  final double bottomGap;

  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width * 0.92, size.height * 0.18);
    for (final r in [56.0, 100.0, 148.0]) {
      canvas.drawCircle(center, r, ringPaint);
    }

    final lanePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final y = size.height - bottomGap - 14;
    const dash = 16.0;
    const gap = 12.0;
    double x = 12;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + dash).clamp(0, size.width), y),
        lanePaint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _HeaderPatternPainter old) =>
      old.bottomGap != bottomGap;
}

/// The DMT mark (same drawing as the splash logo, scaled down).
class _DmtMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double baselineY = size.height * 0.88;
    canvas.drawLine(
      Offset(size.width * 0.02, baselineY),
      Offset(size.width * 0.98, baselineY),
      strokePaint,
    );

    const double wheelRadius = 9.0;
    final Offset circleCenter = Offset(
      size.width * 0.15,
      baselineY - wheelRadius - 1.5,
    );

    canvas.drawCircle(
      circleCenter,
      wheelRadius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(circleCenter, 5, fillPaint);

    final double lineY = circleCenter.dy;
    canvas.drawLine(
      Offset(circleCenter.dx + wheelRadius + 5, lineY),
      Offset(size.width * 0.66, lineY),
      strokePaint,
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'DMT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(size.width * 0.71, lineY - (textPainter.height / 2)),
    );

    final path = Path()
      ..moveTo(size.width * 0.05, size.height * 0.48)
      ..quadraticBezierTo(
        size.width * 0.15,
        size.height * 0.28,
        size.width * 0.25,
        size.height * 0.48,
      )
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.02,
        size.width * 0.65,
        size.height * 0.48,
      )
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.28,
        size.width * 0.87,
        size.height * 0.48,
      );
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
