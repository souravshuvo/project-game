import 'package:rooftop_rain_garden/features/farm/data/farm_save_codec.dart';
import 'package:rooftop_rain_garden/features/farm/domain/farm_plot.dart';
import 'package:rooftop_rain_garden/features/farm/domain/farm_rules.dart';
import 'package:rooftop_rain_garden/features/farm/domain/farm_simulation.dart';
import 'package:rooftop_rain_garden/features/farm/domain/inventory_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rules = FarmRules.mvp;
  const simulation = FarmSimulation(rules);
  final codec = FarmSaveCodec(rules);
  const startMs = 5000;

  test('save codec restores coins, resources, plots, and crate', () {
    final crop = rules.cropById(FarmRules.sunSproutsId);
    final planted = simulation.plant(
      rules.initialState(startMs),
      plotIndex: 1,
      cropId: crop.id,
      nowMs: startMs,
    );
    final watered = simulation.water(
      planted.state,
      plotIndex: 1,
      nowMs: startMs + 1,
    );
    final harvested = simulation.harvest(
      watered.state,
      plotIndex: 1,
      nowMs: startMs + crop.growDuration.inMilliseconds + 1,
    );
    final saved = harvested.state.copyWith(lastSavedAtMs: startMs + 100);

    final raw = codec.encode(saved);
    final restored = codec.decode(raw, nowMs: startMs + 200);

    expect(restored.coins, saved.coins);
    expect(restored.water, saved.water);
    expect(restored.farmLevel, saved.farmLevel);
    expect(restored.lastSavedAtMs, saved.lastSavedAtMs);
    expect(restored.inventory.seeds, saved.inventory.seeds);
    expect(restored.inventory.countForCrop(crop.id), crop.harvestYield);
    expect(restored.plots[1].isEmpty, isTrue);
  });

  test('save codec restores late-game crops and final garden progress', () {
    final plantedGoldenThyme = FarmPlot.planted(
      FarmRules.goldenThymeId,
      startMs,
    ).watered(startMs + 1);
    final saved = rules
        .initialState(startMs)
        .replacePlot(8, plantedGoldenThyme)
        .copyWith(
          farmLevel: rules.maxLevel,
          water: rules.waterCap(rules.maxLevel),
          inventory: InventoryState(
            seeds: 12,
            crate: const <String, int>{
              FarmRules.starfruitVinesId: 3,
              FarmRules.goldenThymeId: 2,
            },
          ),
          lastSavedAtMs: startMs + 100,
        );

    final raw = codec.encode(saved);
    final restored = codec.decode(raw, nowMs: startMs + 200);

    expect(restored.farmLevel, rules.maxLevel);
    expect(restored.water, rules.waterCap(rules.maxLevel));
    expect(restored.plots[8].cropId, FarmRules.goldenThymeId);
    expect(restored.plots[8].wateredAtMs, startMs + 1);
    expect(restored.inventory.countForCrop(FarmRules.starfruitVinesId), 3);
    expect(restored.inventory.countForCrop(FarmRules.goldenThymeId), 2);
  });

  test('save codec rejects invalid save data', () {
    expect(
      () => codec.decode('[]', nowMs: startMs),
      throwsA(isA<FormatException>()),
    );
  });

  test('save codec sanitizes negative resources and impossible watering', () {
    const raw = '''
{
  "version": 1,
  "coins": -50,
  "water": -2,
  "farmLevel": 99,
  "lastWaterRefillAtMs": 5000,
  "lastSavedAtMs": 5000,
  "inventory": {
    "seeds": -3,
    "crate": {
      "sun_sprouts": 2,
      "unknown_crop": 7
    }
  },
  "plots": [
    {
      "cropId": "sun_sprouts",
      "plantedAtMs": 5000,
      "wateredAtMs": 4000
    }
  ]
}
''';

    final restored = codec.decode(raw, nowMs: startMs);

    expect(restored.coins, 0);
    expect(restored.water, 0);
    expect(restored.farmLevel, rules.maxLevel);
    expect(restored.inventory.seeds, 0);
    expect(restored.inventory.countForCrop(FarmRules.sunSproutsId), 2);
    expect(restored.inventory.crate.containsKey('unknown_crop'), isFalse);
    expect(restored.plots.first.cropId, FarmRules.sunSproutsId);
    expect(restored.plots.first.wateredAtMs, isNull);
  });
}
