import 'package:flutter/material.dart';

import 'dew_bubble/dew_bubble_game_screen.dart';
import '../tracing/data/progress_repository.dart';
import '../../shared/ads/game_ad_service.dart';
import '../../shared/analytics/game_analytics.dart';

typedef GameScreenBuilder =
    Widget Function(
      BuildContext context,
      VoidCallback onCompleted,
      ProgressRepository progressRepository,
      GameAnalytics analytics,
      GameAdService adService,
      GameLaunchOptions launchOptions,
    );

@immutable
class GameLaunchOptions {
  const GameLaunchOptions({
    this.initialLevelIndex = 0,
    this.showLevelSelectOnStart = true,
    this.source = 'home',
  });

  final int initialLevelIndex;
  final bool showLevelSelectOnStart;
  final String source;
}

@immutable
class KidsGame {
  const KidsGame({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.builder,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final GameScreenBuilder builder;
}

final List<KidsGame> kidsGameCatalog = List.unmodifiable(<KidsGame>[
  KidsGame(
    id: dewBubbleGameId,
    title: 'Dew Bubble Garden',
    subtitle: 'Aim, bounce, and clear score-chase garden puzzles',
    icon: Icons.bubble_chart_rounded,
    colors: const [Color(0xFF2CB9A0), Color(0xFF67B8F7)],
    builder:
        (
          context,
          onCompleted,
          progressRepository,
          analytics,
          adService,
          launchOptions,
        ) => DewBubbleGameScreen(
          progressRepository: progressRepository,
          analytics: analytics,
          adService: adService,
          onCompleted: onCompleted,
          initialLevelIndex: launchOptions.initialLevelIndex,
          showLevelSelectOnStart: launchOptions.showLevelSelectOnStart,
          launchSource: launchOptions.source,
        ),
  ),
]);
