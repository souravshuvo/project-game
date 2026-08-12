import 'package:flutter/material.dart';

import 'ads/ad_controller.dart';
import '../features/farm/application/clock.dart';
import '../features/farm/application/analytics_events.dart';
import '../features/farm/application/farm_controller.dart';
import '../features/farm/data/farm_save_store.dart';
import '../features/farm/domain/farm_return_report.dart';
import '../features/farm/domain/farm_rules.dart';
import '../features/farm/domain/farm_simulation.dart';
import '../features/farm/domain/farm_state.dart';
import '../features/farm/presentation/farm_screen.dart';
import 'app_theme.dart';
import 'game_feedback.dart';
import 'player_settings.dart';

class FarmLoopApp extends StatefulWidget {
  const FarmLoopApp({
    super.key,
    required this.rules,
    required this.simulation,
    required this.saveStore,
    required this.initialState,
    required this.returnReport,
    required this.clock,
    required this.analytics,
    required this.ads,
  });

  static const title = 'Rooftop Rain Garden';

  final FarmRules rules;
  final FarmSimulation simulation;
  final FarmSaveStore saveStore;
  final FarmState initialState;
  final FarmReturnReport returnReport;
  final Clock clock;
  final FarmAnalytics analytics;
  final AdController ads;

  @override
  State<FarmLoopApp> createState() => _FarmLoopAppState();
}

class _FarmLoopAppState extends State<FarmLoopApp> {
  late final FarmController _controller;
  late final PlayerSettings _settings;
  late final GameFeedback _feedback;

  @override
  void initState() {
    super.initState();
    _settings = PlayerSettings(preferences: widget.saveStore.preferences);
    _feedback = GameFeedback(_settings);
    _controller = FarmController(
      rules: widget.rules,
      simulation: widget.simulation,
      saveStore: widget.saveStore,
      initialState: widget.initialState,
      returnReport: widget.returnReport,
      clock: widget.clock,
      analytics: widget.analytics,
    )..start();
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.ads.dispose();
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FarmLoopApp.title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: FarmScreen(
        controller: _controller,
        settings: _settings,
        feedback: _feedback,
        ads: widget.ads,
      ),
    );
  }
}
