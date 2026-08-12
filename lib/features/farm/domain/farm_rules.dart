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
  static const moonMintId = 'moon_mint';
  static const cloudPepperId = 'cloud_pepper';
  static const glassBerryId = 'glass_berry';
  static const starfruitVinesId = 'starfruit_vines';
  static const goldenThymeId = 'golden_thyme';

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
      CropDefinition(
        id: moonMintId,
        name: 'Moon Mint',
        unlockLevel: 3,
        growDuration: Duration(seconds: 120),
        seedCost: 1,
        harvestYield: 1,
        sellValue: 18,
      ),
      CropDefinition(
        id: cloudPepperId,
        name: 'Cloud Pepper',
        unlockLevel: 3,
        growDuration: Duration(seconds: 180),
        seedCost: 1,
        harvestYield: 1,
        sellValue: 26,
      ),
      CropDefinition(
        id: glassBerryId,
        name: 'Glass Berry',
        unlockLevel: 4,
        growDuration: Duration(seconds: 300),
        seedCost: 1,
        harvestYield: 1,
        sellValue: 38,
      ),
      CropDefinition(
        id: starfruitVinesId,
        name: 'Starfruit Vines',
        unlockLevel: 5,
        growDuration: Duration(seconds: 480),
        seedCost: 1,
        harvestYield: 1,
        sellValue: 60,
      ),
      CropDefinition(
        id: goldenThymeId,
        name: 'Golden Thyme',
        unlockLevel: 6,
        growDuration: Duration(seconds: 720),
        seedCost: 1,
        harvestYield: 1,
        sellValue: 90,
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
      UpgradeDefinition(
        targetLevel: 3,
        cost: 70,
        unlockedPlots: 7,
        waterCap: 7,
        description: 'Unlock Plot 7, Moon Mint, Cloud Pepper, and +1 water cap',
      ),
      UpgradeDefinition(
        targetLevel: 4,
        cost: 160,
        unlockedPlots: 8,
        waterCap: 8,
        description: 'Unlock Plot 8, Glass Berry, and +1 water cap',
      ),
      UpgradeDefinition(
        targetLevel: 5,
        cost: 320,
        unlockedPlots: 9,
        waterCap: 9,
        description: 'Unlock Plot 9, Starfruit Vines, and +1 water cap',
      ),
      UpgradeDefinition(
        targetLevel: 6,
        cost: 650,
        unlockedPlots: 9,
        waterCap: 10,
        description: 'Unlock Golden Thyme and the final +1 water cap',
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
