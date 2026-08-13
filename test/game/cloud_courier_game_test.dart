import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/game/cloud_courier_game.dart';
import 'package:rapid_jump/game/components/pickup_component.dart';
import 'package:rapid_jump/game/models/run_state.dart';
import 'package:rapid_jump/game/world/challenge_catalog.dart';
import 'package:rapid_jump/game/world/world_config.dart';

void main() {
  test('starts a playable run with reachable generated platform gaps', () {
    final game = CloudCourierGame()..configureViewport(const Size(360, 640));

    game.startRun();

    expect(game.phase, RunPhase.playing);
    expect(game.platforms.length, greaterThan(1));

    for (var i = 1; i < game.platforms.length; i += 1) {
      final gap = game.platforms[i - 1].top - game.platforms[i].top;
      expect(gap, lessThanOrEqualTo(WorldConfig.safeMaxVerticalGap));
      expect(gap, greaterThanOrEqualTo(WorldConfig.safeMinVerticalGap));
    }
  });

  test('falling below the camera ends the run with a fall reason', () {
    final game = CloudCourierGame()..configureViewport(const Size(360, 640));
    game.startRun();

    game.player.y = game.cameraY + game.viewport.height + 160;
    game.step(1 / 60, 0);

    expect(game.phase, RunPhase.gameOver);
    expect(game.deathReason, DeathReason.fall);
  });

  test('production route catalog has forty gradual challenge stamps', () {
    expect(ChallengeCatalog.totalSteps, 40);

    final steps = ChallengeCatalog.steps;
    var maxScoreTarget = 0;
    var maxLandingTarget = 0;
    var maxPickupTarget = 0;
    for (var i = 0; i < steps.length; i += 1) {
      final step = steps[i];
      expect(step.goalLabel, isNotEmpty);
      if (step.scoreTarget > 0) {
        expect(step.scoreTarget, greaterThanOrEqualTo(maxScoreTarget));
        maxScoreTarget = step.scoreTarget;
      }
      if (step.landingTarget > 0) {
        expect(step.landingTarget, greaterThanOrEqualTo(maxLandingTarget));
        maxLandingTarget = step.landingTarget;
      }
      if (step.pickupTarget > 0) {
        expect(step.pickupTarget, greaterThanOrEqualTo(maxPickupTarget));
        maxPickupTarget = step.pickupTarget;
      }
    }

    for (var i = 1; i < steps.length; i += 1) {
      expect(steps[i].number, steps[i - 1].number + 1);
    }
  });

  test(
    'starts with visible signal pickups from authored platform patterns',
    () {
      final game = CloudCourierGame()..configureViewport(const Size(360, 640));

      game.startRun();

      expect(game.pickups.where((pickup) => !pickup.collected), isNotEmpty);
    },
  );

  test(
    'collecting a signal adds score and can complete a pickup challenge',
    () {
      final game = CloudCourierGame()..configureViewport(const Size(360, 640));
      game.setCompletedChallengeSteps(2);
      game.startRun();

      game.pickups
        ..clear()
        ..add(PickupComponent(position: game.player.rect.center));

      game.step(1 / 60, 0);

      expect(game.pickupsThisRun, 1);
      expect(game.score, greaterThanOrEqualTo(12));
      expect(game.lastRunCompletedChallenge, true);
      expect(game.completedChallengeSteps, 3);
    },
  );

  test(
    'rewarded revive returns from game over once without resetting score',
    () {
      final game = CloudCourierGame()..configureViewport(const Size(360, 640));
      game.startRun();

      game.player.y = game.cameraY + game.viewport.height + 160;
      game.step(1 / 60, 0);
      final scoreBeforeRevive = game.score;

      expect(game.phase, RunPhase.gameOver);
      expect(game.canRevive, true);
      expect(game.reviveAfterAd(), true);
      expect(game.phase, RunPhase.playing);
      expect(game.score, scoreBeforeRevive);
      expect(game.revivesThisRun, 1);

      game.player.y = game.cameraY + game.viewport.height + 160;
      game.step(1 / 60, 0);

      expect(game.phase, RunPhase.gameOver);
      expect(game.canRevive, false);
    },
  );
}
