import 'dart:async';

import 'package:flutter/material.dart';

import 'features/tic_tac_toe/application/tic_tac_toe_telemetry.dart';
import 'features/tic_tac_toe/data/firebase_tic_tac_toe_telemetry.dart';
import 'features/tic_tac_toe/data/google_mobile_ads_tic_tac_toe_ad_service.dart';
import 'features/tic_tac_toe/data/tic_tac_toe_match_history_store.dart';
import 'features/tic_tac_toe/data/tic_tac_toe_session_store.dart';
import 'features/tic_tac_toe/data/tic_tac_toe_settings_store.dart';
import 'features/tic_tac_toe/presentation/pocket_observatory_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsStore = SharedPreferencesTicTacToeSettingsStore();
  final matchHistoryStore = SharedPreferencesTicTacToeMatchHistoryStore();
  final sessionStore = SharedPreferencesTicTacToeSessionStore();
  final telemetry = await FirebaseTicTacToeTelemetry.createOrNoOp();
  final adService = GoogleMobileAdsTicTacToeAdService(telemetry: telemetry);
  final initialSettings = await settingsStore.load();
  final initialRecentMatches = await matchHistoryStore.loadRecentMatches();
  final sessionMetrics = await sessionStore.recordOpen(DateTime.now());

  telemetry.track(
    TicTacToeTelemetryEvents.appSessionStarted(
      openCount: sessionMetrics.openCount,
      daysSinceFirstOpen: sessionMetrics.daysSinceFirstOpen,
      daysSincePreviousOpen: sessionMetrics.daysSincePreviousOpen,
      usesTestAds: adService.usesTestAds,
    ),
  );
  unawaited(adService.initialize());

  runApp(
    PocketObservatoryApp(
      settingsStore: settingsStore,
      matchHistoryStore: matchHistoryStore,
      initialSettings: initialSettings,
      initialRecentMatches: initialRecentMatches,
      telemetry: telemetry,
      adService: adService,
    ),
  );
}
