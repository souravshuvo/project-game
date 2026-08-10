import 'package:shared_preferences/shared_preferences.dart';

import '../application/tic_tac_toe_settings.dart';

abstract interface class TicTacToeSettingsStore {
  Future<TicTacToeSettings> load();

  Future<void> save(TicTacToeSettings settings);
}

class SharedPreferencesTicTacToeSettingsStore
    implements TicTacToeSettingsStore {
  static const _soundEnabledKey = 'pocket_observatory.sound_enabled';
  static const _hapticsEnabledKey = 'pocket_observatory.haptics_enabled';

  @override
  Future<TicTacToeSettings> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      return TicTacToeSettings(
        soundEnabled: preferences.getBool(_soundEnabledKey) ?? true,
        hapticsEnabled: preferences.getBool(_hapticsEnabledKey) ?? true,
      );
    } on Object {
      return const TicTacToeSettings.initial();
    }
  }

  @override
  Future<void> save(TicTacToeSettings settings) async {
    try {
      final preferences = await SharedPreferences.getInstance();

      await preferences.setBool(_soundEnabledKey, settings.soundEnabled);
      await preferences.setBool(_hapticsEnabledKey, settings.hapticsEnabled);
    } on Object {
      return;
    }
  }
}
