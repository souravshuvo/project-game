const String letterTracingGameId = 'letter-tracing';

abstract interface class ProgressRepository {
  Set<String> get completedGameIds;

  bool isGameComplete(String gameId);

  bool get isLetterAComplete;

  bool get soundEnabled;

  Future<void> markLetterAComplete();

  Future<void> markGameComplete(String gameId);

  Future<void> setSoundEnabled(bool enabled);

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
    Set<String> completedGameIds = const <String>{},
  }) : _completedGameIds = <String>{
         ...completedGameIds,
         if (isLetterAComplete) letterTracingGameId,
       },
       _soundEnabled = soundEnabled;

  final Set<String> _completedGameIds;
  bool _soundEnabled;

  @override
  Set<String> get completedGameIds => Set.unmodifiable(_completedGameIds);

  @override
  bool get isLetterAComplete => isGameComplete(letterTracingGameId);

  @override
  bool get soundEnabled => _soundEnabled;

  @override
  Future<void> markLetterAComplete() async {
    await markGameComplete(letterTracingGameId);
  }

  @override
  Future<void> markGameComplete(String gameId) async {
    _completedGameIds.add(gameId);
  }

  @override
  bool isGameComplete(String gameId) {
    return _completedGameIds.contains(gameId);
  }

  @override
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
  }

  @override
  Future<void> reset() async {
    _completedGameIds.clear();
    _soundEnabled = true;
  }
}
