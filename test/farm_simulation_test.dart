import 'package:rooftop_rain_garden/features/farm/domain/farm_plot.dart';
import 'package:rooftop_rain_garden/features/farm/domain/farm_rules.dart';
import 'package:rooftop_rain_garden/features/farm/domain/farm_simulation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rules = FarmRules.mvp;
  const simulation = FarmSimulation(rules);
  const startMs = 1000;

  group('FarmSimulation', () {
    test('plant consumes seeds and creates a dry crop', () {
      final state = rules.initialState(startMs);

      final result = simulation.plant(
        state,
        plotIndex: 0,
        cropId: FarmRules.sunSproutsId,
        nowMs: startMs,
      );

      expect(result.changed, isTrue);
      expect(result.state.inventory.seeds, state.inventory.seeds - 1);
      expect(result.state.plots[0].cropId, FarmRules.sunSproutsId);
      expect(rules.plotStatus(result.state, 0, startMs), PlotStatus.plantedDry);
    });

    test('dry crops do not grow until watered', () {
      final planted = simulation.plant(
        rules.initialState(startMs),
        plotIndex: 0,
        cropId: FarmRules.sunSproutsId,
        nowMs: startMs,
      );
      final muchLater = startMs + const Duration(minutes: 5).inMilliseconds;

      expect(
        rules.plotStatus(planted.state, 0, muchLater),
        PlotStatus.plantedDry,
      );
    });

    test('water consumes water and starts growth', () {
      final planted = simulation.plant(
        rules.initialState(startMs),
        plotIndex: 0,
        cropId: FarmRules.sunSproutsId,
        nowMs: startMs,
      );

      final watered = simulation.water(
        planted.state,
        plotIndex: 0,
        nowMs: startMs + 1,
      );

      expect(watered.changed, isTrue);
      expect(watered.state.water, rules.startingWater - 1);
      expect(watered.state.plots[0].wateredAtMs, startMs + 1);
      expect(
        rules.plotStatus(watered.state, 0, startMs + 1),
        PlotStatus.growing,
      );
    });

    test('watered crop becomes ready after its grow duration', () {
      final crop = rules.cropById(FarmRules.sunSproutsId);
      final planted = simulation.plant(
        rules.initialState(startMs),
        plotIndex: 0,
        cropId: crop.id,
        nowMs: startMs,
      );
      final watered = simulation.water(
        planted.state,
        plotIndex: 0,
        nowMs: startMs,
      );
      final readyMs = startMs + crop.growDuration.inMilliseconds;

      expect(rules.plotStatus(watered.state, 0, readyMs), PlotStatus.ready);
    });

    test('harvest clears the plot and adds crop to crate', () {
      final crop = rules.cropById(FarmRules.sunSproutsId);
      final planted = simulation.plant(
        rules.initialState(startMs),
        plotIndex: 0,
        cropId: crop.id,
        nowMs: startMs,
      );
      final watered = simulation.water(
        planted.state,
        plotIndex: 0,
        nowMs: startMs,
      );

      final harvested = simulation.harvest(
        watered.state,
        plotIndex: 0,
        nowMs: startMs + crop.growDuration.inMilliseconds,
      );

      expect(harvested.changed, isTrue);
      expect(harvested.state.plots[0].isEmpty, isTrue);
      expect(
        harvested.state.inventory.countForCrop(crop.id),
        crop.harvestYield,
      );
    });

    test('sell crate clears storage and adds coins', () {
      final crop = rules.cropById(FarmRules.sunSproutsId);
      final planted = simulation.plant(
        rules.initialState(startMs),
        plotIndex: 0,
        cropId: crop.id,
        nowMs: startMs,
      );
      final watered = simulation.water(
        planted.state,
        plotIndex: 0,
        nowMs: startMs,
      );
      final harvested = simulation.harvest(
        watered.state,
        plotIndex: 0,
        nowMs: startMs + crop.growDuration.inMilliseconds,
      );

      final sold = simulation.sellCrate(
        harvested.state,
        nowMs: startMs + crop.growDuration.inMilliseconds,
      );

      expect(sold.changed, isTrue);
      expect(sold.state.inventory.totalCrateItems, 0);
      expect(sold.state.coins, rules.startingCoins + crop.sellValue);
    });

    test('buy seeds spends coins and adds a seed pack', () {
      final state = rules.initialState(startMs);

      final bought = simulation.buySeeds(state, nowMs: startMs);

      expect(bought.changed, isTrue);
      expect(bought.state.coins, rules.startingCoins - rules.seedPackCost);
      expect(
        bought.state.inventory.seeds,
        rules.startingSeeds + rules.seedPackAmount,
      );
    });

    test('upgrade spends coins and unlocks the level two garden', () {
      final upgrade = rules.nextUpgrade(1)!;
      final state = rules.initialState(startMs).copyWith(coins: upgrade.cost);

      final upgraded = simulation.upgradeFarm(state, nowMs: startMs);

      expect(upgraded.changed, isTrue);
      expect(upgraded.state.farmLevel, 2);
      expect(upgraded.state.coins, 0);
      expect(rules.unlockedPlotCount(upgraded.state.farmLevel), 6);
      expect(rules.waterCap(upgraded.state.farmLevel), 6);
      expect(rules.unlockedCrops(upgraded.state.farmLevel), hasLength(3));
    });

    test('offline progress refills water and reports ready crops', () {
      final crop = rules.cropById(FarmRules.sunSproutsId);
      final planted = simulation.plant(
        rules.initialState(startMs),
        plotIndex: 0,
        cropId: crop.id,
        nowMs: startMs,
      );
      final watered = simulation.water(
        planted.state,
        plotIndex: 0,
        nowMs: startMs,
      );
      final saved = watered.state.copyWith(lastSavedAtMs: startMs);
      final returnMs = startMs + const Duration(minutes: 1).inMilliseconds;

      final offline = simulation.applyOfflineProgress(saved, returnMs);

      expect(offline.report.readyPlots, 1);
      expect(offline.report.waterRestored, 1);
      expect(offline.state.water, rules.startingWater);
      expect(offline.state.lastSavedAtMs, returnMs);
    });
  });
}
