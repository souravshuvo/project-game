import 'package:flutter/material.dart';

import '../ai/balanced_ai_strategy.dart';
import '../application/tic_tac_toe_controller.dart';
import '../application/tic_tac_toe_ad_service.dart';
import '../application/tic_tac_toe_settings.dart';
import '../application/tic_tac_toe_telemetry.dart';
import '../data/tic_tac_toe_match_history_store.dart';
import '../data/tic_tac_toe_settings_store.dart';
import '../domain/match_record.dart';
import '../domain/tic_tac_toe_engine.dart';
import 'pages/game_page.dart';
import 'pages/help_page.dart';
import 'pages/settings_page.dart';
import 'pages/setup_page.dart';
import 'theme/pocket_observatory_theme.dart';

class PocketObservatoryApp extends StatefulWidget {
  const PocketObservatoryApp({
    super.key,
    required this.settingsStore,
    required this.matchHistoryStore,
    required this.initialSettings,
    required this.initialRecentMatches,
    required this.telemetry,
    required this.adService,
  });

  final TicTacToeSettingsStore settingsStore;
  final TicTacToeMatchHistoryStore matchHistoryStore;
  final TicTacToeSettings initialSettings;
  final List<MatchRecord> initialRecentMatches;
  final TicTacToeTelemetry telemetry;
  final TicTacToeAdService adService;

  @override
  State<PocketObservatoryApp> createState() => _PocketObservatoryAppState();
}

class _PocketObservatoryAppState extends State<PocketObservatoryApp> {
  late final TicTacToeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TicTacToeController(
      engine: const TicTacToeEngine(),
      aiStrategy: const BalancedAiStrategy(),
      settingsStore: widget.settingsStore,
      matchHistoryStore: widget.matchHistoryStore,
      initialSettings: widget.initialSettings,
      initialRecentMatches: widget.initialRecentMatches,
      telemetry: widget.telemetry,
      adService: widget.adService,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'Tik Tak Toe',
          debugShowCheckedModeBanner: false,
          theme: PocketObservatoryTheme.light(),
          home: switch (_controller.screen) {
            TicTacToeScreen.setup => SetupPage(controller: _controller),
            TicTacToeScreen.playing => GamePage(controller: _controller),
            TicTacToeScreen.settings => SettingsPage(controller: _controller),
            TicTacToeScreen.help => HelpPage(controller: _controller),
          },
        );
      },
    );
  }
}
