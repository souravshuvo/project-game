import 'dart:math' as math;

import '../domain/trace_definition.dart';

/// The interaction phase exposed to a tracing UI.
enum TraceStatus {
  /// Waiting for a gesture at the first checkpoint of the current stroke.
  ready,

  /// A valid gesture is currently progressing along the stroke.
  tracing,

  /// The last gesture left the allowed corridor and must be restarted.
  offPath,

  /// Every checkpoint in every stroke has been reached in order.
  completed,
}

/// Immutable tracing state suitable for rendering directly in a UI.
final class TraceState {
  const TraceState._({
    required this.definition,
    required this.status,
    required this.currentStrokeIndex,
    required this.nextCheckpointIndex,
    required this.completedCheckpointCount,
    this.lastAcceptedPoint,
    this.offPathPoint,
  });

  final TraceDefinition definition;
  final TraceStatus status;

  /// Index of the stroke the child should draw next.
  ///
  /// This equals `definition.strokes.length` after completion.
  final int currentStrokeIndex;

  /// Index of the next checkpoint in [currentStroke], or zero while ready.
  final int nextCheckpointIndex;

  /// Checkpoints accepted across completed strokes and the active stroke.
  final int completedCheckpointCount;

  /// Most recent accepted normalized pointer position while tracing.
  final TracePoint? lastAcceptedPoint;

  /// Pointer position supplied by the rejected update or start.
  final TracePoint? offPathPoint;

  TraceStroke? get currentStroke =>
      currentStrokeIndex < definition.strokes.length
      ? definition.strokes[currentStrokeIndex]
      : null;

  double get progress => definition.checkpointCount == 0
      ? 0
      : completedCheckpointCount / definition.checkpointCount;

  double get currentStrokeProgress {
    final stroke = currentStroke;
    if (stroke == null) {
      return 1;
    }
    return nextCheckpointIndex / stroke.checkpoints.length;
  }

  bool get isPointerActive => status == TraceStatus.tracing;
  bool get isCompleted => status == TraceStatus.completed;
}

/// Pure-Dart controller for ordered, corridor-based tracing interactions.
///
/// Call [start] on pointer down, [update] on pointer movement, and [end] on
/// pointer up/cancel. Each method returns the new immutable [state].
final class TraceController {
  TraceController({
    required TraceDefinition definition,
    this.interpolationStep = 0.02,
  }) : _definition = definition,
       _state = TraceState._(
         definition: definition,
         status: TraceStatus.ready,
         currentStrokeIndex: 0,
         nextCheckpointIndex: 0,
         completedCheckpointCount: 0,
       ) {
    if (!interpolationStep.isFinite ||
        interpolationStep <= 0 ||
        interpolationStep > 1) {
      throw RangeError.range(interpolationStep, 0, 1, 'interpolationStep');
    }
  }

  factory TraceController.uppercaseA({double interpolationStep = 0.02}) {
    return TraceController(
      definition: TraceDefinition.uppercaseA(),
      interpolationStep: interpolationStep,
    );
  }

  final TraceDefinition _definition;

  /// Maximum spacing between synthesized samples in normalized coordinates.
  final double interpolationStep;

  TraceState _state;
  TraceState get state => _state;

  /// Starts the current stroke if [point] hits its first checkpoint.
  TraceState start(TracePoint point) {
    if (_state.isCompleted || _state.isPointerActive) {
      return _state;
    }

    final stroke = _definition.strokes[_state.currentStrokeIndex];
    final first = stroke.checkpoints.first;
    if (point.distanceTo(first.point) > first.hitRadius) {
      return _reject(point);
    }

    _state = TraceState._(
      definition: _definition,
      status: TraceStatus.tracing,
      currentStrokeIndex: _state.currentStrokeIndex,
      nextCheckpointIndex: 1,
      completedCheckpointCount: _completedBeforeCurrentStroke + 1,
      lastAcceptedPoint: point,
    );
    return _state;
  }

