import 'dart:math';

class PlayerProgress {
  PlayerProgress({
    required this.currentLevelIndex,
    required this.unlockedLevelIndex,
    required Set<int> completedLevelIds,
    required Map<int, int> bestMovesLeftByLevel,
  }) : completedLevelIds = Set.unmodifiable(completedLevelIds),
       bestMovesLeftByLevel = Map.unmodifiable(bestMovesLeftByLevel);

  factory PlayerProgress.initial() {
    return PlayerProgress(
      currentLevelIndex: 0,
      unlockedLevelIndex: 0,
      completedLevelIds: const {},
      bestMovesLeftByLevel: const {},
    );
  }

  final int currentLevelIndex;
  final int unlockedLevelIndex;
  final Set<int> completedLevelIds;
  final Map<int, int> bestMovesLeftByLevel;

  PlayerProgress copyWith({
    int? currentLevelIndex,
    int? unlockedLevelIndex,
    Set<int>? completedLevelIds,
    Map<int, int>? bestMovesLeftByLevel,
  }) {
    return PlayerProgress(
      currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
      unlockedLevelIndex: unlockedLevelIndex ?? this.unlockedLevelIndex,
      completedLevelIds: completedLevelIds ?? this.completedLevelIds,
      bestMovesLeftByLevel: bestMovesLeftByLevel ?? this.bestMovesLeftByLevel,
    );
  }

  PlayerProgress normalized(int levelCount) {
    if (levelCount <= 0) {
      return PlayerProgress.initial();
    }

    final lastIndex = levelCount - 1;
    final safeUnlocked = unlockedLevelIndex.clamp(0, lastIndex).toInt();
    final safeCurrent = currentLevelIndex.clamp(0, safeUnlocked).toInt();

    return copyWith(
      currentLevelIndex: safeCurrent,
      unlockedLevelIndex: safeUnlocked,
      completedLevelIds: completedLevelIds
          .where((levelId) => levelId >= 1 && levelId <= levelCount)
          .toSet(),
      bestMovesLeftByLevel: Map.fromEntries(
        bestMovesLeftByLevel.entries.where(
          (entry) =>
              entry.key >= 1 && entry.key <= levelCount && entry.value >= 0,
        ),
      ),
    );
  }

  PlayerProgress recordCompletion({
    required int levelId,
    required int levelIndex,
    required int levelCount,
    required int movesLeft,
  }) {
    final completed = {...completedLevelIds, levelId};
    final bestMoves = Map<int, int>.of(bestMovesLeftByLevel);
    bestMoves[levelId] = max(bestMoves[levelId] ?? 0, movesLeft);
    final nextIndex = min(levelIndex + 1, levelCount - 1);

    return copyWith(
      currentLevelIndex: max(currentLevelIndex, nextIndex),
      unlockedLevelIndex: max(unlockedLevelIndex, nextIndex),
      completedLevelIds: completed,
      bestMovesLeftByLevel: bestMoves,
    ).normalized(levelCount);
  }
}
