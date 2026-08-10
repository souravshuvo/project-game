import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignalReefColors {
  const SignalReefColors._();

  static const ink = Color(0xFFEAF7F4);
  static const mutedInk = Color(0xFF9CB9B9);
  static const canvas = Color(0xFF07131E);
  static const surface = Color(0xFF102A34);
  static const surfaceHigh = Color(0xFF163D45);
  static const primary = Color(0xFF50D6C7);
  static const accent = Color(0xFFFFC857);
  static const danger = Color(0xFFFF6B6B);
  static const line = Color(0xFF285766);
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF07131E), Color(0xFF102333), Color(0xFF092621)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: CustomPaint(painter: const _CurrentPainter(), child: child),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SignalReefColors.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SignalReefColors.line),
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
    final linePaint = Paint()
      ..color = SignalReefColors.primary.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final sparkPaint = Paint()
      ..color = SignalReefColors.accent.withValues(alpha: 0.28);

    for (var y = -40.0; y < size.height + 80; y += 92) {
      final path = Path()
        ..moveTo(-20, y)
        ..quadraticBezierTo(size.width * 0.4, y + 46, size.width + 20, y + 8);
      canvas.drawPath(path, linePaint);
    }

    for (var index = 0; index < 28; index++) {
      final x = ((index * 53) % math.max(1, size.width.toInt())).toDouble();
      final y = ((index * 89) % math.max(1, size.height.toInt())).toDouble();
      canvas.drawCircle(Offset(x, y), index.isEven ? 1.4 : 0.8, sparkPaint);
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
    final core = Paint()..color = Colors.white;
    final ship = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width * 0.88, size.height * 0.72)
      ..quadraticBezierTo(
        size.width / 2,
        size.height,
        size.width * 0.12,
        size.height * 0.72,
      )
      ..close();

    canvas.drawPath(ship, shell);
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.44),
      size.width * 0.11,
      core,
    );
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.82),
      Offset(size.width / 2, size.height * 1.08),
      accent..strokeWidth = size.width * 0.08,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
