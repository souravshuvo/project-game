import 'package:flutter/material.dart';

import 'features/tic_tac_toe/data/tic_tac_toe_settings_store.dart';
import 'features/tic_tac_toe/presentation/pocket_observatory_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsStore = SharedPreferencesTicTacToeSettingsStore();
  final initialSettings = await settingsStore.load();

  runApp(
    PocketObservatoryApp(
      settingsStore: settingsStore,
      initialSettings: initialSettings,
    ),
  );
}
