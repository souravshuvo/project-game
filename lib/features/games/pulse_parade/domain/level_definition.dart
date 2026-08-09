import 'dart:ui';

import 'package:flutter/foundation.dart';

enum PulsePolarity { cyan, amber }

enum PulseGateType { amplifier, resonator, polarity }

enum PulseEnemyType { staticGlitch }

enum PulseLevelStatus {
  ready,
  running,
  won,
  failedDepleted,
  failedUndercharged,
}

@immutable
class PulseGateDefinition {
  const PulseGateDefinition({
    required this.id,
    required this.type,
    required this.area,
    this.addValue = 0,
    this.multiplier = 1,
    this.polarity,
  });

  final String id;
  final PulseGateType type;
  final Rect area;
  final int addValue;
  final double multiplier;
  final PulsePolarity? polarity;

  String get label {
    return switch (type) {
      PulseGateType.amplifier => '+$addValue',
      PulseGateType.resonator => 'x${_trimMultiplier(multiplier)}',
      PulseGateType.polarity =>
        (polarity ?? PulsePolarity.cyan).name.toUpperCase(),
    };
  }

  static String _trimMultiplier(double value) {
    final text = value.toStringAsFixed(2);
    return text.replaceAll(RegExp(r'\.?0+$'), '');
  }
}

@immutable
class PulseEnemyDefinition {
  const PulseEnemyDefinition({
    required this.id,
    required this.type,
    required this.area,
    required this.strength,
    required this.weakness,
  });

  final String id;
  final PulseEnemyType type;
  final Rect area;
  final int strength;
  final PulsePolarity weakness;
}

@immutable
class PulsePowerNodeDefinition {
  const PulsePowerNodeDefinition({
    required this.area,
    required this.chargeRequired,
  });

  final Rect area;
  final int chargeRequired;
}

@immutable
class PulseParadeLevel {
  const PulseParadeLevel({
    required this.id,
    required this.title,
    required this.worldWidth,
    required this.worldHeight,
    required this.startingSparkCount,
    required this.startingPolarity,
    required this.forwardSpeed,
    required this.lateralSpeed,
    required this.gates,
    required this.enemies,
    required this.powerNode,
  });

  final String id;
  final String title;
  final double worldWidth;
  final double worldHeight;
  final int startingSparkCount;
  final PulsePolarity startingPolarity;
  final double forwardSpeed;
  final double lateralSpeed;
  final List<PulseGateDefinition> gates;
  final List<PulseEnemyDefinition> enemies;
  final PulsePowerNodeDefinition powerNode;
}
