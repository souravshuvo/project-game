class SaveData {
  const SaveData({
    this.bestScore = 0,
    this.completedChallengeSteps = 0,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
  });

  final int bestScore;
  final int completedChallengeSteps;
  final bool soundEnabled;
  final bool hapticsEnabled;

  SaveData copyWith({
    int? bestScore,
    int? completedChallengeSteps,
    bool? soundEnabled,
    bool? hapticsEnabled,
  }) {
    return SaveData(
      bestScore: bestScore ?? this.bestScore,
      completedChallengeSteps:
          completedChallengeSteps ?? this.completedChallengeSteps,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}
