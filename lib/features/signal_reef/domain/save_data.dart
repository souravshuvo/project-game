class SignalReefSaveData {
  const SignalReefSaveData({
    required this.bestScore,
    required this.soundEnabled,
    required this.musicEnabled,
    required this.hapticsEnabled,
    required this.runsPlayed,
  });

  factory SignalReefSaveData.initial() {
    return const SignalReefSaveData(
      bestScore: 0,
      soundEnabled: true,
      musicEnabled: true,
      hapticsEnabled: true,
      runsPlayed: 0,
    );
  }

  final int bestScore;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final int runsPlayed;

  SignalReefSaveData copyWith({
    int? bestScore,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    int? runsPlayed,
  }) {
    return SignalReefSaveData(
      bestScore: bestScore ?? this.bestScore,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      runsPlayed: runsPlayed ?? this.runsPlayed,
    );
  }
}
