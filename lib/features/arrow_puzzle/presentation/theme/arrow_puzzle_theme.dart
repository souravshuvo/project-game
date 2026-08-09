import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArrowPuzzleColors {
  const ArrowPuzzleColors._();

  static const ink = Color(0xFF172033);
  static const mutedInk = Color(0xFF657086);
  static const canvas = Color(0xFFF4F7FF);
  static const surface = Color(0xFFFFFFFF);
  static const primary = Color(0xFF4B68A5);
  static const primaryDark = Color(0xFF2E477C);
  static const mint = Color(0xFF22A66A);
  static const amber = Color(0xFFFFC531);
  static const coral = Color(0xFFE76E50);
  static const line = Color(0xFFDCE4F4);
  static const blueSoft = Color(0xFFEAF2FF);
  static const amberSoft = Color(0xFFFFF5DE);
  static const mintSoft = Color(0xFFEAF8EF);
}

class ArrowPuzzleTheme {
  const ArrowPuzzleTheme._();

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: ArrowPuzzleColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: ArrowPuzzleColors.primary,
          secondary: ArrowPuzzleColors.mint,
          tertiary: ArrowPuzzleColors.amber,
          surface: ArrowPuzzleColors.surface,
          onSurface: ArrowPuzzleColors.ink,
          outlineVariant: ArrowPuzzleColors.line,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ArrowPuzzleColors.canvas,
      textTheme: Typography.material2021().black.apply(
        bodyColor: ArrowPuzzleColors.ink,
        displayColor: ArrowPuzzleColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ArrowPuzzleColors.ink,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ArrowPuzzleColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ArrowPuzzleColors.primary,
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: ArrowPuzzleColors.primary, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: ArrowPuzzleColors.ink),
      ),
    );
  }
}

class GameBackdrop extends StatelessWidget {
  const GameBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: ArrowPuzzleColors.canvas),
      child: CustomPaint(painter: _LanePatternPainter(), child: child),
    );
  }
}

class ArrowPuzzleCard extends StatelessWidget {
  const ArrowPuzzleCard({
    super.key,
    required this.child,
    this.color = ArrowPuzzleColors.surface,
    this.borderColor = ArrowPuzzleColors.line,
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

class ArrowPuzzleBrandMark extends StatelessWidget {
  const ArrowPuzzleBrandMark({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ArrowPuzzleColors.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: ArrowPuzzleColors.primary.withValues(alpha: 0.28),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.14),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Expanded(
                      child: _BrandTile(icon: Icons.arrow_forward_rounded),
                    ),
                    SizedBox(width: size * 0.08),
                    const Expanded(
                      child: _BrandTile(
                        icon: Icons.arrow_downward_rounded,
                        isAccent: true,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size * 0.08),
              Expanded(
                child: Row(
                  children: [
                    const Expanded(
                      child: _BrandTile(
                        icon: Icons.arrow_upward_rounded,
                        isAccent: true,
                      ),
                    ),
                    SizedBox(width: size * 0.08),
                    const Expanded(
                      child: _BrandTile(icon: Icons.arrow_back_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({required this.icon, this.isAccent = false});

  final IconData icon;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isAccent ? ArrowPuzzleColors.amber : Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        size: 22,
        color: isAccent
            ? ArrowPuzzleColors.primaryDark
            : ArrowPuzzleColors.primary,
      ),
    );
  }
}

class _LanePatternPainter extends CustomPainter {
  const _LanePatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ArrowPuzzleColors.line.withValues(alpha: 0.34)
      ..strokeWidth = 1.2;
    final accentPaint = Paint()
      ..color = ArrowPuzzleColors.amber.withValues(alpha: 0.18)
      ..strokeWidth = 2;

    for (var y = -size.height * 0.2; y < size.height * 1.2; y += 96) {
      canvas.drawLine(
        Offset(-24, y),
        Offset(size.width + 24, y + size.width * 0.12),
        paint,
      );
    }

    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.66, size.height * 0.12),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.92),
      Offset(size.width * 0.88, size.height * 0.82),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
