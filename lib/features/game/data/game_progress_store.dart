import 'dart:convert';

import 'package:flutter/services.dart';

class GameProgress {
  const GameProgress({
    required this.unlockedLevelNumber,
    this.bestStarsByLevel = const <int, int>{},
    this.bestScoresByLevel = const <int, int>{},
  });

  factory GameProgress.initial() {
    return const GameProgress(unlockedLevelNumber: 1);
  }

  factory GameProgress.fromJson(
    Map<String, Object?> json, {
    required int levelCount,
  }) {
    return GameProgress(
      unlockedLevelNumber: _clampLevel(
        _readInt(json['unlockedLevelNumber'], fallback: 1),
        levelCount,
      ),
      bestStarsByLevel: _readIntMap(json['bestStarsByLevel'], levelCount),
      bestScoresByLevel: _readIntMap(json['bestScoresByLevel'], levelCount),
    );
  }

  final int unlockedLevelNumber;
  final Map<int, int> bestStarsByLevel;
  final Map<int, int> bestScoresByLevel;

  int get totalStars {
    return bestStarsByLevel.values.fold<int>(
      0,
      (total, stars) => total + stars,
    );
  }

  bool isUnlocked(int levelNumber) {
    return levelNumber <= unlockedLevelNumber;
  }

  int bestStarsFor(int levelNumber) {
    return bestStarsByLevel[levelNumber] ?? 0;
  }

  int bestScoreFor(int levelNumber) {
    return bestScoresByLevel[levelNumber] ?? 0;
  }

  int nextPlayableLevelIndex(int levelCount) {
    for (
      var levelNumber = 1;
      levelNumber <= unlockedLevelNumber;
      levelNumber++
    ) {
      if (bestStarsFor(levelNumber) == 0) {
        return levelNumber - 1;
      }
    }

    return (_clampLevel(unlockedLevelNumber, levelCount) - 1)
        .clamp(0, levelCount - 1)
        .toInt();
  }

  GameProgress recordWin({
    required int levelNumber,
    required int score,
    required int stars,
    required int levelCount,
  }) {
    final clampedLevel = _clampLevel(levelNumber, levelCount);
    final nextStars = Map<int, int>.of(bestStarsByLevel);
    final nextScores = Map<int, int>.of(bestScoresByLevel);
    final clampedStars = stars.clamp(1, 3).toInt();

    nextStars[clampedLevel] = [
      bestStarsFor(clampedLevel),
      clampedStars,
    ].reduce((a, b) => a > b ? a : b);
    nextScores[clampedLevel] = [
      bestScoreFor(clampedLevel),
      score,
    ].reduce((a, b) => a > b ? a : b);

    final nextUnlocked = clampedLevel >= unlockedLevelNumber
        ? _clampLevel(clampedLevel + 1, levelCount)
        : _clampLevel(unlockedLevelNumber, levelCount);

    return GameProgress(
      unlockedLevelNumber: nextUnlocked,
      bestStarsByLevel: Map<int, int>.unmodifiable(nextStars),
      bestScoresByLevel: Map<int, int>.unmodifiable(nextScores),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'unlockedLevelNumber': unlockedLevelNumber,
      'bestStarsByLevel': _writeIntMap(bestStarsByLevel),
      'bestScoresByLevel': _writeIntMap(bestScoresByLevel),
    };
  }

  static int _clampLevel(int levelNumber, int levelCount) {
    return levelNumber.clamp(1, levelCount).toInt();
  }

  static int _readInt(Object? value, {required int fallback}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }

  static Map<int, int> _readIntMap(Object? value, int levelCount) {
    if (value is! Map) {
      return const <int, int>{};
    }

    final result = <int, int>{};
    for (final entry in value.entries) {
      final key = int.tryParse('${entry.key}');
      if (key == null || key < 1 || key > levelCount) {
        continue;
      }

      result[key] = _readInt(entry.value, fallback: 0);
    }

    return Map<int, int>.unmodifiable(result);
  }

  static Map<String, int> _writeIntMap(Map<int, int> value) {
    return {for (final entry in value.entries) '${entry.key}': entry.value};
  }
}

abstract class GameProgressStore {
  Future<GameProgress> load({required int levelCount});

  Future<void> save(GameProgress progress);
}

class MethodChannelGameProgressStore implements GameProgressStore {
  const MethodChannelGameProgressStore();

  static const MethodChannel _channel = MethodChannel(
    'magnetic_marbles/progress',
  );

  @override
  Future<GameProgress> load({required int levelCount}) async {
    try {
      final payload = await _channel.invokeMethod<String>('loadProgress');
      if (payload == null || payload.isEmpty) {
        return GameProgress.initial();
      }

      final decoded = jsonDecode(payload);
      if (decoded is! Map) {
        return GameProgress.initial();
      }

      return GameProgress.fromJson(
        Map<String, Object?>.from(decoded),
        levelCount: levelCount,
      );
    } on Object {
      return GameProgress.initial();
    }
  }

  @override
  Future<void> save(GameProgress progress) async {
    try {
      await _channel.invokeMethod<void>(
        'saveProgress',
        jsonEncode(progress.toJson()),
      );
    } on Object {
      // Missing platform persistence must not block offline play.
    }
  }
}
