import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/player_progress.dart';

abstract class PuzzleProgressStore {
  Future<PlayerProgress> load();

  Future<void> save(PlayerProgress progress);
}

class SharedPreferencesPuzzleProgressStore implements PuzzleProgressStore {
  static const _currentLevelKey = 'arrow_puzzle.current_level_index';
  static const _unlockedLevelKey = 'arrow_puzzle.unlocked_level_index';
  static const _completedLevelsKey = 'arrow_puzzle.completed_level_ids';
  static const _bestMovesKey = 'arrow_puzzle.best_moves_by_level';
  static const _bestScoreKey = 'arrow_puzzle.best_score_by_level';
  static const _streakDaysKey = 'arrow_puzzle.streak_days';
  static const _hintCountKey = 'arrow_puzzle.hint_count';
  static const _soundEnabledKey = 'arrow_puzzle.sound_enabled';
  static const _hapticsEnabledKey = 'arrow_puzzle.haptics_enabled';
  static const _hasSeenTutorialKey = 'arrow_puzzle.has_seen_tutorial';
  static const _lastCompletionDateKey = 'arrow_puzzle.last_completion_date';
  static const _lastHintClaimDateKey = 'arrow_puzzle.last_hint_claim_date';

  @override
  Future<PlayerProgress> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final bestMovesJson = preferences.getString(_bestMovesKey);
      final bestScoreJson = preferences.getString(_bestScoreKey);

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
        bestMovesByLevel: _decodeIntMap(bestMovesJson),
        bestScoreByLevel: _decodeIntMap(bestScoreJson),
        streakDays: preferences.getInt(_streakDaysKey) ?? 0,
        hintCount: preferences.getInt(_hintCountKey) ?? 1,
        soundEnabled: preferences.getBool(_soundEnabledKey) ?? true,
        hapticsEnabled: preferences.getBool(_hapticsEnabledKey) ?? true,
        hasSeenTutorial: preferences.getBool(_hasSeenTutorialKey) ?? false,
        lastCompletionDate: preferences.getString(_lastCompletionDateKey),
        lastHintClaimDate: preferences.getString(_lastHintClaimDateKey),
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
        _bestMovesKey,
        jsonEncode(_encodeIntMap(progress.bestMovesByLevel)),
      );
      await preferences.setString(
        _bestScoreKey,
        jsonEncode(_encodeIntMap(progress.bestScoreByLevel)),
      );
      await preferences.setInt(_streakDaysKey, progress.streakDays);
      await preferences.setInt(_hintCountKey, progress.hintCount);
      await preferences.setBool(_soundEnabledKey, progress.soundEnabled);
      await preferences.setBool(_hapticsEnabledKey, progress.hapticsEnabled);
      await preferences.setBool(_hasSeenTutorialKey, progress.hasSeenTutorial);

      final lastCompletionDate = progress.lastCompletionDate;
      if (lastCompletionDate == null) {
        await preferences.remove(_lastCompletionDateKey);
      } else {
        await preferences.setString(_lastCompletionDateKey, lastCompletionDate);
      }

      final lastHintClaimDate = progress.lastHintClaimDate;
      if (lastHintClaimDate == null) {
        await preferences.remove(_lastHintClaimDateKey);
      } else {
        await preferences.setString(_lastHintClaimDateKey, lastHintClaimDate);
      }
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
    return values.map((key, value) => MapEntry('$key', value));
  }
}
