import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/player_progress.dart';

abstract interface class MatchProgressStore {
  Future<PlayerProgress> load();

  Future<void> save(PlayerProgress progress);
}

class SharedPreferencesMatchProgressStore implements MatchProgressStore {
  static const _currentLevelKey = 'signal_workshop.current_level_index';
  static const _unlockedLevelKey = 'signal_workshop.unlocked_level_index';
  static const _completedLevelsKey = 'signal_workshop.completed_level_ids';
  static const _bestMovesLeftKey = 'signal_workshop.best_moves_left_by_level';

  @override
  Future<PlayerProgress> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return PlayerProgress(
        currentLevelIndex: preferences.getInt(_currentLevelKey) ?? 0,
        unlockedLevelIndex: preferences.getInt(_unlockedLevelKey) ?? 0,
        completedLevelIds:
            preferences
                .getStringList(_completedLevelsKey)
                ?.map(int.tryParse)
                .nonNulls
                .toSet() ??
            const {},
        bestMovesLeftByLevel: _decodeIntMap(
          preferences.getString(_bestMovesLeftKey),
        ),
      );
    } on Object {
      return PlayerProgress.initial();
    }
  }

  @override
  Future<void> save(PlayerProgress progress) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt(_currentLevelKey, progress.currentLevelIndex);
      await preferences.setInt(_unlockedLevelKey, progress.unlockedLevelIndex);
      await preferences.setStringList(
        _completedLevelsKey,
        progress.completedLevelIds.map((levelId) => '$levelId').toList(),
      );
      await preferences.setString(
        _bestMovesLeftKey,
        jsonEncode(_encodeIntMap(progress.bestMovesLeftByLevel)),
      );
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

  Map<String, int> _encodeIntMap(Map<int, int> value) {
    return value.map((key, value) => MapEntry('$key', value));
  }
}
