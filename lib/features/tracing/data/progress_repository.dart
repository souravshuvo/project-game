const String dewBubbleGameId = 'dew-bubble';

abstract interface class ProgressRepository {
  Set<String> get completedGameIds;

  bool isGameComplete(String gameId);

  int get dewBubbleHighestUnlockedLevelIndex;

  bool get soundEnabled;

  bool get hapticsEnabled;

  int dewBubbleBestScore(String levelId);

  int dewBubbleBestStars(String levelId);

  Future<void> markGameComplete(String gameId);

  Future<void> recordDewBubbleLevelWin({
    required int levelIndex,
    required String levelId,
    required int score,
    required int stars,
  });

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
    bool soundEnabled = true,
    bool hapticsEnabled = true,
    Set<String> completedGameIds = const <String>{},
    int dewBubbleHighestUnlockedLevelIndex = 0,
    Map<String, int> dewBubbleBestScores = const <String, int>{},
    Map<String, int> dewBubbleBestStars = const <String, int>{},
  }) : _completedGameIds = <String>{...completedGameIds},
       _soundEnabled = soundEnabled,
       _hapticsEnabled = hapticsEnabled,
       _dewBubbleHighestUnlockedLevelIndex = dewBubbleHighestUnlockedLevelIndex,
       _dewBubbleBestScores = Map<String, int>.of(dewBubbleBestScores),
       _dewBubbleBestStars = Map<String, int>.of(dewBubbleBestStars);

  final Set<String> _completedGameIds;
  final Map<String, int> _dewBubbleBestScores;
  final Map<String, int> _dewBubbleBestStars;
  bool _soundEnabled;
  bool _hapticsEnabled;
  int _dewBubbleHighestUnlockedLevelIndex;

  @override
  Set<String> get completedGameIds => Set.unmodifiable(_completedGameIds);

  @override
  int get dewBubbleHighestUnlockedLevelIndex =>
      _dewBubbleHighestUnlockedLevelIndex;

  @override
  bool get soundEnabled => _soundEnabled;

  @override
  bool get hapticsEnabled => _hapticsEnabled;

  @override
  int dewBubbleBestScore(String levelId) {
    return _dewBubbleBestScores[levelId] ?? 0;
  }

  @override
  int dewBubbleBestStars(String levelId) {
    return _dewBubbleBestStars[levelId] ?? 0;
  }

  @override
  Future<void> markGameComplete(String gameId) async {
    _completedGameIds.add(gameId);
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
    _dewBubbleHighestUnlockedLevelIndex = _maxInt(
      _dewBubbleHighestUnlockedLevelIndex,
      levelIndex + 1,
    );
    _dewBubbleBestScores[levelId] = _maxInt(dewBubbleBestScore(levelId), score);
    _dewBubbleBestStars[levelId] = _maxInt(dewBubbleBestStars(levelId), stars);
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
  Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
  }

  @override
  Future<void> reset() async {
    _completedGameIds.clear();
    _dewBubbleBestScores.clear();
    _dewBubbleBestStars.clear();
    _dewBubbleHighestUnlockedLevelIndex = 0;
    _soundEnabled = true;
    _hapticsEnabled = true;
  }
}

int _maxInt(int a, int b) => a > b ? a : b;
