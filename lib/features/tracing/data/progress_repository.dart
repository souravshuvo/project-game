const String letterTracingGameId = 'letter-tracing';

abstract interface class ProgressRepository {
  Set<String> get completedGameIds;

  bool isGameComplete(String gameId);

  Set<String> completedContentIds(String gameId);

  bool isContentComplete(String gameId, String contentId);

  bool get isLetterAComplete;

  bool get soundEnabled;

  bool get hapticsEnabled;

  Future<void> markLetterAComplete();

  Future<void> markGameComplete(String gameId);

  Future<void> markContentComplete(String gameId, String contentId);

  Future<void> setSoundEnabled(bool enabled);

  Future<void> setHapticsEnabled(bool enabled);

  Future<void> reset();
}

/// Keeps the game playable if device storage cannot be opened.
///
/// Production progress normally uses Hive; this fallback deliberately lasts
/// only for the current process and is also useful in widget tests.
class MemoryProgressRepository implements ProgressRepository {
  MemoryProgressRepository({
    bool isLetterAComplete = false,
    bool soundEnabled = true,
    bool hapticsEnabled = true,
    Set<String> completedGameIds = const <String>{},
  }) : _completedGameIds = <String>{
         ...completedGameIds,
         if (isLetterAComplete) letterTracingGameId,
       },
       _soundEnabled = soundEnabled,
       _hapticsEnabled = hapticsEnabled;

  final Set<String> _completedGameIds;
  final Set<String> _completedContentKeys = <String>{};
  bool _soundEnabled;
  bool _hapticsEnabled;

  @override
  Set<String> get completedGameIds => Set.unmodifiable(_completedGameIds);

  @override
  bool get isLetterAComplete => isGameComplete(letterTracingGameId);

  @override
  Set<String> completedContentIds(String gameId) {
    final prefix = _contentKeyPrefix(gameId);
    return Set.unmodifiable(
      _completedContentKeys
          .where((key) => key.startsWith(prefix))
          .map((key) => key.substring(prefix.length)),
    );
  }

  @override
  bool get soundEnabled => _soundEnabled;

  @override
  bool get hapticsEnabled => _hapticsEnabled;

  @override
  Future<void> markLetterAComplete() async {
    await markGameComplete(letterTracingGameId);
  }

  @override
  Future<void> markGameComplete(String gameId) async {
    _completedGameIds.add(gameId);
  }

  @override
  Future<void> markContentComplete(String gameId, String contentId) async {
    final key = _contentKey(gameId, contentId);
    if (key != null) {
      _completedContentKeys.add(key);
    }
  }

  @override
  bool isGameComplete(String gameId) {
    return _completedGameIds.contains(gameId);
  }

  @override
  bool isContentComplete(String gameId, String contentId) {
    final key = _contentKey(gameId, contentId);
    return key != null && _completedContentKeys.contains(key);
  }

  @override
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
  }

  @override
  Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
  }

  @override
  Future<void> reset() async {
    _completedGameIds.clear();
    _completedContentKeys.clear();
    _soundEnabled = true;
    _hapticsEnabled = true;
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
