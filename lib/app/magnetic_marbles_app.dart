import 'package:flutter/material.dart';

import '../features/home/presentation/home_screen.dart';

class MagneticMarblesApp extends StatelessWidget {
  const MagneticMarblesApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0EA5E9);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Magnetic Marbles',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
