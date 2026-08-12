import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import '../features/game/data/game_ads.dart';
import '../features/game/data/game_analytics.dart';
import '../features/game/data/game_progress_store.dart';

class GameServices {
  const GameServices({
    required this.progressStore,
    required this.analytics,
    required this.ads,
  });

  static const fallback = GameServices(
    progressStore: MethodChannelGameProgressStore(),
    analytics: NoopGameAnalytics(),
    ads: NoopGameAdService(),
  );

  final GameProgressStore progressStore;
  final GameAnalytics analytics;
  final GameAdService ads;

  static Future<GameServices> initialize() async {
    final analytics = await _createAnalytics();
    final ads = GoogleMobileAdsGameAdService(analytics: analytics);

    await analytics.logEvent('app_open', {
      'ads_mode': GameAdConfig.fromEnvironment().modeName,
    });
    unawaited(ads.initialize());

    return GameServices(
      progressStore: const MethodChannelGameProgressStore(),
      analytics: analytics,
      ads: ads,
    );
  }

  static Future<GameAnalytics> _createAnalytics() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      return FirebaseGameAnalytics(FirebaseAnalytics.instance);
    } on Object {
      return const NoopGameAnalytics();
    }
  }
}
