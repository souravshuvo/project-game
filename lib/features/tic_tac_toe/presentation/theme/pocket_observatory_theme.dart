import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PocketObservatoryColors {
  const PocketObservatoryColors._();

  static const voidInk = Color(0xFF17151F);
  static const deepInk = Color(0xFF24202E);
  static const panel = Color(0xFFF8F2E7);
  static const panelSoft = Color(0xFFFFFAF1);
  static const line = Color(0xFFE1D6C6);
  static const textOnDark = Color(0xFFF9F1E5);
  static const mutedOnDark = Color(0xFFC9C0B5);
  static const ink = Color(0xFF26202D);
  static const mutedInk = Color(0xFF6D6471);
  static const gold = Color(0xFFE9B64E);
  static const teal = Color(0xFF4DB7A8);
  static const rose = Color(0xFFE9827C);
  static const violet = Color(0xFF7465B8);
}

class PocketObservatoryTheme {
  const PocketObservatoryTheme._();

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: PocketObservatoryColors.violet,
          brightness: Brightness.dark,
        ).copyWith(
          primary: PocketObservatoryColors.gold,
          secondary: PocketObservatoryColors.teal,
          tertiary: PocketObservatoryColors.rose,
          surface: PocketObservatoryColors.deepInk,
          onSurface: PocketObservatoryColors.textOnDark,
          outlineVariant: PocketObservatoryColors.line,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: PocketObservatoryColors.voidInk,
      textTheme: Typography.material2021().white.apply(
        bodyColor: PocketObservatoryColors.textOnDark,
        displayColor: PocketObservatoryColors.textOnDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: PocketObservatoryColors.textOnDark,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PocketObservatoryColors.gold,
          foregroundColor: PocketObservatoryColors.voidInk,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PocketObservatoryColors.textOnDark,
          minimumSize: const Size.fromHeight(50),
          side: BorderSide(
            color: PocketObservatoryColors.textOnDark.withValues(alpha: 0.34),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: PocketObservatoryColors.textOnDark,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return PocketObservatoryColors.voidInk;
            }
            return PocketObservatoryColors.textOnDark;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return PocketObservatoryColors.gold;
            }
            return PocketObservatoryColors.deepInk;
          }),
          side: WidgetStateProperty.all(
            BorderSide(
              color: PocketObservatoryColors.textOnDark.withValues(alpha: 0.24),
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? PocketObservatoryColors.gold
              : PocketObservatoryColors.mutedOnDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? PocketObservatoryColors.gold.withValues(alpha: 0.34)
              : PocketObservatoryColors.deepInk;
        }),
      ),
    );
  }
}

class ObservatoryBackdrop extends StatelessWidget {
  const ObservatoryBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: PocketObservatoryColors.voidInk),
      child: CustomPaint(painter: const _StarMapPainter(), child: child),
    );
  }
}

class ObservatoryPanel extends StatelessWidget {
  const ObservatoryPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = PocketObservatoryColors.deepInk,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              borderColor ??
              PocketObservatoryColors.textOnDark.withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class ObservatoryMark extends StatelessWidget {
  const ObservatoryMark({super.key, this.size = 76});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: PocketObservatoryColors.panel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PocketObservatoryColors.gold, width: 2),
        ),
        child: CustomPaint(painter: _ObservatoryMarkPainter()),
      ),
    );
  }
}

class _StarMapPainter extends CustomPainter {
  const _StarMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = PocketObservatoryColors.textOnDark.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    final accentPaint = Paint()
      ..color = PocketObservatoryColors.gold.withValues(alpha: 0.28)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    for (var y = 40.0; y < size.height; y += 92) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + size.width * 0.08),
        linePaint,
      );
    }

    for (var x = 24.0; x < size.width; x += 96) {
      final start = Offset(x, 18 + (x % 40));
      final end = Offset(x + 22, 40 + (x % 54));
      canvas.drawLine(start, end, accentPaint);
      canvas.drawLine(
        Offset(start.dx + 11, start.dy - 11),
        Offset(start.dx + 11, start.dy + 11),
        accentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ObservatoryMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final xPaint = Paint()
      ..color = PocketObservatoryColors.violet
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;
    final oPaint = Paint()
      ..color = PocketObservatoryColors.teal
      ..strokeWidth = size.width * 0.07
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.24, size.height * 0.28),
      Offset(size.width * 0.48, size.height * 0.54),
      xPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.48, size.height * 0.28),
      Offset(size.width * 0.24, size.height * 0.54),
      xPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.66, size.height * 0.46),
      size.width * 0.15,
      oPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
