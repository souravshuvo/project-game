import 'dart:async';

import 'package:flutter/material.dart';

import 'ads/ad_service.dart';
import 'analytics/analytics_service.dart';
import 'app/game_settings.dart';
import 'ui/main_menu_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final analytics = AnalyticsService();
  await analytics.initialize();

  final ads = AdService(analytics: analytics);
  unawaited(ads.initialize());

  runApp(RooftopCurveApp(analytics: analytics, ads: ads));
}

class RooftopCurveApp extends StatefulWidget {
  const RooftopCurveApp({
    super.key,
    required this.analytics,
    required this.ads,
  });

  final AnalyticsService analytics;
  final AdService ads;

  @override
  State<RooftopCurveApp> createState() => _RooftopCurveAppState();
}

class _RooftopCurveAppState extends State<RooftopCurveApp>
    with WidgetsBindingObserver {
  final GameSettings _settings = GameSettings();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(widget.analytics.logAppOpen());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(widget.analytics.logSessionResume());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(widget.analytics.logSessionPause());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.ads.dispose();
    unawaited(widget.analytics.logSessionPause());
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rooftop Curve',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D8F78),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: MainMenuScreen(
        settings: _settings,
        analytics: widget.analytics,
        ads: widget.ads,
      ),
    );
  }
}
