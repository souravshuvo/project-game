import 'package:shared_preferences/shared_preferences.dart';

import '../domain/save_data.dart';

abstract class SignalReefSaveStore {
  Future<SignalReefSaveData> load();

  Future<void> save(SignalReefSaveData data);
}

class SharedPreferencesSignalReefSaveStore implements SignalReefSaveStore {
  static const _bestScoreKey = 'signal_reef.best_score';
  static const _soundEnabledKey = 'signal_reef.sound_enabled';
  static const _musicEnabledKey = 'signal_reef.music_enabled';
  static const _hapticsEnabledKey = 'signal_reef.haptics_enabled';
  static const _runsPlayedKey = 'signal_reef.runs_played';

  @override
  Future<SignalReefSaveData> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      return SignalReefSaveData(
        bestScore: preferences.getInt(_bestScoreKey) ?? 0,
        soundEnabled: preferences.getBool(_soundEnabledKey) ?? true,
        musicEnabled: preferences.getBool(_musicEnabledKey) ?? true,
        hapticsEnabled: preferences.getBool(_hapticsEnabledKey) ?? true,
        runsPlayed: preferences.getInt(_runsPlayedKey) ?? 0,
      );
    } on Object {
      return SignalReefSaveData.initial();
    }
  }

  @override
  Future<void> save(SignalReefSaveData data) async {
    try {
      final preferences = await SharedPreferences.getInstance();

      await preferences.setInt(_bestScoreKey, data.bestScore);
      await preferences.setBool(_soundEnabledKey, data.soundEnabled);
      await preferences.setBool(_musicEnabledKey, data.musicEnabled);
      await preferences.setBool(_hapticsEnabledKey, data.hapticsEnabled);
      await preferences.setInt(_runsPlayedKey, data.runsPlayed);
    } on Object {
      return;
    }
  }
}
