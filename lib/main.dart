import 'package:flutter/material.dart';

import 'ui/main_menu_screen.dart';

void main() {
  runApp(const RooftopCurveApp());
}

class RooftopCurveApp extends StatelessWidget {
  const RooftopCurveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rooftop Curve',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D8F78),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}
