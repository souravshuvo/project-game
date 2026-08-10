class FarmReturnReport {
  const FarmReturnReport({
    this.readyPlots = 0,
    this.waterRestored = 0,
    this.awaySeconds = 0,
    this.wasCapped = false,
    this.saveWasReset = false,
  });

  final int readyPlots;
  final int waterRestored;
  final int awaySeconds;
  final bool wasCapped;
  final bool saveWasReset;

  bool get hasProgress {
    return readyPlots > 0 ||
        waterRestored > 0 ||
        awaySeconds >= 6 ||
        wasCapped ||
        saveWasReset;
  }
}
