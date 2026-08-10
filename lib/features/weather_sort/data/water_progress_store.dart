import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/water_player_progress.dart';

abstract class WaterProgressStore {
  Future<WaterPlayerProgress> load();

  Future<void> save(WaterPlayerProgress progress);
}

class SharedPreferencesWaterProgressStore implements WaterProgressStore {
  static const _completedLevelsKey = 'weather_sort.completed_level_ids';
  static const _bestMovesKey = 'weather_sort.best_moves_by_level';
  static const _bestStarsKey = 'weather_sort.best_stars_by_level';
  static const _soundEnabledKey = 'weather_sort.sound_enabled';
  static const _hapticsEnabledKey = 'weather_sort.haptics_enabled';

  @override
  Future<WaterPlayerProgress> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      return WaterPlayerProgress(
        completedLevelIds:
            preferences
                .getStringList(_completedLevelsKey)
                ?.map(int.tryParse)
                .nonNulls
                .toSet() ??
            const {},
        bestMovesByLevel: _decodeIntMap(preferences.getString(_bestMovesKey)),
        bestStarsByLevel: _decodeIntMap(preferences.getString(_bestStarsKey)),
        soundEnabled: preferences.getBool(_soundEnabledKey) ?? true,
        hapticsEnabled: preferences.getBool(_hapticsEnabledKey) ?? true,
      );
    } on Object {
      return WaterPlayerProgress.initial();
    }
  }

  @override
  Future<void> save(WaterPlayerProgress progress) async {
    try {
      final preferences = await SharedPreferences.getInstance();

      await preferences.setStringList(
        _completedLevelsKey,
        progress.completedLevelIds.map((levelId) => '$levelId').toList(),
      );
      await preferences.setString(
        _bestMovesKey,
        jsonEncode(_encodeIntMap(progress.bestMovesByLevel)),
      );
      await preferences.setString(
        _bestStarsKey,
        jsonEncode(_encodeIntMap(progress.bestStarsByLevel)),
      );
      await preferences.setBool(_soundEnabledKey, progress.soundEnabled);
      await preferences.setBool(_hapticsEnabledKey, progress.hapticsEnabled);
    } on Object {
      return;
    }
  }

  Map<int, int> _decodeIntMap(String? value) {
    if (value == null || value.isEmpty) {
      return const {};
    }

    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) {
      return const {};
    }

    return decoded.map((key, value) {
      return MapEntry(int.parse(key), value as int);
    });
  }

  Map<String, int> _encodeIntMap(Map<int, int> values) {
    return values.map((key, value) {
      return MapEntry('$key', value);
    });
  }
}
