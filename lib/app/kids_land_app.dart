import 'package:flutter/material.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/tracing/data/progress_repository.dart';
import '../shared/ads/game_ad_service.dart';
import '../shared/analytics/game_analytics.dart';

class KidsLandApp extends StatelessWidget {
  const KidsLandApp({
    required this.progressRepository,
    this.analytics = const NoopGameAnalytics(),
    this.adService = const NoopGameAdService(),
    super.key,
  });

  final ProgressRepository progressRepository;
  final GameAnalytics analytics;
  final GameAdService adService;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF7257E8);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Dew Bubble',
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
        analytics: analytics,
        adService: adService,
      ),
    );
  }
}
