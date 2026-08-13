enum ArenaDifficultyPhase { glide, chase, surge }

extension ArenaDifficultyPhaseRules on ArenaDifficultyPhase {
  String get label => switch (this) {
    ArenaDifficultyPhase.glide => 'Glide',
    ArenaDifficultyPhase.chase => 'Chase',
    ArenaDifficultyPhase.surge => 'Surge',
  };

  double get botSpeedScale => switch (this) {
    ArenaDifficultyPhase.glide => 1.0,
    ArenaDifficultyPhase.chase => 1.08,
    ArenaDifficultyPhase.surge => 1.16,
  };

  static ArenaDifficultyPhase fromElapsed(double seconds) {
    if (seconds >= 90) {
      return ArenaDifficultyPhase.surge;
    }
    if (seconds >= 45) {
      return ArenaDifficultyPhase.chase;
    }
    return ArenaDifficultyPhase.glide;
  }
}
