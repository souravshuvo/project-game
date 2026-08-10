import 'dart:math' as math;

import 'crop_definition.dart';
import 'farm_plot.dart';
import 'farm_state.dart';
import 'inventory_state.dart';
import 'upgrade_definition.dart';

class FarmRules {
  const FarmRules({
    required this.plotCount,
    required this.startingCoins,
    required this.startingSeeds,
    required this.startingWater,
    required this.seedPackCost,
    required this.seedPackAmount,
    required this.waterRefillInterval,
    required this.offlineProgressCap,
    required this.crops,
    required this.upgrades,
  });

  static const sunSproutsId = 'sun_sprouts';
  static const rainBeansId = 'rain_beans';
  static const amberLeafId = 'amber_leaf';

  static const mvp = FarmRules(
    plotCount: 9,
    startingCoins: 8,
    startingSeeds: 4,
    startingWater: 4,
    seedPackCost: 8,
    seedPackAmount: 4,
    waterRefillInterval: Duration(seconds: 30),
    offlineProgressCap: Duration(hours: 8),
    crops: <CropDefinition>[
      CropDefinition(
        id: sunSproutsId,
        name: 'Sun Sprouts',
        unlockLevel: 1,
        growDuration: Duration(seconds: 20),
        seedCost: 1,
        harvestYield: 1,
        sellValue: 4,
      ),
      CropDefinition(
        id: rainBeansId,
        name: 'Rain Beans',
        unlockLevel: 2,
        growDuration: Duration(seconds: 45),
        seedCost: 1,
        harvestYield: 1,
        sellValue: 8,
      ),
      CropDefinition(
        id: amberLeafId,
        name: 'Amber Leaf',
        unlockLevel: 2,
        growDuration: Duration(seconds: 75),
        seedCost: 1,
        harvestYield: 1,
        sellValue: 13,
      ),
    ],
    upgrades: <UpgradeDefinition>[
      UpgradeDefinition(
        targetLevel: 2,
        cost: 20,
        unlockedPlots: 6,
        waterCap: 6,
        description: 'Unlock 2 plots, Rain Beans, Amber Leaf, and +2 water cap',
      ),
    ],
  );

  final int plotCount;
  final int startingCoins;
  final int startingSeeds;
  final int startingWater;
  final int seedPackCost;
  final int seedPackAmount;
  final Duration waterRefillInterval;
  final Duration offlineProgressCap;
  final List<CropDefinition> crops;
  final List<UpgradeDefinition> upgrades;

  int get maxLevel {
    return upgrades.isEmpty ? 1 : upgrades.last.targetLevel;
  }

  FarmState initialState(int nowMs) {
    return FarmState(
      coins: startingCoins,
      water: startingWater,
      farmLevel: 1,
      lastWaterRefillAtMs: nowMs,
      lastSavedAtMs: nowMs,
      inventory: InventoryState(seeds: startingSeeds),
      plots: List<FarmPlot>.generate(plotCount, (_) => const FarmPlot.empty()),
    );
  }

  CropDefinition cropById(String cropId) {
    return crops.firstWhere((crop) => crop.id == cropId);
  }

  List<CropDefinition> unlockedCrops(int farmLevel) {
    return crops.where((crop) => crop.unlockLevel <= farmLevel).toList();
  }

  bool isCropUnlocked(String cropId, int farmLevel) {
    return cropById(cropId).unlockLevel <= farmLevel;
  }

  int unlockedPlotCount(int farmLevel) {
    final matchingUpgrade = upgrades
        .where((upgrade) => upgrade.targetLevel <= farmLevel)
        .fold<UpgradeDefinition?>(null, (_, upgrade) => upgrade);
    return math.min(matchingUpgrade?.unlockedPlots ?? 4, plotCount);
  }

  int waterCap(int farmLevel) {
    final matchingUpgrade = upgrades
        .where((upgrade) => upgrade.targetLevel <= farmLevel)
        .fold<UpgradeDefinition?>(null, (_, upgrade) => upgrade);
    return matchingUpgrade?.waterCap ?? startingWater;
  }

  UpgradeDefinition? nextUpgrade(int farmLevel) {
    for (final upgrade in upgrades) {
      if (upgrade.targetLevel > farmLevel) {
        return upgrade;
      }
    }
    return null;
  }

  bool isPlotUnlocked(FarmState state, int index) {
    return index >= 0 && index < unlockedPlotCount(state.farmLevel);
  }

  PlotStatus plotStatus(FarmState state, int index, int nowMs) {
    if (!isPlotUnlocked(state, index)) {
      return PlotStatus.locked;
    }

    final plot = state.plots[index];
    if (plot.isEmpty) {
      return PlotStatus.empty;
    }
    if (!plot.isWatered) {
      return PlotStatus.plantedDry;
    }
    return remainingGrowth(plot, nowMs) == Duration.zero
        ? PlotStatus.ready
        : PlotStatus.growing;
  }

  Duration remainingGrowth(FarmPlot plot, int nowMs) {
    if (plot.cropId == null || plot.wateredAtMs == null) {
      return cropById(sunSproutsId).growDuration;
    }

    final crop = cropById(plot.cropId!);
    final elapsed = Duration(milliseconds: nowMs - plot.wateredAtMs!);
    final remaining = crop.growDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  int crateSellValue(InventoryState inventory) {
    var total = 0;
    for (final entry in inventory.crate.entries) {
      total += cropById(entry.key).sellValue * entry.value;
    }
    return total;
  }
}
