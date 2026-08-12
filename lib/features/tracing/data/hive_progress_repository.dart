import 'package:hive_ce_flutter/hive_flutter.dart';

import 'progress_repository.dart';

class HiveProgressRepository implements ProgressRepository {
  HiveProgressRepository._(this._box);

  static const int currentSchemaVersion = 4;
  static const String boxName = 'kidsland_progress';

  static const String _schemaVersionKey = 'schemaVersion';
  static const String _letterACompleteKey = 'letterAComplete';
  static const String _completedGameIdsKey = 'completedGameIds';
  static const String _completedContentIdsKey = 'completedContentIds';
  static const String _soundEnabledKey = 'soundEnabled';
  static const String _hapticsEnabledKey = 'hapticsEnabled';

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
    return _readStringSet(_completedGameIdsKey);
  }

  @override
  Set<String> completedContentIds(String gameId) {
    final prefix = _contentKeyPrefix(gameId);
    return Set.unmodifiable(
      _readStringSet(_completedContentIdsKey)
          .where((key) => key.startsWith(prefix))
          .map((key) => key.substring(prefix.length)),
    );
  }

  @override
  bool get isLetterAComplete => isGameComplete(letterTracingGameId);

  @override
  bool get soundEnabled => _readBool(_soundEnabledKey, defaultValue: true);

  @override
  bool get hapticsEnabled => _readBool(_hapticsEnabledKey, defaultValue: true);

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
  Future<void> markContentComplete(String gameId, String contentId) async {
    final key = _contentKey(gameId, contentId);
    if (key == null || isContentComplete(gameId, contentId)) {
      return;
    }
    final updatedIds = <String>{
      ..._readStringSet(_completedContentIdsKey),
      key,
    }.toList()..sort();
    await _box.put(_completedContentIdsKey, updatedIds);
  }

  @override
  bool isGameComplete(String gameId) {
    return completedGameIds.contains(gameId);
  }

  @override
  bool isContentComplete(String gameId, String contentId) {
    final key = _contentKey(gameId, contentId);
    return key != null && _readStringSet(_completedContentIdsKey).contains(key);
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

    if (storedVersion == 3) {
      final legacyCompletedGameIds = completedGameIds.toList()..sort();
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
      await _box.put(_completedGameIdsKey, legacyCompletedGameIds);
      await _box.put(_soundEnabledKey, legacySoundEnabled);
      await _box.put(_hapticsEnabledKey, legacyHapticsEnabled);
      return;
    }

    if (storedVersion == 2) {
      final legacyCompletedGameIds = completedGameIds.toList()..sort();
      final legacySoundEnabled = _readBool(
        _soundEnabledKey,
        defaultValue: true,
      );
      await _box.clear();
      await _writeDefaults();
      await _box.put(_completedGameIdsKey, legacyCompletedGameIds);
      await _box.put(_soundEnabledKey, legacySoundEnabled);
      return;
    }

    if (storedVersion == 1) {
      final legacyLetterComplete = _readBool(
        _letterACompleteKey,
        defaultValue: false,
      );
      final legacySoundEnabled = _readBool(
        _soundEnabledKey,
        defaultValue: true,
      );
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
      _completedContentIdsKey: <String>[],
      _soundEnabledKey: true,
      _hapticsEnabledKey: true,
    });
  }

  Set<String> _readStringSet(String key) {
    final rawIds = _box.get(key, defaultValue: const <String>[]);
    if (rawIds is! List) {
      return const <String>{};
    }
    return Set.unmodifiable(rawIds.whereType<String>());
  }

  bool _readBool(String key, {required bool defaultValue}) {
    final rawValue = _box.get(key, defaultValue: defaultValue);
    return rawValue is bool ? rawValue : defaultValue;
  }

  static String _contentKeyPrefix(String gameId) => '${gameId.trim()}::';

  static String? _contentKey(String gameId, String contentId) {
    final trimmedGameId = gameId.trim();
    final trimmedContentId = contentId.trim();
    if (trimmedGameId.isEmpty ||
        trimmedContentId.isEmpty ||
        trimmedGameId.contains('::') ||
        trimmedContentId.contains('::')) {
      return null;
    }
    return '$trimmedGameId::$trimmedContentId';
  }
}
