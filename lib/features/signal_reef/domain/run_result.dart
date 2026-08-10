class SignalReefRunResult {
  const SignalReefRunResult({
    required this.score,
    required this.waveReached,
    required this.wavesCleared,
    required this.won,
  });

  final int score;
  final int waveReached;
  final int wavesCleared;
  final bool won;
}
