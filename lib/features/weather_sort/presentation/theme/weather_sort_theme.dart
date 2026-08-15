import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WeatherSortColors {
  const WeatherSortColors._();

  static const ink = Color(0xFF18212F);
  static const mutedInk = Color(0xFF637084);
  static const canvas = Color(0xFFF3F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const primary = Color(0xFF386FA4);
  static const primaryDark = Color(0xFF214C75);
  static const rain = Color(0xFF2F80B9);
  static const sun = Color(0xFFF6C65B);
  static const mist = Color(0xFF88B4AE);
  static const cloud = Color(0xFF7B6FB3);
  static const frost = Color(0xFF9FDDE7);
  static const mint = Color(0xFF35A878);
  static const coral = Color(0xFFE56F55);
  static const line = Color(0xFFD8E3EC);
  static const wash = Color(0xFFEAF3F8);
}

class WeatherSortTheme {
  const WeatherSortTheme._();

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: WeatherSortColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: WeatherSortColors.primary,
          secondary: WeatherSortColors.mint,
          tertiary: WeatherSortColors.sun,
          surface: WeatherSortColors.surface,
          onSurface: WeatherSortColors.ink,
          outlineVariant: WeatherSortColors.line,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: WeatherSortColors.canvas,
      textTheme: Typography.material2021().black.apply(
        bodyColor: WeatherSortColors.ink,
        displayColor: WeatherSortColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: WeatherSortColors.ink,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: WeatherSortColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: WeatherSortColors.primary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: WeatherSortColors.primary, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: WeatherSortColors.ink),
      ),
    );
  }
}

class WeatherBackdrop extends StatelessWidget {
  const WeatherBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: WeatherSortColors.canvas),
      child: CustomPaint(painter: _WeatherPatternPainter(), child: child),
    );
  }
}

class WeatherPanel extends StatelessWidget {
  const WeatherPanel({
    super.key,
    required this.child,
    this.color = WeatherSortColors.surface,
    this.borderColor = WeatherSortColors.line,
    this.padding = const EdgeInsets.all(14),
    this.shadow = false,
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _WeatherPatternPainter extends CustomPainter {
  const _WeatherPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final washPaint = Paint()
      ..color = WeatherSortColors.line.withValues(alpha: 0.28)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final accentPaint = Paint()
      ..color = WeatherSortColors.sun.withValues(alpha: 0.2)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var y = 48.0; y < size.height; y += 112) {
      final path = Path()
        ..moveTo(-24, y)
        ..cubicTo(
          size.width * 0.22,
          y - 22,
          size.width * 0.52,
          y + 30,
          size.width + 24,
          y,
        );
      canvas.drawPath(path, washPaint);
    }

    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.16),
      Offset(size.width * 0.54, size.height * 0.12),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.42, size.height * 0.88),
      Offset(size.width * 0.86, size.height * 0.84),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