  /// Adds a pointer sample, interpolating gaps before testing the trace path.
  TraceState update(TracePoint point) {
    if (!_state.isPointerActive) {
      return _state;
    }

    final previous = _state.lastAcceptedPoint!;
    final distance = previous.distanceTo(point);
    final sampleCount = math.max(1, (distance / interpolationStep).ceil());
    var nextCheckpointIndex = _state.nextCheckpointIndex;
    final stroke = _definition.strokes[_state.currentStrokeIndex];

    for (var index = 1; index <= sampleCount; index++) {
      final sample = previous.interpolate(point, index / sampleCount);
      if (_distanceToStroke(sample, stroke) > stroke.corridorRadius) {
        return _reject(point);
      }

      while (nextCheckpointIndex < stroke.checkpoints.length &&
          sample.distanceTo(stroke.checkpoints[nextCheckpointIndex].point) <=
              stroke.checkpoints[nextCheckpointIndex].hitRadius) {
        nextCheckpointIndex++;
      }

      if (nextCheckpointIndex == stroke.checkpoints.length) {
        return _completeCurrentStroke();
      }
    }

    _state = TraceState._(
      definition: _definition,
      status: TraceStatus.tracing,
      currentStrokeIndex: _state.currentStrokeIndex,
      nextCheckpointIndex: nextCheckpointIndex,
      completedCheckpointCount:
          _completedBeforeCurrentStroke + nextCheckpointIndex,
      lastAcceptedPoint: point,
    );
    return _state;
  }

  /// Ends a gesture. An unfinished stroke returns to its first checkpoint.
  TraceState end() {
    if (_state.isCompleted ||
        _state.status == TraceStatus.ready ||
        _state.status == TraceStatus.offPath) {
      return _state;
    }

    _state = TraceState._(
      definition: _definition,
      status: TraceStatus.ready,
      currentStrokeIndex: _state.currentStrokeIndex,
      nextCheckpointIndex: 0,
      completedCheckpointCount: _completedBeforeCurrentStroke,
    );
    return _state;
  }

  /// Clears all trace progress.
  TraceState reset() {
    _state = TraceState._(
      definition: _definition,
      status: TraceStatus.ready,
      currentStrokeIndex: 0,
      nextCheckpointIndex: 0,
      completedCheckpointCount: 0,
    );
    return _state;
  }

  int get _completedBeforeCurrentStroke {
    var completed = 0;
    for (var index = 0; index < _state.currentStrokeIndex; index++) {
      completed += _definition.strokes[index].checkpoints.length;
    }
    return completed;
  }

  TraceState _reject(TracePoint point) {
    _state = TraceState._(
      definition: _definition,
      status: TraceStatus.offPath,
      currentStrokeIndex: _state.currentStrokeIndex,
      nextCheckpointIndex: 0,
      completedCheckpointCount: _completedBeforeCurrentStroke,
      offPathPoint: point,
    );
    return _state;
  }

  TraceState _completeCurrentStroke() {
    final nextStrokeIndex = _state.currentStrokeIndex + 1;
    final completed = nextStrokeIndex == _definition.strokes.length;

    _state = TraceState._(
      definition: _definition,
      status: completed ? TraceStatus.completed : TraceStatus.ready,
      currentStrokeIndex: nextStrokeIndex,
      nextCheckpointIndex: 0,
      completedCheckpointCount: completed
          ? _definition.checkpointCount
          : _completedThroughStroke(nextStrokeIndex),
    );
    return _state;
  }

  int _completedThroughStroke(int strokeCount) {
    var completed = 0;
    for (var index = 0; index < strokeCount; index++) {
      completed += _definition.strokes[index].checkpoints.length;
    }
    return completed;
  }

  static double _distanceToStroke(TracePoint point, TraceStroke stroke) {
    var closest = double.infinity;
    for (var index = 0; index < stroke.checkpoints.length - 1; index++) {
      final start = stroke.checkpoints[index].point;
      final end = stroke.checkpoints[index + 1].point;
      closest = math.min(closest, _distanceToSegment(point, start, end));
    }
    return closest;
  }

  static double _distanceToSegment(
    TracePoint point,
    TracePoint start,
    TracePoint end,
  ) {
    final segmentX = end.x - start.x;
    final segmentY = end.y - start.y;
    final lengthSquared = (segmentX * segmentX) + (segmentY * segmentY);
    if (lengthSquared == 0) {
      return point.distanceTo(start);
    }

    final projection =
        (((point.x - start.x) * segmentX) + ((point.y - start.y) * segmentY)) /
        lengthSquared;
    final t = projection.clamp(0.0, 1.0);
    final projected = TracePoint(
      start.x + (segmentX * t),
      start.y + (segmentY * t),
    );
    return point.distanceTo(projected);
  }
}
