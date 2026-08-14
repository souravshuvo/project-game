class SignalReefRunResult {
  const SignalReefRunResult({
    required this.score,
    required this.waveReached,
    required this.wavesCleared,
    required this.durationSeconds,
    required this.hullRemaining,
    required this.won,
  });

  final int score;
  final int waveReached;
  final int wavesCleared;
  final int durationSeconds;
  final int hullRemaining;
  final bool won;
}
