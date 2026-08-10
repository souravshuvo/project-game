enum PlotStatus { locked, empty, plantedDry, growing, ready }

class FarmPlot {
  const FarmPlot({
    required this.cropId,
    required this.plantedAtMs,
    required this.wateredAtMs,
  });

  const FarmPlot.empty()
    : cropId = null,
      plantedAtMs = null,
      wateredAtMs = null;

  factory FarmPlot.planted(String cropId, int nowMs) {
    return FarmPlot(cropId: cropId, plantedAtMs: nowMs, wateredAtMs: null);
  }

  final String? cropId;
  final int? plantedAtMs;
  final int? wateredAtMs;

  bool get isEmpty => cropId == null;
  bool get isWatered => wateredAtMs != null;

  FarmPlot watered(int nowMs) {
    return FarmPlot(
      cropId: cropId,
      plantedAtMs: plantedAtMs,
      wateredAtMs: nowMs,
    );
  }
}
