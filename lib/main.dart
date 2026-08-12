import 'dart:async';

import 'package:flutter/material.dart';

import 'app/kids_land_app.dart';
import 'features/tracing/data/hive_progress_repository.dart';
import 'features/tracing/data/progress_repository.dart';
import 'shared/ads/ad_mob_service.dart';
import 'shared/analytics/firebase_game_analytics.dart';
import 'shared/analytics/game_analytics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final progressRepository = await _openProgressRepository();
  final analytics = await FirebaseGameAnalytics.create();
  final adService = AdMobGameAdService(analytics: analytics);
  unawaited(adService.warmUp());
  unawaited(
    analytics.logEvent(GameAnalyticsEvents.appSessionStarted, {
      'game_id': dewBubbleGameId,
      'analytics_enabled': FirebaseGameAnalytics.enabled,
    }),
  );

  runApp(
    KidsLandApp(
      progressRepository: progressRepository,
      analytics: analytics,
      adService: adService,
    ),
  );
}

Future<ProgressRepository> _openProgressRepository() async {
  try {
    return await HiveProgressRepository.open();
  } on Object {
    // Local-storage failure must not lock a young child out of the activity.
    // This process-only fallback intentionally collects and transmits nothing.
    return MemoryProgressRepository();
  }
}
