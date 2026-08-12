import 'package:hive_ce_flutter/hive_flutter.dart';

import 'progress_repository.dart';

class HiveProgressRepository implements ProgressRepository {
  HiveProgressRepository._(this._box);

  static const int currentSchemaVersion = 5;
  static const String boxName = 'kidsland_progress';

  static const String _schemaVersionKey = 'schemaVersion';
  static const String _completedGameIdsKey = 'completedGameIds';
  static const String _soundEnabledKey = 'soundEnabled';
  static const String _hapticsEnabledKey = 'hapticsEnabled';
  static const String _dewBubbleHighestUnlockedLevelIndexKey =
      'dewBubbleHighestUnlockedLevelIndex';
  static const String _dewBubbleBestScoresKey = 'dewBubbleBestScores';
  static const String _dewBubbleBestStarsKey = 'dewBubbleBestStars';

  final Box<dynamic> _box;

  static Future<HiveProgressRepository> open() async {
    await Hive.initFlutter('kidsland');
    final box = await Hive.openBox<dynamic>(boxName);
    return create(box);
  }

  static Future<HiveProgressRepository> create(Box<dynamic> box) async {
    final repository = HiveProgressRepository._(box);
    await repository._ensureCurrentSchema();
    return repository;
  }

  @override
  Set<String> get completedGameIds {
    final rawIds = _box.get(
      _completedGameIdsKey,
      defaultValue: const <String>[],
    );
    if (rawIds is! List) {
      return const <String>{};
    }
    return Set.unmodifiable(rawIds.whereType<String>());
  }

  @override
  int get dewBubbleHighestUnlockedLevelIndex {
    final raw = _box.get(
      _dewBubbleHighestUnlockedLevelIndexKey,
      defaultValue: 0,
    );
    return raw is int && raw > 0 ? raw : 0;
  }

  @override
  bool get soundEnabled => _readBool(_soundEnabledKey, defaultValue: true);

  @override
  bool get hapticsEnabled => _readBool(_hapticsEnabledKey, defaultValue: true);

  @override
  int dewBubbleBestScore(String levelId) {
    return _readIntMap(_dewBubbleBestScoresKey)[levelId] ?? 0;
  }

  @override
  int dewBubbleBestStars(String levelId) {
    return _readIntMap(_dewBubbleBestStarsKey)[levelId] ?? 0;
  }

  @override
  Future<void> markGameComplete(String gameId) async {
    if (gameId.trim().isEmpty || isGameComplete(gameId)) {
      return;
    }
    final updatedIds = <String>{...completedGameIds, gameId}.toList()..sort();
    await _box.put(_completedGameIdsKey, updatedIds);
  }

  @override
  Future<void> recordDewBubbleLevelWin({
    required int levelIndex,
    required String levelId,
    required int score,
    required int stars,
  }) async {
    if (levelId.trim().isEmpty) {
      return;
    }

    final highestUnlocked = _maxInt(
      dewBubbleHighestUnlockedLevelIndex,
      levelIndex + 1,
    );
    await _box.put(_dewBubbleHighestUnlockedLevelIndexKey, highestUnlocked);

    final bestScores = _readIntMap(_dewBubbleBestScoresKey);
    bestScores[levelId] = _maxInt(bestScores[levelId] ?? 0, score);
    await _box.put(_dewBubbleBestScoresKey, bestScores);

    final bestStars = _readIntMap(_dewBubbleBestStarsKey);
    bestStars[levelId] = _maxInt(bestStars[levelId] ?? 0, stars);
    await _box.put(_dewBubbleBestStarsKey, bestStars);
  }

  @override
  bool isGameComplete(String gameId) {
    return completedGameIds.contains(gameId);
  }

  @override
  Future<void> setSoundEnabled(bool enabled) async {
    await _box.put(_soundEnabledKey, enabled);
  }

  @override
  Future<void> setHapticsEnabled(bool enabled) async {
    await _box.put(_hapticsEnabledKey, enabled);
  }

  @override
  Future<void> reset() async {
    await _box.clear();
    await _writeDefaults();
  }

  Future<void> _ensureCurrentSchema() async {
    final storedVersion = _box.get(_schemaVersionKey) as int?;
    if (storedVersion == currentSchemaVersion) {
      return;
    }

    if (storedVersion == 3 || storedVersion == 4) {
      final completedIds = completedGameIds.toList()..sort();
      final soundEnabled = this.soundEnabled;
      final hapticsEnabled = this.hapticsEnabled;
      final highestUnlocked = dewBubbleHighestUnlockedLevelIndex;
      final bestScores = _readIntMap(_dewBubbleBestScoresKey);
      final bestStars = _readIntMap(_dewBubbleBestStarsKey);
      await _box.clear();
      await _writeDefaults();
      await _box.put(
        _completedGameIdsKey,
        completedIds.where((id) => id == dewBubbleGameId).toList(),
      );
      await _box.put(_soundEnabledKey, soundEnabled);
      await _box.put(_hapticsEnabledKey, hapticsEnabled);
      await _box.put(_dewBubbleHighestUnlockedLevelIndexKey, highestUnlocked);
      await _box.put(_dewBubbleBestScoresKey, bestScores);
      await _box.put(_dewBubbleBestStarsKey, bestStars);
      return;
    }

    if (storedVersion == 1 || storedVersion == 2) {
      final legacySoundEnabled = _readBool(
        _soundEnabledKey,
        defaultValue: true,
      );
      final legacyHapticsEnabled = _readBool(
        _hapticsEnabledKey,
        defaultValue: true,
      );
      await _box.clear();
      await _writeDefaults();
      await _box.put(_soundEnabledKey, legacySoundEnabled);
      await _box.put(_hapticsEnabledKey, legacyHapticsEnabled);
      return;
    }

    // This is the first schema. Unknown data is safer to discard than to
    // interpret as a child's progress under the wrong format.
    await _box.clear();
    await _writeDefaults();
  }

  Future<void> _writeDefaults() {
    return _box.putAll(<String, Object>{
      _schemaVersionKey: currentSchemaVersion,
      _completedGameIdsKey: <String>[],
      _dewBubbleHighestUnlockedLevelIndexKey: 0,
      _dewBubbleBestScoresKey: <String, int>{},
      _dewBubbleBestStarsKey: <String, int>{},
      _soundEnabledKey: true,
      _hapticsEnabledKey: true,
    });
  }

  bool _readBool(String key, {required bool defaultValue}) {
    final raw = _box.get(key, defaultValue: defaultValue);
    return raw is bool ? raw : defaultValue;
  }

  Map<String, int> _readIntMap(String key) {
    final raw = _box.get(key, defaultValue: const <String, int>{});
    if (raw is! Map) {
      return <String, int>{};
    }

    return <String, int>{
      for (final entry in raw.entries)
        if (entry.key is String && entry.value is int)
          entry.key as String: entry.value as int,
    };
  }
}

int _maxInt(int a, int b) => a > b ? a : b;
