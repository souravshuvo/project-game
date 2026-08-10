import 'dart:math' as math;

import 'farm_action_result.dart';
import 'farm_offline_result.dart';
import 'farm_plot.dart';
import 'farm_return_report.dart';
import 'farm_rules.dart';
import 'farm_state.dart';

class FarmSimulation {
  const FarmSimulation(this.rules);

  final FarmRules rules;

  FarmState applyTimeProgress(FarmState state, int nowMs) {
    final waterCap = rules.waterCap(state.farmLevel);
    if (state.water >= waterCap || nowMs <= state.lastWaterRefillAtMs) {
      return state.copyWith(water: math.min(state.water, waterCap));
    }

    final elapsedMs = nowMs - state.lastWaterRefillAtMs;
    final refillTicks = elapsedMs ~/ rules.waterRefillInterval.inMilliseconds;
    if (refillTicks <= 0) {
      return state;
    }

    final restored = math.min(refillTicks, waterCap - state.water);
    final nextWater = state.water + restored;
    final nextRefillAt = nextWater >= waterCap
        ? nowMs
        : state.lastWaterRefillAtMs +
              restored * rules.waterRefillInterval.inMilliseconds;

    return state.copyWith(water: nextWater, lastWaterRefillAtMs: nextRefillAt);
  }

  FarmOfflineResult applyOfflineProgress(FarmState state, int nowMs) {
    final rawElapsedMs = math.max(0, nowMs - state.lastSavedAtMs);
    final cappedElapsedMs = math.min(
      rawElapsedMs,
      rules.offlineProgressCap.inMilliseconds,
    );
    final effectiveNowMs = state.lastSavedAtMs + cappedElapsedMs;
    final waterBefore = state.water;
    var progressed = applyTimeProgress(state, effectiveNowMs);
    final wasCapped = rawElapsedMs > cappedElapsedMs;

    if (wasCapped && progressed.water < rules.waterCap(progressed.farmLevel)) {
      progressed = progressed.copyWith(lastWaterRefillAtMs: nowMs);
    }

    final readyPlots = _countReadyPlots(progressed, effectiveNowMs);
    return FarmOfflineResult(
      state: progressed.copyWith(lastSavedAtMs: nowMs),
      report: FarmReturnReport(
        readyPlots: readyPlots,
        waterRestored: progressed.water - waterBefore,
        awaySeconds: Duration(milliseconds: rawElapsedMs).inSeconds,
        wasCapped: wasCapped,
      ),
    );
  }

  FarmActionResult plant(
    FarmState state, {
    required int plotIndex,
    required String cropId,
    required int nowMs,
  }) {
    state = applyTimeProgress(state, nowMs);
    if (!_isValidUnlockedPlot(state, plotIndex)) {
      return _unchanged(state, 'Upgrade to open that plot.');
    }

    final crop = rules.cropById(cropId);
    if (!rules.isCropUnlocked(crop.id, state.farmLevel)) {
      return _unchanged(
        state,
        '${crop.name} unlocks after the garden upgrade.',
      );
    }

    final plot = state.plots[plotIndex];
    if (!plot.isEmpty) {
      return _unchanged(state, 'That plot is already planted.');
    }
    if (state.inventory.seeds < crop.seedCost) {
      return _unchanged(state, 'Buy a seed pack first.');
    }

    final nextInventory = state.inventory.copyWith(
      seeds: state.inventory.seeds - crop.seedCost,
    );
    final nextState = state
        .replacePlot(plotIndex, FarmPlot.planted(crop.id, nowMs))
        .copyWith(inventory: nextInventory);

    return _changed(nextState, '${crop.name} planted.');
  }

