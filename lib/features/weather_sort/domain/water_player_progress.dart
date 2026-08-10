class WaterPlayerProgress {
  WaterPlayerProgress({
    required this.currentLevelIndex,
    required this.unlockedLevelIndex,
    required Set<int> completedLevelIds,
    required Map<int, int> bestMovesByLevel,
    required Map<int, int> bestStarsByLevel,
    required this.soundEnabled,
    required this.hapticsEnabled,
  }) : completedLevelIds = Set.unmodifiable(completedLevelIds),
       bestMovesByLevel = Map.unmodifiable(bestMovesByLevel),
       bestStarsByLevel = Map.unmodifiable(bestStarsByLevel);

  factory WaterPlayerProgress.initial() {
    return WaterPlayerProgress(
      currentLevelIndex: 0,
      unlockedLevelIndex: 0,
      completedLevelIds: const {},
      bestMovesByLevel: const {},
      bestStarsByLevel: const {},
      soundEnabled: true,
      hapticsEnabled: true,
    );
  }

  final int currentLevelIndex;
  final int unlockedLevelIndex;
  final Set<int> completedLevelIds;
  final Map<int, int> bestMovesByLevel;
  final Map<int, int> bestStarsByLevel;
  final bool soundEnabled;
  final bool hapticsEnabled;

  WaterPlayerProgress copyWith({
    int? currentLevelIndex,
    int? unlockedLevelIndex,
    Set<int>? completedLevelIds,
    Map<int, int>? bestMovesByLevel,
    Map<int, int>? bestStarsByLevel,
    bool? soundEnabled,
    bool? hapticsEnabled,
  }) {
    return WaterPlayerProgress(
      currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
      unlockedLevelIndex: unlockedLevelIndex ?? this.unlockedLevelIndex,
      completedLevelIds: completedLevelIds ?? this.completedLevelIds,
      bestMovesByLevel: bestMovesByLevel ?? this.bestMovesByLevel,
      bestStarsByLevel: bestStarsByLevel ?? this.bestStarsByLevel,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  WaterPlayerProgress normalized(int totalLevels) {
    if (totalLevels <= 0) {
      return WaterPlayerProgress.initial();
    }

    final lastIndex = totalLevels - 1;
    final safeUnlocked = unlockedLevelIndex.clamp(0, lastIndex).toInt();
    final safeCurrent = currentLevelIndex.clamp(0, safeUnlocked).toInt();

    return copyWith(
      currentLevelIndex: safeCurrent,
      unlockedLevelIndex: safeUnlocked,
    );
  }
}
