import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../core/constants/app_color.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _navigationTimer;
  late AnimationController _wheelController;

  @override
  void initState() {
    super.initState();

    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _navigateToNext();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _wheelController.dispose();
    super.dispose();
  }

  void _navigateToNext() {
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryMaroon,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _wheelController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(240, 90),
                        painter: _DMTLogoPainter(
                          wheelRotation: _wheelController.value,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'DEPARTMENT OF MOTOR TRAFFIC',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'SRI LANKA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              const Text(
                'GOVERNMENT OF SRI LANKA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DMTLogoPainter extends CustomPainter {
  final double wheelRotation;

  _DMTLogoPainter({required this.wheelRotation});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double baselineY = size.height * 0.88;

    // Ground Baseline
    canvas.drawLine(
      Offset(size.width * 0.02, baselineY),
      Offset(size.width * 0.98, baselineY),
      strokePaint,
    );

    const double wheelRadius = 14.0;

    final Offset circleCenter = Offset(
      size.width * 0.15,
      baselineY - wheelRadius - 1.5,
    );

    // =========================
    // 1. SOLID FILLED INNER CIRCLE (Center Hub)
    // =========================
    canvas.drawCircle(circleCenter, wheelRadius * 0.5, fillPaint);

    // =========================
    // 2. ROTATING OUTER SINGLE ARC
    // =========================
    canvas.save();
    canvas.translate(circleCenter.dx, circleCenter.dy);
    canvas.rotate(wheelRotation * 2 * pi);

    final outerArcPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    // Single arc spinning around the center disc (~270 degrees)
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: wheelRadius),
      0,
      1.5 * pi,
      false,
      outerArcPaint,
    );

    canvas.restore();

    // =========================
    // DMT LINE
    // =========================
    final double lineStartY = circleCenter.dy;

    canvas.drawLine(
      Offset(circleCenter.dx + wheelRadius + 6, lineStartY),
      Offset(size.width * 0.66, lineStartY),
      strokePaint,
    );

    // =========================
    // DMT TEXT
    // =========================
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'DMT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(size.width * 0.71, lineStartY - (textPainter.height / 2)),
    );

    // =========================
    // CAR ROOF
    // =========================
    final path = Path();

    path.moveTo(size.width * 0.05, size.height * 0.48);

    path.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.28,
      size.width * 0.25,
      size.height * 0.48,
    );

    path.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.02,
      size.width * 0.65,
      size.height * 0.48,
    );

    path.quadraticBezierTo(
      size.width * 0.76,
      size.height * 0.28,
      size.width * 0.87,
      size.height * 0.48,
    );

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _DMTLogoPainter oldDelegate) {
    return oldDelegate.wheelRotation != wheelRotation;
  }
}
