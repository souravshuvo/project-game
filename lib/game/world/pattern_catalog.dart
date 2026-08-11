import 'dart:math' as math;

import '../models/spawn_pattern.dart';
import 'world_config.dart';

class PatternCatalog {
  PatternCatalog({int seed = 31}) : _random = math.Random(seed);

  final math.Random _random;

  SpawnPattern nextPattern({
    required int platformsSpawned,
    required double difficulty,
  }) {
    if (platformsSpawned < introPatterns.length) {
      return introPatterns[platformsSpawned];
    }

    final gap = _lerp(80, WorldConfig.safeMaxVerticalGap, _random.nextDouble());
    final width = _lerp(108, 160, _random.nextDouble()) - difficulty * 10;
    final offset = _lerp(
      -WorldConfig.safeMaxHorizontalOffset,
      WorldConfig.safeMaxHorizontalOffset,
      _random.nextDouble(),
    );
    final hazardChance = 0.22 + difficulty * 0.12;
    final hazardSlot = _random.nextDouble() < hazardChance
        ? HazardSlot.values[1 + _random.nextInt(3)]
        : HazardSlot.none;

    return SpawnPattern(offset, gap, width, hazardSlot);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}

const introPatterns = <SpawnPattern>[
  SpawnPattern(0, 78, 190, HazardSlot.none),
  SpawnPattern(-52, 82, 174, HazardSlot.none),
  SpawnPattern(70, 86, 166, HazardSlot.none),
  SpawnPattern(-92, 90, 154, HazardSlot.none),
  SpawnPattern(96, 94, 150, HazardSlot.none),
  SpawnPattern(-74, 96, 156, HazardSlot.left),
  SpawnPattern(82, 100, 148, HazardSlot.right),
  SpawnPattern(-108, 104, 138, HazardSlot.none),
  SpawnPattern(118, 108, 132, HazardSlot.center),
  SpawnPattern(-86, 112, 128, HazardSlot.none),
];
