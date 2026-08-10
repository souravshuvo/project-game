import 'farm_plot.dart';
import 'inventory_state.dart';

class FarmState {
  FarmState({
    required this.coins,
    required this.water,
    required this.farmLevel,
    required this.lastWaterRefillAtMs,
    required this.lastSavedAtMs,
    required this.inventory,
    required List<FarmPlot> plots,
  }) : plots = List.unmodifiable(plots);

  final int coins;
  final int water;
  final int farmLevel;
  final int lastWaterRefillAtMs;
  final int lastSavedAtMs;
  final InventoryState inventory;
  final List<FarmPlot> plots;

  FarmState copyWith({
    int? coins,
    int? water,
    int? farmLevel,
    int? lastWaterRefillAtMs,
    int? lastSavedAtMs,
    InventoryState? inventory,
    List<FarmPlot>? plots,
  }) {
    return FarmState(
      coins: coins ?? this.coins,
      water: water ?? this.water,
      farmLevel: farmLevel ?? this.farmLevel,
      lastWaterRefillAtMs: lastWaterRefillAtMs ?? this.lastWaterRefillAtMs,
      lastSavedAtMs: lastSavedAtMs ?? this.lastSavedAtMs,
      inventory: inventory ?? this.inventory,
      plots: plots ?? this.plots,
    );
  }

  FarmState replacePlot(int index, FarmPlot plot) {
    final nextPlots = plots.toList();
    nextPlots[index] = plot;
    return copyWith(plots: nextPlots);
  }
}
