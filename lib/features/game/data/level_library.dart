import 'dart:math' as math;
import 'dart:ui';

import '../domain/game_model.dart';

final List<LevelDefinition> v1Levels = List<LevelDefinition>.unmodifiable([
  ..._tutorialLevels,
  ...List<LevelDefinition>.generate(25, _buildProductionLevel),
]);

const _tutorialLevels = [
  LevelDefinition(
    id: 'channel-1',
    number: 1,
    name: 'First Flow',
    startReserve: 45,
    launchRate: 36,
    unitSpeed: 118,
    maxCrowd: 120,
    visualCap: 90,
    finishY: 64,
    gates: [
      GateDefinition(
        id: 'l1-add',
        center: Offset(108, 470),
        size: Size(112, 54),
        effect: GateEffect.add(20),
        choiceGroup: 'l1-choice',
      ),
      GateDefinition(
        id: 'l1-multiply',
        center: Offset(252, 470),
        size: Size(112, 54),
        effect: GateEffect.multiply(2),
        choiceGroup: 'l1-choice',
      ),
      GateDefinition(
        id: 'l1-bonus',
        center: Offset(180, 330),
        size: Size(118, 54),
        effect: GateEffect.add(8),
      ),
    ],
    enemies: [
      EnemyDefinition(
        id: 'l1-final',
        center: Offset(180, 155),
        size: Size(228, 78),
        strength: 52,
      ),
    ],
  ),
  LevelDefinition(
    id: 'channel-2',
    number: 2,
    name: 'Two Clusters',
    startReserve: 48,
    launchRate: 36,
    unitSpeed: 120,
    maxCrowd: 130,
    visualCap: 90,
    finishY: 64,
    gates: [
      GateDefinition(
        id: 'l2-add',
        center: Offset(108, 500),
        size: Size(112, 54),
        effect: GateEffect.add(18),
        choiceGroup: 'l2-choice',
      ),
      GateDefinition(
        id: 'l2-multiply',
        center: Offset(252, 500),
        size: Size(112, 54),
        effect: GateEffect.multiply(2),
        choiceGroup: 'l2-choice',
      ),
      GateDefinition(
        id: 'l2-bonus',
        center: Offset(180, 355),
        size: Size(118, 54),
        effect: GateEffect.add(12),
      ),
    ],
    enemies: [
      EnemyDefinition(
        id: 'l2-first',
        center: Offset(180, 255),
        size: Size(180, 60),
        strength: 28,
      ),
      EnemyDefinition(
        id: 'l2-final',
        center: Offset(180, 130),
        size: Size(230, 76),
        strength: 40,
      ),
    ],
  ),
  LevelDefinition(
    id: 'channel-3',
    number: 3,
    name: 'Avoid Drain',
    startReserve: 52,
    launchRate: 36,
    unitSpeed: 122,
    maxCrowd: 140,
    visualCap: 95,
    finishY: 64,
    gates: [
      GateDefinition(
        id: 'l3-add',
        center: Offset(108, 500),
        size: Size(112, 54),
        effect: GateEffect.add(25),
        choiceGroup: 'l3-choice',
      ),
      GateDefinition(
        id: 'l3-drain',
        center: Offset(252, 500),
        size: Size(112, 54),
        effect: GateEffect.subtract(12),
        choiceGroup: 'l3-choice',
      ),
      GateDefinition(
        id: 'l3-multiply',
        center: Offset(180, 335),
        size: Size(118, 54),
        effect: GateEffect.multiply(2),
      ),
    ],
    enemies: [
      EnemyDefinition(
        id: 'l3-final',
        center: Offset(180, 155),
        size: Size(240, 82),
        strength: 95,
      ),
    ],
  ),
  LevelDefinition(
    id: 'channel-4',
    number: 4,
    name: 'Wide Line',
    startReserve: 54,
    launchRate: 38,
    unitSpeed: 124,
    maxCrowd: 150,
    visualCap: 100,
    finishY: 64,
    gates: [
      GateDefinition(
        id: 'l4-wide',
        center: Offset(108, 500),
        size: Size(112, 54),
        effect: GateEffect.wide(),
        choiceGroup: 'l4-choice',
      ),
      GateDefinition(
        id: 'l4-add',
        center: Offset(252, 500),
        size: Size(112, 54),
        effect: GateEffect.add(18),
        choiceGroup: 'l4-choice',
      ),
      GateDefinition(
        id: 'l4-multiply',
        center: Offset(180, 350),
        size: Size(118, 54),
        effect: GateEffect.multiply(2),
      ),
    ],
    enemies: [
      EnemyDefinition(
        id: 'l4-line',
        center: Offset(180, 165),
        size: Size(290, 72),
        strength: 104,
        shape: EnemyShape.wideLine,
      ),
    ],
  ),
  LevelDefinition(
    id: 'channel-5',
    number: 5,
    name: 'Final Clash',
    startReserve: 56,
    launchRate: 38,
    unitSpeed: 126,
    maxCrowd: 155,
    visualCap: 105,
    finishY: 64,
    gates: [
      GateDefinition(
        id: 'l5-add',
        center: Offset(108, 505),
        size: Size(112, 54),
        effect: GateEffect.add(30),
        choiceGroup: 'l5-choice',
      ),
      GateDefinition(
        id: 'l5-multiply',
        center: Offset(252, 505),
        size: Size(112, 54),
        effect: GateEffect.multiply(2),
        choiceGroup: 'l5-choice',
      ),
      GateDefinition(
        id: 'l5-bonus',
        center: Offset(180, 355),
        size: Size(118, 54),
        effect: GateEffect.add(10),
      ),
    ],
    enemies: [
      EnemyDefinition(
        id: 'l5-first',
        center: Offset(180, 250),
        size: Size(190, 60),
        strength: 35,
      ),
      EnemyDefinition(
        id: 'l5-final',
        center: Offset(180, 125),
        size: Size(260, 82),
        strength: 60,
        shape: EnemyShape.narrowBlock,
      ),
    ],
  ),
];

