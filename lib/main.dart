import 'package:flutter/material.dart';

import 'features/game/logic/game_ad_service.dart';
import 'features/game/logic/game_analytics.dart';
import 'features/game/presentation/emoji_chor_police_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final analytics = await GameAnalytics.initialize();
  await analytics.logEvent('session_start');

  final adService = GameAdService(analytics: analytics);
  await adService.initialize();

  runApp(EmojiChorPoliceApp(analytics: analytics, adService: adService));
}
