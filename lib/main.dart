import 'package:flutter/material.dart';

import 'app_services.dart';
import 'features/trail_arena/presentation/screens/trail_arena_game_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await AppServices.initialize();
  runApp(TrailArenaApp(services: services));
}

class TrailArenaApp extends StatelessWidget {
  const TrailArenaApp({super.key, required this.services});

  final AppServices services;

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
      home: TrailArenaGameScreen(
        analytics: services.analytics,
        ads: services.ads,
      ),
    );
  }
}
