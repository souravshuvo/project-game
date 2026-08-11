import 'package:flutter/material.dart';

import 'features/trail_arena/presentation/screens/trail_arena_game_screen.dart';

void main() {
  runApp(const TrailArenaApp());
}

class TrailArenaApp extends StatelessWidget {
  const TrailArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trail Arena',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2DD08A),
          brightness: Brightness.dark,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF65F0B4),
            foregroundColor: const Color(0xFF102116),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const TrailArenaGameScreen(),
    );
  }
}
