import 'package:flutter/material.dart';

import '../core/ads/app_ads_controller.dart';
import '../core/analytics/analytics_lifecycle_reporter.dart';
import '../core/analytics/game_analytics.dart';
import '../core/audio/letter_audio_cue.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/tracing/data/progress_repository.dart';

class KidsLandApp extends StatelessWidget {
  const KidsLandApp({
    required this.progressRepository,
    required this.audioCue,
    required this.analytics,
    required this.adsController,
    super.key,
  });

  final ProgressRepository progressRepository;
  final LetterAudioCue audioCue;
  final GameAnalytics analytics;
  final AppAdsController adsController;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF7257E8);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );

    return AnalyticsLifecycleReporter(
      analytics: analytics,
      child: MaterialApp(
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
          analytics: analytics,
          adsController: adsController,
        ),
      ),
    );
  }
}
