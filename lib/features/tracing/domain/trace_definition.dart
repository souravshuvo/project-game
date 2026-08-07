import 'dart:math' as math;

/// A point in trace-canvas coordinates, where both axes range from 0 to 1.
///
/// Keeping trace definitions normalized makes them independent of the rendered
/// canvas size. A UI should convert pointer positions to this coordinate space
/// before passing them to the tracing controller.
final class TracePoint {
  TracePoint(this.x, this.y) {
    if (!x.isFinite || x < 0 || x > 1) {
      throw RangeError.range(x, 0, 1, 'x');
    }
    if (!y.isFinite || y < 0 || y > 1) {
      throw RangeError.range(y, 0, 1, 'y');
    }
  }

  final double x;
  final double y;

  double distanceTo(TracePoint other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt((dx * dx) + (dy * dy));
  }

  TracePoint interpolate(TracePoint other, double t) {
    if (!t.isFinite || t < 0 || t > 1) {
      throw RangeError.range(t, 0, 1, 't');
    }
    return TracePoint(x + ((other.x - x) * t), y + ((other.y - y) * t));
  }

  @override
  bool operator ==(Object other) {
    return other is TracePoint && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'TracePoint($x, $y)';
}

/// One ordered target that must be reached while drawing a stroke.
final class TraceCheckpoint {
  TraceCheckpoint({required this.point, this.hitRadius = 0.08}) {
    if (!hitRadius.isFinite || hitRadius <= 0 || hitRadius > 1) {
      throw RangeError.range(hitRadius, 0, 1, 'hitRadius');
    }
  }

  final TracePoint point;

  /// The normalized distance within which this checkpoint counts as reached.
  final double hitRadius;
}

/// A continuous, ordered part of a trace definition.
final class TraceStroke {
  TraceStroke({
    required this.id,
    required List<TraceCheckpoint> checkpoints,
    this.corridorRadius = 0.09,
  }) : checkpoints = List.unmodifiable(checkpoints) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'A stroke id cannot be empty.');
    }
    if (checkpoints.length < 2) {
      throw ArgumentError.value(
        checkpoints,
        'checkpoints',
        'A stroke needs at least two checkpoints.',
      );
    }
    if (!corridorRadius.isFinite || corridorRadius <= 0 || corridorRadius > 1) {
      throw RangeError.range(corridorRadius, 0, 1, 'corridorRadius');
    }
  }

  final String id;
  final List<TraceCheckpoint> checkpoints;

  /// Maximum normalized distance accepted from this stroke's center line.
  final double corridorRadius;

  TracePoint get start => checkpoints.first.point;
  TracePoint get end => checkpoints.last.point;
}

/// Immutable geometry and stroke order for a traceable symbol.
final class TraceDefinition {
  TraceDefinition({required this.symbol, required List<TraceStroke> strokes})
    : strokes = List.unmodifiable(strokes) {
    if (symbol.trim().isEmpty) {
      throw ArgumentError.value(
        symbol,
        'symbol',
        'A trace symbol cannot be empty.',
      );
    }
    if (strokes.isEmpty) {
      throw ArgumentError.value(
        strokes,
        'strokes',
        'A trace definition needs at least one stroke.',
      );
    }

    final ids = <String>{};
    for (final stroke in strokes) {
      if (!ids.add(stroke.id)) {
        throw ArgumentError.value(
          stroke.id,
          'strokes',
          'Stroke ids must be unique.',
        );
      }
    }
  }

  final String symbol;
  final List<TraceStroke> strokes;

  int get checkpointCount =>
      strokes.fold(0, (total, stroke) => total + stroke.checkpoints.length);

  /// A child-friendly uppercase A: left leg, right leg, then crossbar.
  factory TraceDefinition.uppercaseA() {
    TraceCheckpoint checkpoint(double x, double y) =>
        TraceCheckpoint(point: TracePoint(x, y));

    return TraceDefinition(
      symbol: 'A',
      strokes: [
        TraceStroke(
          id: 'left-leg',
          checkpoints: [
            checkpoint(0.20, 0.88),
            checkpoint(0.275, 0.69),
            checkpoint(0.35, 0.50),
            checkpoint(0.425, 0.31),
            checkpoint(0.50, 0.12),
          ],
        ),
        TraceStroke(
          id: 'right-leg',
          checkpoints: [
            checkpoint(0.50, 0.12),
            checkpoint(0.575, 0.31),
            checkpoint(0.65, 0.50),
            checkpoint(0.725, 0.69),
            checkpoint(0.80, 0.88),
          ],
        ),
        TraceStroke(
          id: 'crossbar',
          checkpoints: [
            checkpoint(0.325, 0.565),
            checkpoint(0.4125, 0.565),
            checkpoint(0.50, 0.565),
            checkpoint(0.5875, 0.565),
            checkpoint(0.675, 0.565),
          ],
        ),
      ],
    );
  }

