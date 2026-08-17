class PlayerProgress {
  PlayerProgress({
    required this.currentLevelIndex,
    required this.unlockedLevelIndex,
    required Set<int> completedLevelIds,
    required Map<int, int> bestMovesByLevel,
    required Map<int, int> bestScoreByLevel,
    required this.streakDays,
    required this.hintCount,
    required this.soundEnabled,
    required this.hapticsEnabled,
    this.hasSeenTutorial = false,
    this.lastCompletionDate,
    this.lastHintClaimDate,
  }) : completedLevelIds = Set.unmodifiable(completedLevelIds),
       bestMovesByLevel = Map.unmodifiable(bestMovesByLevel),
       bestScoreByLevel = Map.unmodifiable(bestScoreByLevel);

  factory PlayerProgress.initial() {
    return PlayerProgress(
      currentLevelIndex: 0,
      unlockedLevelIndex: 0,
      completedLevelIds: const {},
      bestMovesByLevel: const {},
      bestScoreByLevel: const {},
      streakDays: 0,
      hintCount: 1,
      soundEnabled: true,
      hapticsEnabled: true,
    );
  }

  final int currentLevelIndex;
  final int unlockedLevelIndex;
  final Set<int> completedLevelIds;
  final Map<int, int> bestMovesByLevel;
  final int streakDays;
  final int hintCount;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final Map<int, int> bestScoreByLevel;
  final bool hasSeenTutorial;
  final String? lastCompletionDate;
  final String? lastHintClaimDate;

  PlayerProgress copyWith({
    int? currentLevelIndex,
    int? unlockedLevelIndex,
    Set<int>? completedLevelIds,
    Map<int, int>? bestMovesByLevel,
    int? streakDays,
    int? hintCount,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? hasSeenTutorial,
    Map<int, int>? bestScoreByLevel,
    String? lastCompletionDate,
    String? lastHintClaimDate,
  }) {
    return PlayerProgress(
      currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
      unlockedLevelIndex: unlockedLevelIndex ?? this.unlockedLevelIndex,
      completedLevelIds: completedLevelIds ?? this.completedLevelIds,
      bestMovesByLevel: bestMovesByLevel ?? this.bestMovesByLevel,
      bestScoreByLevel: bestScoreByLevel ?? this.bestScoreByLevel,
      streakDays: streakDays ?? this.streakDays,
      hintCount: hintCount ?? this.hintCount,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      hasSeenTutorial: hasSeenTutorial ?? this.hasSeenTutorial,
      lastCompletionDate: lastCompletionDate ?? this.lastCompletionDate,
      lastHintClaimDate: lastHintClaimDate ?? this.lastHintClaimDate,
    );
  }

  PlayerProgress normalized(int totalLevels) {
    if (totalLevels <= 0) {
      return PlayerProgress.initial();
    }

    final lastIndex = totalLevels - 1;
    final safeUnlocked = unlockedLevelIndex.clamp(0, lastIndex).toInt();
    final safeCurrent = currentLevelIndex.clamp(0, safeUnlocked).toInt();

    return copyWith(
      currentLevelIndex: safeCurrent,
      unlockedLevelIndex: safeUnlocked,
      hintCount: hintCount.clamp(0, 99).toInt(),
    );
  }
}
