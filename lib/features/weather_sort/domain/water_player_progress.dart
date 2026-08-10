class WaterPlayerProgress {
  WaterPlayerProgress({
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
      completedLevelIds: const {},
      bestMovesByLevel: const {},
      bestStarsByLevel: const {},
      soundEnabled: true,
      hapticsEnabled: true,
    );
  }

  final Set<int> completedLevelIds;
  final Map<int, int> bestMovesByLevel;
  final Map<int, int> bestStarsByLevel;
  final bool soundEnabled;
  final bool hapticsEnabled;

  WaterPlayerProgress copyWith({
    Set<int>? completedLevelIds,
    Map<int, int>? bestMovesByLevel,
    Map<int, int>? bestStarsByLevel,
    bool? soundEnabled,
    bool? hapticsEnabled,
  }) {
    return WaterPlayerProgress(
      completedLevelIds: completedLevelIds ?? this.completedLevelIds,
      bestMovesByLevel: bestMovesByLevel ?? this.bestMovesByLevel,
      bestStarsByLevel: bestStarsByLevel ?? this.bestStarsByLevel,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}
