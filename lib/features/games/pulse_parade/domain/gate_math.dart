import 'dart:ui';

import 'level_definition.dart';

const int maxPulseCrowdCount = 300;

class GateMathResult {
  const GateMathResult({required this.sparkCount, required this.polarity});

  final int sparkCount;
  final PulsePolarity polarity;
}

GateMathResult applyPulseGate({
  required int sparkCount,
  required PulsePolarity polarity,
  required PulseGateDefinition gate,
}) {
  final nextCount = switch (gate.type) {
    PulseGateType.amplifier => sparkCount + gate.addValue,
    PulseGateType.resonator => (sparkCount * gate.multiplier).floor(),
    PulseGateType.polarity => sparkCount,
  };

  return GateMathResult(
    sparkCount: nextCount.clamp(0, maxPulseCrowdCount),
    polarity: gate.polarity ?? polarity,
  );
}

PulseGateDefinition? choosePulseGateAtPoint({
  required Offset point,
  required Iterable<PulseGateDefinition> gates,
  required Set<String> activatedGateIds,
}) {
  for (final gate in gates) {
    if (!activatedGateIds.contains(gate.id) && gate.area.contains(point)) {
      return gate;
    }
  }
  return null;
}
