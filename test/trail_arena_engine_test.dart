import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:trail_arena/features/trail_arena/domain/arena_food.dart';
import 'package:trail_arena/features/trail_arena/domain/arena_difficulty_phase.dart';
import 'package:trail_arena/features/trail_arena/domain/food_type.dart';
import 'package:trail_arena/features/trail_arena/domain/game_feedback_event.dart';
import 'package:trail_arena/features/trail_arena/domain/run_state.dart';
import 'package:trail_arena/features/trail_arena/domain/run_stats.dart';
import 'package:trail_arena/features/trail_arena/domain/trail_goal.dart';
import 'package:trail_arena/features/trail_arena/domain/vector2.dart';
import 'package:trail_arena/features/trail_arena/game/trail_arena_game.dart';

void main() {
  test('starts with a playable arena state', () {
    final game = TrailArenaGame(random: math.Random(1))..startRun();

    expect(game.phase, RunPhase.ready);
    expect(game.score, 0);
    expect(game.player.trail.length, greaterThan(4));
    expect(game.food.length, TrailArenaGame.targetFoodCount);
    expect(game.bots.length, 2);
    expect(
      game.food.every(
        (food) =>
            food.position.x >= TrailArenaGame.spawnMargin &&
            food.position.x <=
                TrailArenaGame.arenaWidth - TrailArenaGame.spawnMargin &&
            food.position.y >= TrailArenaGame.spawnMargin &&
            food.position.y <=
                TrailArenaGame.arenaHeight - TrailArenaGame.spawnMargin,
      ),
      isTrue,
    );
  });

  test('collecting food increases score and target length', () {
    final game = TrailArenaGame(random: math.Random(2))..startRun();
    _advanceReady(game);
    final initialLength = game.player.targetLength;
    game.debugReplaceFood([
      ArenaFood(position: game.player.head + const Vec2(0, -8)),
    ]);

    game.update(0.05);

    expect(game.score, FoodType.seed.score);
    expect(game.latestEvent?.kind, GameFeedbackKind.foodCollected);
    expect(game.latestEvent?.scoreDelta, FoodType.seed.score);
    expect(
      game.player.targetLength,
      initialLength + FoodType.seed.playerGrowth,
    );
    expect(game.phase, RunPhase.running);
  });

  test('hitting the arena boundary ends the run', () {
    final game = TrailArenaGame(random: math.Random(3))..startRun();
    _advanceReady(game);

    for (var i = 0; i < 80 && !game.isGameOver; i++) {
      game.update(0.1);
    }

    expect(game.phase, RunPhase.gameOver);
    expect(game.deathCause, DeathCause.boundary);
    expect(game.latestEvent?.kind, GameFeedbackKind.playerDied);
  });

  test('trail goal catalog has production v1 content with unique ids', () {
    final goals = TrailGoalCatalog.goals;
    final ids = goals.map((goal) => goal.id).toSet();

    expect(goals.length, 24);
    expect(ids.length, goals.length);
    expect(TrailGoalCatalog.firstIncomplete(<String>{}), goals.first);
    expect(TrailGoalCatalog.nextIncomplete({goals.first.id}).first, goals[1]);
  });

  test('arena difficulty phases ramp over longer runs', () {
    expect(
      ArenaDifficultyPhaseRules.fromElapsed(0),
      ArenaDifficultyPhase.glide,
    );
    expect(
      ArenaDifficultyPhaseRules.fromElapsed(45),
      ArenaDifficultyPhase.chase,
    );
    expect(
      ArenaDifficultyPhaseRules.fromElapsed(90),
      ArenaDifficultyPhase.surge,
    );
    expect(
      ArenaDifficultyPhase.surge.botSpeedScale,
      greaterThan(ArenaDifficultyPhase.glide.botSpeedScale),
    );
  });

  test('trail goals complete from real run stat metrics', () {
    const stats = RunStats(
      score: 260,
      survivalSeconds: 61,
      foodCollected: 20,
      brightFoodCollected: 2,
      botCrashes: 1,
      trailLength: 340,
    );

    final completed = TrailGoalCatalog.newlyCompleted(stats, <String>{});

    expect(completed.any((goal) => goal.id == 'trail_score_260'), isTrue);
    expect(completed.any((goal) => goal.id == 'trail_survive_60'), isTrue);
    expect(completed.any((goal) => goal.id == 'trail_seed_20'), isTrue);
    expect(completed.any((goal) => goal.id == 'trail_length_340'), isTrue);
    expect(completed.any((goal) => goal.id == 'trail_score_650'), isFalse);
  });

  test('collecting bright food updates run stats', () {
    final game = TrailArenaGame(random: math.Random(5))..startRun();
    _advanceReady(game);
    final initialLength = game.player.targetLength;
    game.debugReplaceFood([
      ArenaFood(
        position: game.player.head + const Vec2(0, -8),
        type: FoodType.brightSeed,
      ),
    ]);

    game.update(0.05);

    expect(game.runStats.score, FoodType.brightSeed.score);
    expect(game.runStats.foodCollected, 1);
    expect(game.runStats.brightFoodCollected, 1);
    expect(
      game.runStats.trailLength,
      initialLength + FoodType.brightSeed.playerGrowth,
    );
  });

  test('pause and resume use a short ready state', () {
    final game = TrailArenaGame(random: math.Random(4))..startRun();
    _advanceReady(game);

    game.pause();
    expect(game.phase, RunPhase.paused);

    game.resume();
    expect(game.phase, RunPhase.ready);
    expect(game.readyRemaining, 1);
  });
}

void _advanceReady(TrailArenaGame game) {
  for (var i = 0; i < 60 && game.phase == RunPhase.ready; i++) {
    game.update(0.05);
  }
}
