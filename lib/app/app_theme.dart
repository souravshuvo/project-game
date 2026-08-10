import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const seedGreen = Color(0xFF406B36);
    const soilBrown = Color(0xFF6D4B31);
    const fieldPaper = Color(0xFFF6F0E7);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedGreen,
        primary: seedGreen,
        secondary: soilBrown,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: fieldPaper,
      appBarTheme: const AppBarTheme(
        backgroundColor: fieldPaper,
        foregroundColor: Color(0xFF253521),
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF36552E),
          side: const BorderSide(color: Color(0xFFBDAA8E)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      chipTheme: const ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF273B29),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
