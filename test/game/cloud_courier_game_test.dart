import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/game/cloud_courier_game.dart';
import 'package:rapid_jump/game/models/run_state.dart';
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
}
