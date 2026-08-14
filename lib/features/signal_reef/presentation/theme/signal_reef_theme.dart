import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignalReefColors {
  const SignalReefColors._();

  static const ink = Color(0xFFEAF7F4);
  static const mutedInk = Color(0xFF9CB9B9);
  static const canvas = Color(0xFF050710);
  static const surface = Color(0xFF111B31);
  static const surfaceHigh = Color(0xFF1A2B4A);
  static const primary = Color(0xFF61E4FF);
  static const accent = Color(0xFFFFC857);
  static const danger = Color(0xFFFF6B6B);
  static const line = Color(0xFF2D5E7A);
}

class SignalReefTheme {
  const SignalReefTheme._();

  static ThemeData dark() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: SignalReefColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: SignalReefColors.primary,
          secondary: SignalReefColors.accent,
          error: SignalReefColors.danger,
          surface: SignalReefColors.surface,
          onSurface: SignalReefColors.ink,
          outlineVariant: SignalReefColors.line,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: SignalReefColors.canvas,
      textTheme: Typography.material2021().white.apply(
        bodyColor: SignalReefColors.ink,
        displayColor: SignalReefColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: SignalReefColors.ink,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: SignalReefColors.primary,
          foregroundColor: const Color(0xFF06212A),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SignalReefColors.ink,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: SignalReefColors.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: SignalReefColors.ink),
      ),
    );
  }
}

class SignalReefBackdrop extends StatelessWidget {
  const SignalReefBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050710), Color(0xFF0B1024), Color(0xFF061A24)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomPaint(
          painter: const _CurrentPainter(),
          child: SizedBox.expand(child: child),
        ),
      ),
    );
  }
}

class SignalReefPanel extends StatelessWidget {
  const SignalReefPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SignalReefColors.surface.withValues(alpha: 0.88),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: SignalReefColors.line),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class SignalReefMark extends StatelessWidget {
  const SignalReefMark({super.key, this.size = 78});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: const _SignalDiverPainter()),
    );
  }
}

class _CurrentPainter extends CustomPainter {
  const _CurrentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final lanePaint = Paint()
      ..color = SignalReefColors.primary.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final starPaint = Paint();

    for (var x = -size.width; x < size.width * 2; x += 92) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.width * 0.34, size.height),
        lanePaint,
      );
    }

    for (var index = 0; index < 42; index++) {
      final x = ((index * 53) % math.max(1, size.width.toInt())).toDouble();
      final y = ((index * 89) % math.max(1, size.height.toInt())).toDouble();
      final color = index % 7 == 0
          ? SignalReefColors.accent.withValues(alpha: 0.34)
          : SignalReefColors.ink.withValues(alpha: 0.26);
      starPaint.color = color;
      canvas.drawCircle(Offset(x, y), index.isEven ? 1.3 : 0.8, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SignalDiverPainter extends CustomPainter {
  const _SignalDiverPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final shell = Paint()..color = SignalReefColors.primary;
    final accent = Paint()..color = SignalReefColors.accent;
    final wing = Paint()..color = SignalReefColors.surfaceHigh;
    final core = Paint()..color = const Color(0xFF06101D);
    final highlight = Paint()..color = Colors.white;
    final leftWing = Path()
      ..moveTo(size.width * 0.22, size.height * 0.42)
      ..lineTo(size.width * 0.02, size.height * 0.78)
      ..lineTo(size.width * 0.34, size.height * 0.70)
      ..close();
    final rightWing = Path()
      ..moveTo(size.width * 0.78, size.height * 0.42)
      ..lineTo(size.width * 0.98, size.height * 0.78)
      ..lineTo(size.width * 0.66, size.height * 0.70)
      ..close();
    final ship = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width * 0.72, size.height * 0.75)
      ..lineTo(size.width * 0.60, size.height * 0.94)
      ..lineTo(size.width * 0.40, size.height * 0.94)
      ..lineTo(size.width * 0.28, size.height * 0.75)
      ..close();

    canvas.drawPath(leftWing, wing);
    canvas.drawPath(rightWing, wing);
    canvas.drawPath(ship, shell);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.47),
        width: size.width * 0.20,
        height: size.height * 0.24,
      ),
      core,
    );
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.42),
      size.width * 0.035,
      highlight,
    );
    canvas.drawLine(
      Offset(size.width * 0.42, size.height * 0.90),
      Offset(size.width * 0.42, size.height * 1.08),
      accent..strokeWidth = size.width * 0.05,
    );
    canvas.drawLine(
      Offset(size.width * 0.58, size.height * 0.90),
      Offset(size.width * 0.58, size.height * 1.08),
      accent..strokeWidth = size.width * 0.08,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
