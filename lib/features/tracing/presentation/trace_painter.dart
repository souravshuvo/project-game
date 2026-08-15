import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../application/trace_controller.dart';
import '../domain/trace_definition.dart';

class TracePainter extends CustomPainter {
  TracePainter({
    required this.state,
    required this.pulse,
    this.activeColor = const Color(0xFF7257E8),
    this.hintColor = const Color(0xFFFFA62B),
  }) : super(repaint: pulse);

  final TraceState state;
  final Animation<double> pulse;
  final Color activeColor;
  final Color hintColor;

  static const Color _guideColor = Color(0xFFD8D2E8);
  static const Color _tracedColor = Color(0xFF25A97A);

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = _guideColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.shortestSide * 0.075;

    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.shortestSide * 0.13;

    for (final stroke in state.definition.strokes) {
      final path = _pathForPoints(
        stroke.checkpoints.map((checkpoint) => checkpoint.point),
        size,
      );
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, guidePaint);
    }

    final tracedPaint = Paint()
      ..color = _tracedColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.shortestSide * 0.075;

    for (var index = 0; index < state.currentStrokeIndex; index++) {
      final stroke = state.definition.strokes[index];
      canvas.drawPath(
        _pathForPoints(
          stroke.checkpoints.map((checkpoint) => checkpoint.point),
          size,
        ),
        tracedPaint,
      );
    }

    final currentStroke = state.currentStroke;
    if (currentStroke != null && state.nextCheckpointIndex > 0) {
      final acceptedPoints = <TracePoint>[
        ...currentStroke.checkpoints
            .take(state.nextCheckpointIndex)
            .map((checkpoint) => checkpoint.point),
        if (state.lastAcceptedPoint != null) state.lastAcceptedPoint!,
      ];
      if (acceptedPoints.length > 1) {
        final activePaint = Paint()
          ..color = activeColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = size.shortestSide * 0.075;
        canvas.drawPath(_pathForPoints(acceptedPoints, size), activePaint);
      }
    }

    if (!state.isCompleted && currentStroke != null) {
      final targetIndex = state.isPointerActive
          ? state.nextCheckpointIndex.clamp(
              0,
              currentStroke.checkpoints.length - 1,
            )
          : 0;
      final nextIndex = (targetIndex + 1).clamp(
        0,
        currentStroke.checkpoints.length - 1,
      );
      final target = currentStroke.checkpoints[targetIndex].point;
      final center = _offset(target, size);
      final pulseColor = state.status == TraceStatus.offPath
          ? hintColor
          : activeColor;
      final baseRadius = size.shortestSide * 0.032;
      final pulseRadius =
          baseRadius + (size.shortestSide * 0.018 * pulse.value);

      canvas.drawCircle(
        center,
        pulseRadius * 1.8,
        Paint()..color = pulseColor.withValues(alpha: 0.16),
      );
      canvas.drawCircle(center, pulseRadius, Paint()..color = pulseColor);
      canvas.drawCircle(
        center,
        pulseRadius * 0.38,
        Paint()..color = Colors.white,
      );

      if (nextIndex != targetIndex) {
        _drawMovingGuide(
          canvas: canvas,
          size: size,
          from: target,
          to: currentStroke.checkpoints[nextIndex].point,
          color: pulseColor,
        );
      }
      _drawTargetSparkles(canvas, center, size, pulseColor);
    }
  }

  void _drawMovingGuide({
    required Canvas canvas,
    required Size size,
    required TracePoint from,
    required TracePoint to,
    required Color color,
  }) {
    final start = _offset(from, size);
    final end = _offset(to, size);
    final guidePaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * 0.018;
    canvas.drawLine(start, end, guidePaint);

    for (var index = 0; index < 3; index += 1) {
      final t = ((pulse.value + (index * 0.22)) % 1.0).clamp(0.0, 1.0);
      final bead = Offset.lerp(start, end, t)!;
      final radius = size.shortestSide * (0.013 + (index * 0.002));
      canvas.drawCircle(
        bead,
        radius * 2.3,
        Paint()..color = Colors.white.withValues(alpha: 0.72),
      );
      canvas.drawCircle(bead, radius, Paint()..color = color);
    }
  }

  void _drawTargetSparkles(
    Canvas canvas,
    Offset center,
    Size size,
    Color color,
  ) {
    final sparklePaint = Paint()
      ..color = color.withValues(alpha: 0.52)
      ..style = PaintingStyle.fill;
    final orbit = size.shortestSide * (0.065 + (pulse.value * 0.012));
    final radius = size.shortestSide * 0.008;

    for (var index = 0; index < 3; index += 1) {
      final angle = (pulse.value * math.pi * 2) + (index * math.pi * 0.72);
      final point = center + Offset(math.cos(angle), math.sin(angle)) * orbit;
      canvas.drawCircle(point, radius, sparklePaint);
    }
  }

  Path _pathForPoints(Iterable<TracePoint> points, Size size) {
    final iterator = points.iterator;
    final path = Path();
    if (!iterator.moveNext()) {
      return path;
    }

    final first = _offset(iterator.current, size);
    path.moveTo(first.dx, first.dy);
    while (iterator.moveNext()) {
      final point = _offset(iterator.current, size);
      path.lineTo(point.dx, point.dy);
    }
    return path;
  }

  Offset _offset(TracePoint point, Size size) {
    return Offset(point.x * size.width, point.y * size.height);
  }

  @override
  bool shouldRepaint(covariant TracePainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.hintColor != hintColor;
  }
}
