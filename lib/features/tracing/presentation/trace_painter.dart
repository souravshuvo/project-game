import 'package:flutter/material.dart';

import '../application/trace_controller.dart';
import '../domain/trace_definition.dart';

class TracePainter extends CustomPainter {
  TracePainter({required this.state, required this.pulse})
    : super(repaint: pulse);

  final TraceState state;
  final Animation<double> pulse;

  static const Color _guideColor = Color(0xFFD8D2E8);
  static const Color _tracedColor = Color(0xFF25A97A);
  static const Color _activeColor = Color(0xFF7257E8);
  static const Color _hintColor = Color(0xFFFFA62B);

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
          ..color = _activeColor
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
      final target = currentStroke.checkpoints[targetIndex].point;
      final center = _offset(target, size);
      final hintColor = state.status == TraceStatus.offPath
          ? _hintColor
          : _activeColor;
      final baseRadius = size.shortestSide * 0.032;
      final pulseRadius =
          baseRadius + (size.shortestSide * 0.018 * pulse.value);

      canvas.drawCircle(
        center,
        pulseRadius * 1.8,
        Paint()..color = hintColor.withValues(alpha: 0.16),
      );
      canvas.drawCircle(center, pulseRadius, Paint()..color = hintColor);
      canvas.drawCircle(
        center,
        pulseRadius * 0.38,
        Paint()..color = Colors.white,
      );
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
    return oldDelegate.state != state;
  }
}