const _arcNames = ['North', 'East', 'South', 'West', 'Core'];

const _patternNames = [
  'Split Charge',
  'Cross Current',
  'Red Bend',
  'Wide Sweep',
  'Double Wall',
];

LevelDefinition _buildProductionLevel(int index) {
  final number = index + 6;
  final tier = index ~/ 5;
  final pattern = index % 5;
  final idPrefix = 'l$number';
  final reserve = 58 + tier * 8 + pattern * 2;
  final launchRate = 38.0 + tier;
  final unitSpeed = 126.0 + tier * 3 + pattern;
  final maxCrowd = 158 + tier * 24 + pattern * 6;
  final visualCap = math.min(120, 98 + tier * 5 + pattern * 2).toInt();
  final add = 22 + tier * 5 + pattern * 2;
  final bonus = 12 + tier * 3 + pattern;
  final drain = 10 + tier * 3 + pattern;
  final firstStrength = 26 + tier * 5 + pattern * 2;
  final finalStrength = 58 + tier * 9 + pattern * 4;
  final arcName = _arcNames[tier];
  final patternName = _patternNames[pattern];

  return switch (pattern) {
    0 => LevelDefinition(
      id: 'channel-$number',
      number: number,
      name: '$arcName $patternName',
      startReserve: reserve,
      launchRate: launchRate,
      unitSpeed: unitSpeed,
      maxCrowd: maxCrowd,
      visualCap: visualCap,
      finishY: 64,
      gates: [
        GateDefinition(
          id: '$idPrefix-add',
          center: const Offset(108, 505),
          size: const Size(112, 54),
          effect: GateEffect.add(add),
          choiceGroup: '$idPrefix-choice-a',
        ),
        GateDefinition(
          id: '$idPrefix-multiply',
          center: const Offset(252, 505),
          size: const Size(112, 54),
          effect: const GateEffect.multiply(2),
          choiceGroup: '$idPrefix-choice-a',
        ),
        GateDefinition(
          id: '$idPrefix-bonus',
          center: const Offset(180, 350),
          size: const Size(118, 54),
          effect: GateEffect.add(bonus),
        ),
      ],
      enemies: [
        EnemyDefinition(
          id: '$idPrefix-final',
          center: const Offset(180, 150),
          size: Size(232.0 + tier * 6, 78),
          strength: finalStrength + 14,
        ),
      ],
    ),
    1 => LevelDefinition(
      id: 'channel-$number',
      number: number,
      name: '$arcName $patternName',
      startReserve: reserve,
      launchRate: launchRate,
      unitSpeed: unitSpeed,
      maxCrowd: maxCrowd,
      visualCap: visualCap,
      finishY: 64,
      gates: [
        GateDefinition(
          id: '$idPrefix-tight',
          center: const Offset(108, 510),
          size: const Size(112, 54),
          effect: const GateEffect.tight(),
          choiceGroup: '$idPrefix-choice-a',
        ),
        GateDefinition(
          id: '$idPrefix-add',
          center: const Offset(252, 510),
          size: const Size(112, 54),
          effect: GateEffect.add(add),
          choiceGroup: '$idPrefix-choice-a',
        ),
        GateDefinition(
          id: '$idPrefix-multiply',
          center: const Offset(180, 365),
          size: const Size(118, 54),
          effect: const GateEffect.multiply(2),
        ),
      ],
      enemies: [
        EnemyDefinition(
          id: '$idPrefix-left',
          center: const Offset(132, 242),
          size: const Size(150, 58),
          strength: firstStrength,
        ),
        EnemyDefinition(
          id: '$idPrefix-right',
          center: const Offset(218, 128),
          size: const Size(190, 72),
          strength: finalStrength + 4,
        ),
      ],
    ),
    2 => LevelDefinition(
      id: 'channel-$number',
      number: number,
      name: '$arcName $patternName',
      startReserve: reserve,
      launchRate: launchRate,
      unitSpeed: unitSpeed,
      maxCrowd: maxCrowd,
      visualCap: visualCap,
      finishY: 64,
      gates: [
        GateDefinition(
          id: '$idPrefix-add',
          center: const Offset(108, 500),
          size: const Size(112, 54),
          effect: GateEffect.add(add + 8),
          choiceGroup: '$idPrefix-choice-a',
        ),
        GateDefinition(
          id: '$idPrefix-drain',
          center: const Offset(252, 500),
          size: const Size(112, 54),
          effect: GateEffect.subtract(drain),
          choiceGroup: '$idPrefix-choice-a',
        ),
        GateDefinition(
          id: '$idPrefix-multiply',
          center: const Offset(180, 345),
          size: const Size(118, 54),
          effect: const GateEffect.multiply(2),
        ),
      ],
      enemies: [
        EnemyDefinition(
          id: '$idPrefix-final',
          center: const Offset(180, 150),
          size: Size(238.0 + tier * 6, 82),
          strength: finalStrength + 28,
          shape: EnemyShape.narrowBlock,
        ),
      ],
    ),
    3 => LevelDefinition(
      id: 'channel-$number',
      number: number,
      name: '$arcName $patternName',
      startReserve: reserve,
      launchRate: launchRate,
      unitSpeed: unitSpeed,
      maxCrowd: maxCrowd,
      visualCap: visualCap,
      finishY: 64,
      gates: [
        GateDefinition(
          id: '$idPrefix-wide',
          center: const Offset(108, 510),
          size: const Size(112, 54),
          effect: const GateEffect.wide(),
          choiceGroup: '$idPrefix-choice-a',
        ),
        GateDefinition(
          id: '$idPrefix-add',
          center: const Offset(252, 510),
          size: const Size(112, 54),
          effect: GateEffect.add(add),
          choiceGroup: '$idPrefix-choice-a',
        ),
        GateDefinition(
          id: '$idPrefix-multiply',
          center: const Offset(180, 365),
          size: const Size(118, 54),
          effect: const GateEffect.multiply(2),
        ),
      ],
      enemies: [
        EnemyDefinition(
          id: '$idPrefix-line',
          center: const Offset(180, 166),
          size: Size(292.0 + tier * 4, 72),
          strength: finalStrength + 34,
          shape: EnemyShape.wideLine,
        ),
      ],
    ),
    _ => LevelDefinition(
      id: 'channel-$number',
      number: number,
      name: '$arcName $patternName',
      startReserve: reserve,
      launchRate: launchRate,
      unitSpeed: unitSpeed,
      maxCrowd: maxCrowd,
      visualCap: visualCap,
      finishY: 64,
      gates: [
        GateDefinition(
          id: '$idPrefix-add',
          center: const Offset(108, 505),
          size: const Size(112, 54),
          effect: GateEffect.add(add + 4),
          choiceGroup: '$idPrefix-choice-a',
        ),
        GateDefinition(
          id: '$idPrefix-multiply',
          center: const Offset(252, 505),
          size: const Size(112, 54),
          effect: const GateEffect.multiply(2),
          choiceGroup: '$idPrefix-choice-a',
        ),
        GateDefinition(
          id: '$idPrefix-bonus',
          center: const Offset(180, 355),
          size: const Size(118, 54),
          effect: GateEffect.add(bonus + 4),
        ),
      ],
      enemies: [
        EnemyDefinition(
          id: '$idPrefix-first',
          center: const Offset(180, 250),
          size: const Size(190, 60),
          strength: firstStrength + 4,
        ),
        EnemyDefinition(
          id: '$idPrefix-final',
          center: const Offset(180, 125),
          size: Size(254.0 + tier * 4, 82),
          strength: finalStrength + 10,
          shape: EnemyShape.narrowBlock,
        ),
      ],
    ),
  };
}
