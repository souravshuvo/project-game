import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_game/features/game/data/level_library.dart';
import 'package:project_game/features/game/domain/game_model.dart';
import 'package:project_game/features/game/domain/marble_run_game_engine.dart';

void main() {
  test('production v1 includes thirty sequential offline levels', () {
    expect(v1Levels, hasLength(30));
    expect(
      v1Levels.map((level) => level.number),
      List<int>.generate(30, (index) => index + 1),
    );
    expect(v1Levels.map((level) => level.id).toSet(), hasLength(30));
  });

  test('level geometry stays inside the game world', () {
    final world = Offset.zero & gameWorldSize;

    for (final level in v1Levels) {
      expect(level.gates, isNotEmpty, reason: level.id);
      expect(level.enemies, isNotEmpty, reason: level.id);
      expect(level.startReserve, greaterThan(0), reason: level.id);
      expect(
        level.maxCrowd,
        greaterThanOrEqualTo(level.startReserve),
        reason: level.id,
      );
      expect(
        level.visualCap,
        lessThanOrEqualTo(level.maxCrowd),
        reason: level.id,
      );

      for (final gate in level.gates) {
        expect(world.contains(gate.bounds.topLeft), isTrue, reason: gate.id);
        expect(
          world.contains(gate.bounds.bottomRight),
          isTrue,
          reason: gate.id,
        );
      }

      for (final enemy in level.enemies) {
        expect(world.contains(enemy.bounds.topLeft), isTrue, reason: enemy.id);
        expect(
          world.contains(enemy.bounds.bottomRight),
          isTrue,
          reason: enemy.id,
        );
      }
    }
  });

  test('every production v1 level has a guided winning route', () {
    for (final level in v1Levels) {
      final engine = MarbleRunGameEngine(
        level: level,
        levelCount: v1Levels.length,
      )..setLaunching(true);

      for (var tick = 0; tick < 480; tick += 1) {
        if (engine.snapshot.isFinished) {
          break;
        }

        engine.setLauncherX(_targetXFor(engine));
        engine.update(1 / 30);
      }

      expect(engine.snapshot.phase, GamePhase.won, reason: level.id);
    }
  });
}

double _targetXFor(MarbleRunGameEngine engine) {
  final gates =
      engine.level.gates
          .where((gate) => !engine.triggeredGateIds.contains(gate.id))
          .toList()
        ..sort((a, b) => b.center.dy.compareTo(a.center.dy));

  if (gates.isEmpty) {
    return gameWorldSize.width / 2;
  }

  final nextY = gates.first.center.dy;
  final groupKey = gates.first.choiceGroup ?? gates.first.id;
  final candidates = gates.where((gate) {
    final candidateKey = gate.choiceGroup ?? gate.id;
    return candidateKey == groupKey && (gate.center.dy - nextY).abs() < 0.5;
  });

  return candidates
      .reduce((best, gate) {
        final bestScore = _gateScore(best, engine.level);
        final gateScore = _gateScore(gate, engine.level);
        if (gateScore != bestScore) {
          return gateScore > bestScore ? gate : best;
        }

        final bestDistance = (best.center.dx - gameWorldSize.width / 2).abs();
        final gateDistance = (gate.center.dx - gameWorldSize.width / 2).abs();
        return gateDistance < bestDistance ? gate : best;
      })
      .center
      .dx;
}

int _gateScore(GateDefinition gate, LevelDefinition level) {
  return switch (gate.effect.kind) {
    GateKind.subtract => 0,
    GateKind.wide || GateKind.tight => math.max(1, level.startReserve),
    GateKind.add || GateKind.multiply => gate.effect.applyTo(
      level.startReserve,
      level.maxCrowd,
    ),
  };
}
