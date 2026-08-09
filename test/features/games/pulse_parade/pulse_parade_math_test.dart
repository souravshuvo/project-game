import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/features/games/pulse_parade/data/pulse_parade_levels.dart';
import 'package:rapid_jump/features/games/pulse_parade/domain/combat_math.dart';
import 'package:rapid_jump/features/games/pulse_parade/domain/gate_math.dart';
import 'package:rapid_jump/features/games/pulse_parade/domain/level_definition.dart';

void main() {
  test('amplifier and resonator gates update the grouped crowd count', () {
    const amplifier = PulseGateDefinition(
      id: 'amp',
      type: PulseGateType.amplifier,
      area: Rect.zero,
      addValue: 25,
    );
    const resonator = PulseGateDefinition(
      id: 'res',
      type: PulseGateType.resonator,
      area: Rect.zero,
      multiplier: 1.5,
    );

    final amplified = applyPulseGate(
      sparkCount: 40,
      polarity: PulsePolarity.cyan,
      gate: amplifier,
    );
    final resonated = applyPulseGate(
      sparkCount: amplified.sparkCount,
      polarity: amplified.polarity,
      gate: resonator,
    );

    expect(amplified.sparkCount, 65);
    expect(resonated.sparkCount, 97);
  });

  test('polarity gates change color without changing crowd count', () {
    const gate = PulseGateDefinition(
      id: 'amber',
      type: PulseGateType.polarity,
      area: Rect.zero,
      polarity: PulsePolarity.amber,
    );

    final result = applyPulseGate(
      sparkCount: 42,
      polarity: PulsePolarity.cyan,
      gate: gate,
    );

    expect(result.sparkCount, 42);
    expect(result.polarity, PulsePolarity.amber);
  });

  test('matching polarity halves static glitch spark loss', () {
    const enemy = PulseEnemyDefinition(
      id: 'glitch',
      type: PulseEnemyType.staticGlitch,
      area: Rect.zero,
      strength: 70,
      weakness: PulsePolarity.cyan,
    );

    final matched = resolveStaticGlitchCombat(
      sparkCount: 65,
      polarity: PulsePolarity.cyan,
      enemy: enemy,
    );
    final unmatched = resolveStaticGlitchCombat(
      sparkCount: 65,
      polarity: PulsePolarity.amber,
      enemy: enemy,
    );

    expect(matched.damagePerSpark, 2);
    expect(matched.sparkLoss, 35);
    expect(matched.sparkCount, 30);
    expect(unmatched.damagePerSpark, 1);
    expect(unmatched.sparkLoss, 65);
    expect(unmatched.sparkCount, 0);
  });

  test('gate math caps the logical crowd size for MVP performance', () {
    const gate = PulseGateDefinition(
      id: 'huge',
      type: PulseGateType.amplifier,
      area: Rect.zero,
      addValue: 500,
    );

    final result = applyPulseGate(
      sparkCount: 250,
      polarity: PulsePolarity.cyan,
      gate: gate,
    );

    expect(result.sparkCount, maxPulseCrowdCount);
  });

  test(
    'side-by-side gate choices trigger only when the crowd center enters one',
    () {
      final level = pulseParadePrototypeLevel;
      final leftGate = level.gates.singleWhere(
        (gate) => gate.id == 'left-amplifier',
      );
      final rightGate = level.gates.singleWhere(
        (gate) => gate.id == 'right-resonator',
      );
      final choiceRow = <PulseGateDefinition>[leftGate, rightGate];

      expect(
        choosePulseGateAtPoint(
          point: const Offset(180, 310),
          gates: choiceRow,
          activatedGateIds: const <String>{},
        ),
        isNull,
      );
      expect(
        choosePulseGateAtPoint(
          point: const Offset(100, 310),
          gates: choiceRow,
          activatedGateIds: const <String>{},
        ),
        leftGate,
      );
      expect(
        choosePulseGateAtPoint(
          point: const Offset(260, 310),
          gates: choiceRow,
          activatedGateIds: const <String>{},
        ),
        rightGate,
      );
    },
  );

  test('activated gates cannot trigger again', () {
    final level = pulseParadePrototypeLevel;
    final leftGate = level.gates.singleWhere(
      (gate) => gate.id == 'left-amplifier',
    );

    final selectedGate = choosePulseGateAtPoint(
      point: const Offset(100, 310),
      gates: <PulseGateDefinition>[leftGate],
      activatedGateIds: <String>{leftGate.id},
    );

    expect(selectedGate, isNull);
  });

  test('prototype level tuning can produce a win after the static glitch', () {
    final level = pulseParadePrototypeLevel;
    final resonator = level.gates.singleWhere(
      (gate) => gate.id == 'right-resonator',
    );
    final polarityGate = level.gates.singleWhere(
      (gate) => gate.id == 'cyan-polarity',
    );
    final enemy = level.enemies.single;

    final resonated = applyPulseGate(
      sparkCount: level.startingSparkCount,
      polarity: level.startingPolarity,
      gate: resonator,
    );
    final tuned = applyPulseGate(
      sparkCount: resonated.sparkCount,
      polarity: resonated.polarity,
      gate: polarityGate,
    );
    final combat = resolveStaticGlitchCombat(
      sparkCount: tuned.sparkCount,
      polarity: tuned.polarity,
      enemy: enemy,
    );

    expect(
      combat.sparkCount,
      greaterThanOrEqualTo(level.powerNode.chargeRequired),
    );
    expect(combat.sparkCount, level.powerNode.chargeRequired);
  });

  test('five level progression is present with unique level ids', () {
    final ids = pulseParadeLevels.map((level) => level.id).toSet();

    expect(pulseParadeLevels, hasLength(5));
    expect(ids, hasLength(pulseParadeLevels.length));
  });

  test('each progression level has at least one intended winning path', () {
    final preferredGateIdsByLevel = <String, List<String>>{
      'pulse-level-1': <String>['first-amplifier'],
      'pulse-level-2': <String>['warm-amplifier'],
      'pulse-level-3': <String>['choice-amplifier'],
      'pulse-level-4': <String>['right-resonator', 'cyan-polarity'],
      'pulse-level-5': <String>[
        'final-right-resonator',
        'final-cyan-polarity',
        'final-amplifier',
      ],
    };

    for (final level in pulseParadeLevels) {
      var sparkCount = level.startingSparkCount;
      var polarity = level.startingPolarity;

      for (final gateId in preferredGateIdsByLevel[level.id]!) {
        final gate = level.gates.singleWhere((gate) => gate.id == gateId);
        final result = applyPulseGate(
          sparkCount: sparkCount,
          polarity: polarity,
          gate: gate,
        );
        sparkCount = result.sparkCount;
        polarity = result.polarity;
      }

      for (final enemy in level.enemies) {
        final result = resolveStaticGlitchCombat(
          sparkCount: sparkCount,
          polarity: polarity,
          enemy: enemy,
        );
        sparkCount = result.sparkCount;
      }

      expect(
        sparkCount,
        greaterThanOrEqualTo(level.powerNode.chargeRequired),
        reason: '${level.title} should be winnable on its intended path.',
      );
    }
  });
}
