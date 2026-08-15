import 'package:flutter/widgets.dart';

import '../analytics/game_analytics.dart';

abstract interface class AppAdsController {
  bool get isEnabled;

  Widget buildHomeBanner();

  void preloadInterstitial();

  Future<void> recordCompletedGameBreak({
    required String gameId,
    required String gameTitle,
    required int completedGames,
    required int totalGames,
    required int gameDurationMs,
  });

  void dispose();
}

class NoopAppAdsController implements AppAdsController {
  const NoopAppAdsController({
    this.reason = 'disabled',
    this.adMode = 'disabled',
    this.analytics = const NoopGameAnalytics(),
  });

  final String reason;
  final String adMode;
  final GameAnalytics analytics;

  @override
  bool get isEnabled => false;

  @override
  Widget buildHomeBanner() => const SizedBox.shrink();

  @override
  void preloadInterstitial() {}

  @override
  Future<void> recordCompletedGameBreak({
    required String gameId,
    required String gameTitle,
    required int completedGames,
    required int totalGames,
    required int gameDurationMs,
  }) async {
    analytics.adOpportunity(
      placement: 'completed_game_home_return',
      format: 'interstitial',
      adMode: adMode,
      decision: 'blocked',
      reason: reason,
      gameId: gameId,
      gameTitle: gameTitle,
      completedGames: completedGames,
      totalGames: totalGames,
      gameDurationMs: gameDurationMs,
    );
  }

  @override
  void dispose() {}
}
