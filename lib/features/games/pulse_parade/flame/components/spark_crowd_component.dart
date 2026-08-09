import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../domain/level_definition.dart';

class SparkCrowdComponent extends PositionComponent {
  SparkCrowdComponent({
    required int sparkCount,
    required PulsePolarity polarity,
  }) : _sparkCount = sparkCount,
       _polarity = polarity,
       _slots = List<Offset>.generate(80, _slotOffset),
       super(anchor: Anchor.center, priority: 30);

  static const int maxRenderedSparks = 80;

  final List<Offset> _slots;
  int _sparkCount;
  PulsePolarity _polarity;
  double _pulse = 0;
  double _polaritySweep = 0;

  void sync({
    required Vector2 screenPosition,
    required double crowdRadius,
    required int sparkCount,
    required PulsePolarity polarity,
  }) {
    position = screenPosition;
    size = Vector2.all(crowdRadius * 2);
    if (sparkCount != _sparkCount) {
      _pulse = 1;
    }
    if (polarity != _polarity) {
      _pulse = 1;
      _polaritySweep = 1;
    }
    _sparkCount = sparkCount;
    _polarity = polarity;
  }

  @override
  void update(double dt) {
    _pulse = math.max(0, _pulse - (dt * 3.6));
    _polaritySweep = math.max(0, _polaritySweep - (dt * 2.4));
  }

  @override
  void render(Canvas canvas) {
    if (_sparkCount <= 0) {
      return;
    }

    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;
    final color = _polarityColor(_polarity);
    final auraPaint = Paint()
      ..color = color.withValues(alpha: 0.2 + (_pulse * 0.24));
    canvas.drawCircle(center, radius * (0.9 + _pulse * 0.2), auraPaint);

    if (_polaritySweep > 0) {
      final sweepProgress = 1 - _polaritySweep;
      final sweepPaint = Paint()
        ..color = color.withValues(alpha: 0.72 * _polaritySweep)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawCircle(
        center,
        radius * (0.25 + (sweepProgress * 0.95)),
        sweepPaint,
      );
    }

    final visibleSparks = math.min(_sparkCount, maxRenderedSparks);
    for (var i = 0; i < visibleSparks; i++) {
      final offset = _slots[i] * radius * 0.72;
      final dotRadius = 2.4 + ((_sparkCount / 300).clamp(0, 1) * 2.1);
      final paint = Paint()
        ..color = Color.lerp(Colors.white, color, 0.55 + ((i % 5) * 0.08))!;
      canvas.drawCircle(center + offset, dotRadius, paint);
    }

    final corePaint = Paint()..color = Colors.white.withValues(alpha: 0.74);
    canvas.drawCircle(center, math.max(3, radius * 0.11), corePaint);
  }

  static Offset _slotOffset(int index) {
    final angle = index * 2.399963229728653;
    final radius = math.sqrt((index + 0.5) / maxRenderedSparks);
    return Offset(math.cos(angle) * radius, math.sin(angle) * radius);
  }

  Color _polarityColor(PulsePolarity polarity) {
    return switch (polarity) {
      PulsePolarity.cyan => const Color(0xFF43F0D8),
      PulsePolarity.amber => const Color(0xFFFFC44D),
    };
  }
}
