import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/game/domain/board_validator.dart';
import 'src/game/infrastructure/ads/game_ads.dart';
import 'src/game/infrastructure/analytics/game_analytics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BoardValidator.validate().throwIfInvalid();
  final analytics = await GameAnalytics.initialize();
  final ads = await GameAdsController.initialize(analytics);
  runApp(SholoGutiApp(analytics: analytics, ads: ads));
}
