import 'package:hive_ce_flutter/hive_flutter.dart';

import 'progress_repository.dart';

class HiveProgressRepository implements ProgressRepository {
  HiveProgressRepository._(this._box);

  static const int currentSchemaVersion = 2;
  static const String boxName = 'kidsland_progress';

  static const String _schemaVersionKey = 'schemaVersion';
  static const String _letterACompleteKey = 'letterAComplete';
  static const String _completedGameIdsKey = 'completedGameIds';
  static const String _soundEnabledKey = 'soundEnabled';

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
  bool get isLetterAComplete => isGameComplete(letterTracingGameId);

  @override
  bool get soundEnabled =>
      _box.get(_soundEnabledKey, defaultValue: true) as bool;

  @override
  Future<void> markLetterAComplete() async {
    await markGameComplete(letterTracingGameId);
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
  bool isGameComplete(String gameId) {
    return completedGameIds.contains(gameId);
  }

  @override
  Future<void> setSoundEnabled(bool enabled) async {
    await _box.put(_soundEnabledKey, enabled);
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

    if (storedVersion == 1) {
      final legacyLetterComplete =
          _box.get(_letterACompleteKey, defaultValue: false) as bool;
      final legacySoundEnabled =
          _box.get(_soundEnabledKey, defaultValue: true) as bool;
      await _box.clear();
      await _writeDefaults();
      await _box.put(_soundEnabledKey, legacySoundEnabled);
      if (legacyLetterComplete) {
        await markGameComplete(letterTracingGameId);
      }
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
      _soundEnabledKey: true,
    });
  }
}
