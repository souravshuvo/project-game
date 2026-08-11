import 'dart:math' as math;

import '../../domain/arena_food.dart';
import '../../domain/food_type.dart';
import '../../domain/vector2.dart';
import '../components/trail_actor_component.dart';

class SpawnSystem {
  SpawnSystem({
    required this.random,
    required this.arenaWidth,
    required this.arenaHeight,
    required this.spawnMargin,
    required this.bodyRadius,
  });

  final math.Random random;
  final double arenaWidth;
  final double arenaHeight;
  final double spawnMargin;
  final double bodyRadius;

  ArenaFood? createFood({
    required List<TrailActorComponent> actors,
    required List<ArenaFood> existingFood,
  }) {
    for (var attempt = 0; attempt < 80; attempt++) {
      final type = random.nextDouble() < 0.1
          ? FoodType.brightSeed
          : FoodType.seed;
      final candidate = Vec2(
        _randomRange(spawnMargin, arenaWidth - spawnMargin),
        _randomRange(spawnMargin, arenaHeight - spawnMargin),
      );

      if (_isSafe(candidate, type.radius, actors, existingFood)) {
        return ArenaFood(position: candidate, type: type);
      }
    }
    return null;
  }

  Vec2? safeActorSpawn({
    required List<TrailActorComponent> actors,
    required List<ArenaFood> food,
    required Vec2 avoid,
    double minAvoidDistance = 180,
  }) {
    for (var attempt = 0; attempt < 120; attempt++) {
      final candidate = Vec2(
        _randomRange(spawnMargin * 2, arenaWidth - (spawnMargin * 2)),
        _randomRange(spawnMargin * 2, arenaHeight - (spawnMargin * 2)),
      );
      if (candidate.distanceTo(avoid) < minAvoidDistance) {
        continue;
      }
      if (_isSafe(candidate, bodyRadius + 12, actors, food)) {
        return candidate;
      }
    }
    return null;
  }

  bool _isSafe(
    Vec2 position,
    double radius,
    List<TrailActorComponent> actors,
    List<ArenaFood> food,
  ) {
    if (position.x < spawnMargin ||
        position.x > arenaWidth - spawnMargin ||
        position.y < spawnMargin ||
        position.y > arenaHeight - spawnMargin) {
      return false;
    }

    for (final actor in actors) {
      if (!actor.alive) {
        continue;
      }
      if (position.distanceTo(actor.head) < radius + 42) {
        return false;
      }
      for (final point in actor.trail) {
        if (position.distanceTo(point) < bodyRadius + radius + 18) {
          return false;
        }
      }
    }

    for (final item in food) {
      if (position.distanceTo(item.position) < radius + item.type.radius + 14) {
        return false;
      }
    }

    return true;
  }

  double _randomRange(double min, double max) {
    return min + (random.nextDouble() * (max - min));
  }
}