  /// A child-friendly uppercase B: spine, top tummy, then bottom tummy.
  factory TraceDefinition.uppercaseB() {
    return TraceDefinition(
      symbol: 'B',
      strokes: [
        _traceStroke(
          'spine',
          const [
            (0.31, 0.14),
            (0.31, 0.32),
            (0.31, 0.50),
            (0.31, 0.68),
            (0.31, 0.86),
          ],
        ),
        _traceStroke(
          'top-bowl',
          const [
            (0.31, 0.14),
            (0.48, 0.14),
            (0.64, 0.20),
            (0.70, 0.32),
            (0.64, 0.44),
            (0.48, 0.50),
            (0.31, 0.50),
          ],
        ),
        _traceStroke(
          'bottom-bowl',
          const [
            (0.31, 0.50),
            (0.50, 0.50),
            (0.68, 0.56),
            (0.74, 0.69),
            (0.68, 0.81),
            (0.50, 0.86),
            (0.31, 0.86),
          ],
        ),
      ],
    );
  }

  /// A single, continuous uppercase C drawn from top-right to bottom-right.
  factory TraceDefinition.uppercaseC() {
    return TraceDefinition(
      symbol: 'C',
      strokes: [
        _traceStroke(
          'curve',
          const [
            (0.73, 0.24),
            (0.63, 0.16),
            (0.49, 0.13),
            (0.36, 0.18),
            (0.27, 0.30),
            (0.23, 0.50),
            (0.27, 0.70),
            (0.36, 0.82),
            (0.49, 0.87),
            (0.63, 0.84),
            (0.73, 0.76),
          ],
        ),
      ],
    );
  }

  /// A simple number 1 with a lead-in, downstroke, and baseline.
  factory TraceDefinition.numberOne() {
    return TraceDefinition(
      symbol: '1',
      strokes: [
        _traceStroke(
          'lead-in-and-down',
          const [
            (0.37, 0.29),
            (0.47, 0.20),
            (0.55, 0.13),
            (0.55, 0.36),
            (0.55, 0.60),
            (0.55, 0.85),
          ],
        ),
        _traceStroke(
          'baseline',
          const [(0.38, 0.85), (0.55, 0.85), (0.72, 0.85)],
        ),
      ],
    );
  }

  /// A continuous number 2: curved top, diagonal slide, then baseline.
  factory TraceDefinition.numberTwo() {
    return TraceDefinition(
      symbol: '2',
      strokes: [
        _traceStroke(
          'curve-and-base',
          const [
            (0.29, 0.29),
            (0.36, 0.18),
            (0.50, 0.13),
            (0.64, 0.17),
            (0.72, 0.29),
            (0.68, 0.42),
            (0.58, 0.53),
            (0.47, 0.63),
            (0.36, 0.74),
            (0.28, 0.85),
            (0.50, 0.85),
            (0.73, 0.85),
          ],
        ),
      ],
    );
  }

  /// A continuous number 3 with two rounded tummies.
  factory TraceDefinition.numberThree() {
    return TraceDefinition(
      symbol: '3',
      strokes: [
        _traceStroke(
          'double-curve',
          const [
            (0.31, 0.23),
            (0.41, 0.15),
            (0.55, 0.13),
            (0.68, 0.19),
            (0.72, 0.31),
            (0.67, 0.42),
            (0.55, 0.50),
            (0.67, 0.56),
            (0.73, 0.68),
            (0.69, 0.80),
            (0.56, 0.87),
            (0.41, 0.85),
            (0.30, 0.77),
          ],
        ),
      ],
    );
  }

  /// Short aliases are convenient for catalog and test code.
  factory TraceDefinition.digit1() => TraceDefinition.numberOne();

  factory TraceDefinition.digit2() => TraceDefinition.numberTwo();

  factory TraceDefinition.digit3() => TraceDefinition.numberThree();
}

TraceStroke _traceStroke(
  String id,
  List<(double, double)> points, {
  double corridorRadius = 0.105,
  double hitRadius = 0.095,
}) {
  return TraceStroke(
    id: id,
    corridorRadius: corridorRadius,
    checkpoints: [
      for (final (x, y) in points)
        TraceCheckpoint(point: TracePoint(x, y), hitRadius: hitRadius),
    ],
  );
}