  FarmActionResult water(
    FarmState state, {
    required int plotIndex,
    required int nowMs,
  }) {
    state = applyTimeProgress(state, nowMs);
    if (!_isValidUnlockedPlot(state, plotIndex)) {
      return _unchanged(state, 'Upgrade to open that plot.');
    }

    final plot = state.plots[plotIndex];
    if (plot.isEmpty) {
      return _unchanged(state, 'Plant this plot first.');
    }
    if (plot.isWatered) {
      final status = rules.plotStatus(state, plotIndex, nowMs);
      return _unchanged(
        state,
        status == PlotStatus.ready ? 'Ready to harvest.' : 'Already watered.',
      );
    }
    if (state.water <= 0) {
      return _unchanged(state, 'Water is refilling.');
    }

    final refillStart = state.water == rules.waterCap(state.farmLevel)
        ? nowMs
        : state.lastWaterRefillAtMs;
    final nextState = state
        .replacePlot(plotIndex, plot.watered(nowMs))
        .copyWith(water: state.water - 1, lastWaterRefillAtMs: refillStart);

    return _changed(nextState, 'Watered.');
  }

  FarmActionResult harvest(
    FarmState state, {
    required int plotIndex,
    required int nowMs,
  }) {
    state = applyTimeProgress(state, nowMs);
    if (!_isValidUnlockedPlot(state, plotIndex)) {
      return _unchanged(state, 'Upgrade to open that plot.');
    }

    final plot = state.plots[plotIndex];
    if (rules.plotStatus(state, plotIndex, nowMs) != PlotStatus.ready) {
      return _unchanged(state, 'Still growing.');
    }

    final crop = rules.cropById(plot.cropId!);
    final nextInventory = state.inventory.addHarvest(
      crop.id,
      crop.harvestYield,
    );
    final nextState = state
        .replacePlot(plotIndex, const FarmPlot.empty())
        .copyWith(inventory: nextInventory);

    return _changed(nextState, '${crop.name} added to crate.');
  }

  FarmActionResult sellCrate(FarmState state, {required int nowMs}) {
    state = applyTimeProgress(state, nowMs);
    if (!state.inventory.hasCrateItems) {
      return _unchanged(state, 'No harvest to sell.');
    }

    final coinsEarned = rules.crateSellValue(state.inventory);
    final nextState = state.copyWith(
      coins: state.coins + coinsEarned,
      inventory: state.inventory.clearCrate(),
    );

    return _changed(nextState, 'Sold harvest for $coinsEarned coins.');
  }

  FarmActionResult buySeeds(FarmState state, {required int nowMs}) {
    state = applyTimeProgress(state, nowMs);
    if (state.coins < rules.seedPackCost) {
      return _unchanged(state, 'Need ${rules.seedPackCost} coins for seeds.');
    }

    final nextInventory = state.inventory.copyWith(
      seeds: state.inventory.seeds + rules.seedPackAmount,
    );
    final nextState = state.copyWith(
      coins: state.coins - rules.seedPackCost,
      inventory: nextInventory,
    );

    return _changed(nextState, 'Seed pack added.');
  }

  FarmActionResult upgradeFarm(FarmState state, {required int nowMs}) {
    state = applyTimeProgress(state, nowMs);
    final upgrade = rules.nextUpgrade(state.farmLevel);
    if (upgrade == null) {
      return _unchanged(state, 'Garden is fully upgraded for version 1.');
    }
    if (state.coins < upgrade.cost) {
      return _unchanged(
        state,
        'Need ${upgrade.cost} coins for the garden upgrade.',
      );
    }

    final nextState = state.copyWith(
      coins: state.coins - upgrade.cost,
      farmLevel: upgrade.targetLevel,
      water: math.min(state.water + 2, upgrade.waterCap),
      lastWaterRefillAtMs: nowMs,
    );

    return _changed(nextState, 'Garden upgrade complete.');
  }

  int _countReadyPlots(FarmState state, int nowMs) {
    final unlockedPlots = rules.unlockedPlotCount(state.farmLevel);
    var readyPlots = 0;
    for (var index = 0; index < unlockedPlots; index += 1) {
      if (rules.plotStatus(state, index, nowMs) == PlotStatus.ready) {
        readyPlots += 1;
      }
    }
    return readyPlots;
  }

  bool _isValidUnlockedPlot(FarmState state, int plotIndex) {
    return plotIndex >= 0 &&
        plotIndex < state.plots.length &&
        rules.isPlotUnlocked(state, plotIndex);
  }

  FarmActionResult _changed(FarmState state, String message) {
    return FarmActionResult(state: state, message: message, changed: true);
  }

  FarmActionResult _unchanged(FarmState state, String message) {
    return FarmActionResult(state: state, message: message, changed: false);
  }
}
