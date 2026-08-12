import 'package:flutter_test/flutter_test.dart';
import 'package:project_game/features/game/data/level_library.dart';
import 'package:project_game/features/game/domain/game_model.dart';
import 'package:project_game/features/game/domain/marble_run_game_engine.dart';

void main() {
  test('gate math clamps to the level crowd cap', () {
    expect(const GateEffect.add(20).applyTo(45, 120), 65);
    expect(const GateEffect.multiply(2).applyTo(75, 120), 120);
    expect(const GateEffect.subtract(12).applyTo(8, 120), 0);
  });

  test('gate choice applies only the selected gate in a choice group', () {
    final engine =
        MarbleRunGameEngine(level: v1Levels.first, levelCount: v1Levels.length)
          ..setLauncherX(252)
          ..setLaunching(true);

    for (var tick = 0; tick < 75; tick += 1) {
      engine.update(1 / 30);
    }

    expect(engine.appliedGateIds, contains('l1-multiply'));
    expect(engine.appliedGateIds, isNot(contains('l1-add')));
    expect(engine.triggeredGateIds, containsAll(['l1-multiply', 'l1-add']));
  });

  test('level one can clear through the add route', () {
    final engine =
        MarbleRunGameEngine(level: v1Levels.first, levelCount: v1Levels.length)
          ..setLauncherX(108)
          ..setLaunching(true);

    for (var tick = 0; tick < 190; tick += 1) {
      if (tick == 70) {
        engine.setLauncherX(180);
      }
      engine.update(1 / 30);
    }

    expect(engine.snapshot.phase, GamePhase.won);
    expect(engine.snapshot.activeCount, greaterThan(0));
  });

  test('level five rewards the stronger route', () {
    final engine =
        MarbleRunGameEngine(level: v1Levels[4], levelCount: v1Levels.length)
          ..setLauncherX(252)
          ..setLaunching(true);

    for (var tick = 0; tick < 220; tick += 1) {
      if (tick == 55) {
        engine.setLauncherX(180);
      }
      engine.update(1 / 30);
    }

    expect(engine.snapshot.phase, GamePhase.won);
  });
}
