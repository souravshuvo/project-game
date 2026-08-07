import 'package:flutter/material.dart';

import '../core/audio/letter_audio_cue.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/tracing/data/progress_repository.dart';

class KidsLandApp extends StatelessWidget {
  const KidsLandApp({
    required this.progressRepository,
    required this.audioCue,
    super.key,
  });

  final ProgressRepository progressRepository;
  final LetterAudioCue audioCue;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF7257E8);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'KidsLand',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFFFFBF4),
        useMaterial3: true,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
      ),
      home: HomeScreen(
        progressRepository: progressRepository,
        audioCue: audioCue,
      ),
    );
  }
}
