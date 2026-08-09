import 'dart:ui';

import '../domain/level_definition.dart';

const PulseParadeLevel pulseParadeLevel1 = PulseParadeLevel(
  id: 'pulse-level-1',
  title: 'Signal Start',
  worldWidth: 360,
  worldHeight: 1120,
  startingSparkCount: 40,
  startingPolarity: PulsePolarity.amber,
  forwardSpeed: 195,
  lateralSpeed: 520,
  gates: <PulseGateDefinition>[
    PulseGateDefinition(
      id: 'first-amplifier',
      type: PulseGateType.amplifier,
      area: Rect.fromLTWH(110, 300, 140, 74),
      addValue: 20,
    ),
  ],
  enemies: <PulseEnemyDefinition>[],
  powerNode: PulsePowerNodeDefinition(
    area: Rect.fromLTWH(32, 880, 296, 92),
    chargeRequired: 45,
  ),
);

const PulseParadeLevel pulseParadeLevel2 = PulseParadeLevel(
  id: 'pulse-level-2',
  title: 'First Static',
  worldWidth: 360,
  worldHeight: 1280,
  startingSparkCount: 40,
  startingPolarity: PulsePolarity.amber,
  forwardSpeed: 200,
  lateralSpeed: 520,
  gates: <PulseGateDefinition>[
    PulseGateDefinition(
      id: 'warm-amplifier',
      type: PulseGateType.amplifier,
      area: Rect.fromLTWH(110, 280, 140, 74),
      addValue: 25,
    ),
  ],
  enemies: <PulseEnemyDefinition>[
    PulseEnemyDefinition(
      id: 'first-glitch',
      type: PulseEnemyType.staticGlitch,
      area: Rect.fromLTWH(70, 680, 220, 76),
      strength: 50,
      weakness: PulsePolarity.amber,
    ),
  ],
  powerNode: PulsePowerNodeDefinition(
    area: Rect.fromLTWH(32, 1040, 296, 92),
    chargeRequired: 35,
  ),
);

const PulseParadeLevel pulseParadeLevel3 = PulseParadeLevel(
  id: 'pulse-level-3',
  title: 'Two Fields',
  worldWidth: 360,
  worldHeight: 1360,
  startingSparkCount: 40,
  startingPolarity: PulsePolarity.amber,
  forwardSpeed: 205,
  lateralSpeed: 520,
  gates: <PulseGateDefinition>[
    PulseGateDefinition(
      id: 'choice-amplifier',
      type: PulseGateType.amplifier,
      area: Rect.fromLTWH(36, 290, 122, 74),
      addValue: 25,
    ),
    PulseGateDefinition(
      id: 'choice-resonator',
      type: PulseGateType.resonator,
      area: Rect.fromLTWH(202, 290, 122, 74),
      multiplier: 1.5,
    ),
  ],
  enemies: <PulseEnemyDefinition>[
    PulseEnemyDefinition(
      id: 'choice-glitch',
      type: PulseEnemyType.staticGlitch,
      area: Rect.fromLTWH(56, 720, 248, 78),
      strength: 50,
      weakness: PulsePolarity.amber,
    ),
  ],
  powerNode: PulsePowerNodeDefinition(
    area: Rect.fromLTWH(32, 1110, 296, 92),
    chargeRequired: 35,
  ),
);

const PulseParadeLevel pulseParadePrototypeLevel = PulseParadeLevel(
  id: 'pulse-level-4',
  title: 'Polarity Tune',
  worldWidth: 360,
  worldHeight: 1500,
  startingSparkCount: 40,
  startingPolarity: PulsePolarity.amber,
  forwardSpeed: 205,
  lateralSpeed: 520,
  gates: <PulseGateDefinition>[
    PulseGateDefinition(
      id: 'left-amplifier',
      type: PulseGateType.amplifier,
      area: Rect.fromLTWH(36, 275, 122, 74),
      addValue: 25,
    ),
    PulseGateDefinition(
      id: 'right-resonator',
      type: PulseGateType.resonator,
      area: Rect.fromLTWH(202, 275, 122, 74),
      multiplier: 1.5,
    ),
    PulseGateDefinition(
      id: 'cyan-polarity',
      type: PulseGateType.polarity,
      area: Rect.fromLTWH(110, 600, 140, 74),
      polarity: PulsePolarity.cyan,
    ),
  ],
  enemies: <PulseEnemyDefinition>[
    PulseEnemyDefinition(
      id: 'static-glitch-alpha',
      type: PulseEnemyType.staticGlitch,
      area: Rect.fromLTWH(18, 880, 324, 82),
      strength: 60,
      weakness: PulsePolarity.cyan,
    ),
  ],
  powerNode: PulsePowerNodeDefinition(
    area: Rect.fromLTWH(32, 1260, 296, 92),
    chargeRequired: 30,
  ),
);

const PulseParadeLevel pulseParadeLevel5 = PulseParadeLevel(
  id: 'pulse-level-5',
  title: 'Bright Breaker',
  worldWidth: 360,
  worldHeight: 1680,
  startingSparkCount: 45,
  startingPolarity: PulsePolarity.amber,
  forwardSpeed: 210,
  lateralSpeed: 525,
  gates: <PulseGateDefinition>[
    PulseGateDefinition(
      id: 'final-left-amplifier',
      type: PulseGateType.amplifier,
      area: Rect.fromLTWH(36, 270, 122, 74),
      addValue: 25,
    ),
    PulseGateDefinition(
      id: 'final-right-resonator',
      type: PulseGateType.resonator,
      area: Rect.fromLTWH(202, 270, 122, 74),
      multiplier: 1.5,
    ),
    PulseGateDefinition(
      id: 'final-cyan-polarity',
      type: PulseGateType.polarity,
      area: Rect.fromLTWH(110, 570, 140, 74),
      polarity: PulsePolarity.cyan,
    ),
    PulseGateDefinition(
      id: 'final-amplifier',
      type: PulseGateType.amplifier,
      area: Rect.fromLTWH(110, 820, 140, 74),
      addValue: 25,
    ),
  ],
  enemies: <PulseEnemyDefinition>[
    PulseEnemyDefinition(
      id: 'wide-static-glitch',
      type: PulseEnemyType.staticGlitch,
      area: Rect.fromLTWH(18, 1120, 324, 86),
      strength: 85,
      weakness: PulsePolarity.cyan,
    ),
  ],
  powerNode: PulsePowerNodeDefinition(
    area: Rect.fromLTWH(32, 1430, 296, 92),
    chargeRequired: 45,
  ),
);

const List<PulseParadeLevel> pulseParadeLevels = <PulseParadeLevel>[
  pulseParadeLevel1,
  pulseParadeLevel2,
  pulseParadeLevel3,
  pulseParadePrototypeLevel,
  pulseParadeLevel5,
];
