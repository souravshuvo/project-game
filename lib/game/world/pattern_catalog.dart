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
    final hazardChance = 0.18 + difficulty * 0.16;
    final hazardSlot = _random.nextDouble() < hazardChance
        ? HazardSlot.values[1 + _random.nextInt(3)]
        : HazardSlot.none;
    final pickupChance = 0.35 - difficulty * 0.08;
    final pickupSlot =
        hazardSlot == HazardSlot.center || _random.nextDouble() > pickupChance
        ? PickupSlot.none
        : PickupSlot.values[1 + _random.nextInt(3)];

    return SpawnPattern(offset, gap, width, hazardSlot, pickupSlot);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}

const introPatterns = <SpawnPattern>[
  SpawnPattern(0, 78, 190, HazardSlot.none, PickupSlot.center),
  SpawnPattern(-52, 82, 174, HazardSlot.none, PickupSlot.right),
  SpawnPattern(70, 86, 166, HazardSlot.none, PickupSlot.left),
  SpawnPattern(-92, 90, 154, HazardSlot.none, PickupSlot.none),
  SpawnPattern(96, 94, 150, HazardSlot.none, PickupSlot.center),
  SpawnPattern(-74, 96, 156, HazardSlot.left, PickupSlot.right),
  SpawnPattern(82, 100, 148, HazardSlot.right, PickupSlot.left),
  SpawnPattern(-108, 104, 138, HazardSlot.none, PickupSlot.center),
  SpawnPattern(118, 108, 132, HazardSlot.center, PickupSlot.none),
  SpawnPattern(-86, 106, 146, HazardSlot.none, PickupSlot.right),
  SpawnPattern(58, 94, 156, HazardSlot.left, PickupSlot.right),
  SpawnPattern(102, 108, 134, HazardSlot.none, PickupSlot.left),
  SpawnPattern(-112, 106, 142, HazardSlot.right, PickupSlot.left),
  SpawnPattern(-46, 96, 150, HazardSlot.none, PickupSlot.center),
  SpawnPattern(94, 110, 128, HazardSlot.center, PickupSlot.none),
  SpawnPattern(-104, 104, 138, HazardSlot.none, PickupSlot.right),
  SpawnPattern(74, 98, 148, HazardSlot.right, PickupSlot.left),
  SpawnPattern(-88, 108, 132, HazardSlot.none, PickupSlot.center),
  SpawnPattern(116, 110, 126, HazardSlot.left, PickupSlot.right),
  SpawnPattern(-62, 100, 144, HazardSlot.none, PickupSlot.left),
  SpawnPattern(84, 106, 136, HazardSlot.center, PickupSlot.none),
  SpawnPattern(-116, 108, 130, HazardSlot.none, PickupSlot.right),
  SpawnPattern(106, 110, 124, HazardSlot.right, PickupSlot.left),
  SpawnPattern(-78, 104, 138, HazardSlot.left, PickupSlot.right),
  SpawnPattern(48, 96, 148, HazardSlot.none, PickupSlot.center),
  SpawnPattern(112, 110, 126, HazardSlot.none, PickupSlot.left),
  SpawnPattern(-118, 110, 124, HazardSlot.center, PickupSlot.none),
  SpawnPattern(76, 104, 134, HazardSlot.right, PickupSlot.left),
  SpawnPattern(-96, 108, 130, HazardSlot.none, PickupSlot.right),
  SpawnPattern(118, 110, 122, HazardSlot.left, PickupSlot.right),
];
