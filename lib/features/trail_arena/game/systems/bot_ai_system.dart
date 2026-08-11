import 'dart:math' as math;

import '../../domain/arena_food.dart';
import '../../domain/vector2.dart';
import '../components/trail_actor_component.dart';

class BotAiSystem {
  BotAiSystem({
    required this.random,
    required this.arenaWidth,
    required this.arenaHeight,
  });

  final math.Random random;
  final double arenaWidth;
  final double arenaHeight;

  void updateBot({
    required TrailActorComponent bot,
    required List<ArenaFood> food,
    required List<TrailActorComponent> actors,
    required double dt,
  }) {
    if (!bot.alive) {
      return;
    }

    final targetFood = _nearestFood(bot.head, food);
    var steering = targetFood == null
        ? Vec2.fromAngle(bot.wanderHeading)
        : (targetFood.position - bot.head).normalized();

    steering = steering + (_wallAvoidance(bot.head) * 1.4);
    steering = steering + (_trailAvoidance(bot, actors) * 1.8);

    bot.wanderClock -= dt;
    if (bot.wanderClock <= 0) {
      bot.wanderClock = 0.8 + random.nextDouble() * 1.4;
      bot.wanderHeading += (random.nextDouble() - 0.5) * 1.3;
    }
    steering = steering + (Vec2.fromAngle(bot.wanderHeading) * 0.25);
    bot.steerWithDirection(steering.normalized());
  }

  ArenaFood? _nearestFood(Vec2 head, List<ArenaFood> food) {
    ArenaFood? best;
    var bestDistance = double.infinity;
    for (final item in food) {
      final distance = head.distanceTo(item.position);
      if (distance < bestDistance && distance < 280) {
        best = item;
        bestDistance = distance;
      }
    }
    return best;
  }

  Vec2 _wallAvoidance(Vec2 head) {
    const edge = 110.0;
    var force = const Vec2(0, 0);
    if (head.x < edge) {
      force += Vec2((edge - head.x) / edge, 0);
    } else if (head.x > arenaWidth - edge) {
      force += Vec2(-((head.x - (arenaWidth - edge)) / edge), 0);
    }
    if (head.y < edge) {
      force += Vec2(0, (edge - head.y) / edge);
    } else if (head.y > arenaHeight - edge) {
      force += Vec2(0, -((head.y - (arenaHeight - edge)) / edge));
    }
    return force;
  }

  Vec2 _trailAvoidance(
    TrailActorComponent bot,
    List<TrailActorComponent> actors,
  ) {
    final lookAhead = bot.head + (Vec2.fromAngle(bot.heading) * 54);
    var force = const Vec2(0, 0);
    for (final actor in actors) {
      if (!actor.alive) {
        continue;
      }
      var skipped = 0.0;
      for (final point in actor.trail) {
        if (identical(actor, bot) && skipped < 72) {
          skipped += point.distanceTo(bot.head);
          continue;
        }
        final distance = lookAhead.distanceTo(point);
        if (distance < 46) {
          force += (lookAhead - point).normalized() * ((46 - distance) / 46);
        }
      }
    }
    return force;
  }
}
