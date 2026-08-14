class SignalReefSaveData {
  const SignalReefSaveData({
    required this.bestScore,
    required this.bestWaveReached,
    required this.soundEnabled,
    required this.hapticsEnabled,
    required this.runsPlayed,
  });

  factory SignalReefSaveData.initial() {
    return const SignalReefSaveData(
      bestScore: 0,
      bestWaveReached: 0,
      soundEnabled: true,
      hapticsEnabled: true,
      runsPlayed: 0,
    );
  }

  final int bestScore;
  final int bestWaveReached;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final int runsPlayed;

  SignalReefSaveData copyWith({
    int? bestScore,
    int? bestWaveReached,
    bool? soundEnabled,
    bool? hapticsEnabled,
    int? runsPlayed,
  }) {
    return SignalReefSaveData(
      bestScore: bestScore ?? this.bestScore,
      bestWaveReached: bestWaveReached ?? this.bestWaveReached,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      runsPlayed: runsPlayed ?? this.runsPlayed,
    );
  }
}
