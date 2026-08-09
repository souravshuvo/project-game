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
  static const _streakDaysKey = 'arrow_puzzle.streak_days';
  static const _hintCountKey = 'arrow_puzzle.hint_count';
  static const _soundEnabledKey = 'arrow_puzzle.sound_enabled';
  static const _hapticsEnabledKey = 'arrow_puzzle.haptics_enabled';
  static const _lastCompletionDateKey = 'arrow_puzzle.last_completion_date';
  static const _lastHintClaimDateKey = 'arrow_puzzle.last_hint_claim_date';

  @override
  Future<PlayerProgress> load() async {
    final preferences = await SharedPreferences.getInstance();
    final bestMovesJson = preferences.getString(_bestMovesKey);

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
      bestMovesByLevel: _decodeBestMoves(bestMovesJson),
      streakDays: preferences.getInt(_streakDaysKey) ?? 0,
      hintCount: preferences.getInt(_hintCountKey) ?? 1,
      soundEnabled: preferences.getBool(_soundEnabledKey) ?? true,
      hapticsEnabled: preferences.getBool(_hapticsEnabledKey) ?? true,
      lastCompletionDate: preferences.getString(_lastCompletionDateKey),
      lastHintClaimDate: preferences.getString(_lastHintClaimDateKey),
    );
  }

  @override
  Future<void> save(PlayerProgress progress) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setInt(_currentLevelKey, progress.currentLevelIndex);
    await preferences.setInt(_unlockedLevelKey, progress.unlockedLevelIndex);
    await preferences.setStringList(
      _completedLevelsKey,
      progress.completedLevelIds.map((levelId) => '$levelId').toList(),
    );
    await preferences.setString(
      _bestMovesKey,
      jsonEncode(_encodeBestMoves(progress.bestMovesByLevel)),
    );
    await preferences.setInt(_streakDaysKey, progress.streakDays);
    await preferences.setInt(_hintCountKey, progress.hintCount);
    await preferences.setBool(_soundEnabledKey, progress.soundEnabled);
    await preferences.setBool(_hapticsEnabledKey, progress.hapticsEnabled);

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
  }

  Map<int, int> _decodeBestMoves(String? value) {
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

  Map<String, int> _encodeBestMoves(Map<int, int> bestMovesByLevel) {
    return bestMovesByLevel.map((key, value) {
      return MapEntry('$key', value);
    });
  }
}
