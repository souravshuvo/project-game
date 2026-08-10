import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TripleMatchColors {
  const TripleMatchColors._();

  static const ink = Color(0xFF1D2430);
  static const mutedInk = Color(0xFF657080);
  static const canvas = Color(0xFFF1F7F4);
  static const surface = Color(0xFFFFFFFF);
  static const primary = Color(0xFF276B63);
  static const primaryDark = Color(0xFF16443F);
  static const coral = Color(0xFFE45D50);
  static const amber = Color(0xFFF0B429);
  static const blue = Color(0xFF3978B8);
  static const line = Color(0xFFD7E5DE);
  static const softGreen = Color(0xFFE3F2EA);
  static const softBlue = Color(0xFFE6F0FA);
  static const softCoral = Color(0xFFFFE9E5);
  static const softAmber = Color(0xFFFFF5D8);
}

class TripleMatchTheme {
  const TripleMatchTheme._();

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: TripleMatchColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: TripleMatchColors.primary,
          secondary: TripleMatchColors.coral,
          tertiary: TripleMatchColors.amber,
          surface: TripleMatchColors.surface,
          onSurface: TripleMatchColors.ink,
          outlineVariant: TripleMatchColors.line,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: TripleMatchColors.canvas,
      textTheme: Typography.material2021().black.apply(
        bodyColor: TripleMatchColors.ink,
        displayColor: TripleMatchColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: TripleMatchColors.ink,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: TripleMatchColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: TripleMatchColors.ink),
      ),
    );
  }
}
