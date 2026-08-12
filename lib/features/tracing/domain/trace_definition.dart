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
        _traceStroke('spine', const [
          (0.31, 0.14),
          (0.31, 0.32),
          (0.31, 0.50),
          (0.31, 0.68),
          (0.31, 0.86),
        ]),
        _traceStroke('top-bowl', const [
          (0.31, 0.14),
          (0.48, 0.14),
          (0.64, 0.20),
          (0.70, 0.32),
          (0.64, 0.44),
          (0.48, 0.50),
          (0.31, 0.50),
        ]),
        _traceStroke('bottom-bowl', const [
          (0.31, 0.50),
          (0.50, 0.50),
          (0.68, 0.56),
          (0.74, 0.69),
          (0.68, 0.81),
          (0.50, 0.86),
          (0.31, 0.86),
        ]),
      ],
    );
  }

  /// A single, continuous uppercase C drawn from top-right to bottom-right.
  factory TraceDefinition.uppercaseC() {
    return TraceDefinition(
      symbol: 'C',
      strokes: [
        _traceStroke('curve', const [
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
        ]),
      ],
    );
  }

  /// A simple number 1 with a lead-in, downstroke, and baseline.
  factory TraceDefinition.numberOne() {
    return TraceDefinition(
      symbol: '1',
      strokes: [
        _traceStroke('lead-in-and-down', const [
          (0.37, 0.29),
          (0.47, 0.20),
          (0.55, 0.13),
          (0.55, 0.36),
          (0.55, 0.60),
          (0.55, 0.85),
        ]),
        _traceStroke('baseline', const [
          (0.38, 0.85),
          (0.55, 0.85),
          (0.72, 0.85),
        ]),
      ],
    );
  }

  /// A continuous number 2: curved top, diagonal slide, then baseline.
  factory TraceDefinition.numberTwo() {
    return TraceDefinition(
      symbol: '2',
      strokes: [
        _traceStroke('curve-and-base', const [
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
        ]),
      ],
    );
  }

  /// A continuous number 3 with two rounded tummies.
  factory TraceDefinition.numberThree() {
    return TraceDefinition(
      symbol: '3',
      strokes: [
        _traceStroke('double-curve', const [
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
        ]),
      ],
    );
  }

  factory TraceDefinition.uppercaseD() {
    return TraceDefinition(
      symbol: 'D',
      strokes: [
        _traceStroke('spine', const [(0.30, 0.14), (0.30, 0.50), (0.30, 0.86)]),
        _traceStroke('curve', const [
          (0.30, 0.14),
          (0.54, 0.15),
          (0.72, 0.30),
          (0.78, 0.50),
          (0.72, 0.70),
          (0.54, 0.85),
          (0.30, 0.86),
        ]),
      ],
    );
  }

  factory TraceDefinition.uppercaseE() {
    return TraceDefinition(
      symbol: 'E',
      strokes: [
        _traceStroke('spine', const [(0.72, 0.14), (0.30, 0.14), (0.30, 0.86)]),
        _traceStroke('middle-arm', const [(0.30, 0.50), (0.58, 0.50)]),
        _traceStroke('bottom-arm', const [(0.30, 0.86), (0.72, 0.86)]),
      ],
    );
  }

  factory TraceDefinition.uppercaseF() {
    return TraceDefinition(
      symbol: 'F',
      strokes: [
        _traceStroke('spine', const [(0.72, 0.14), (0.30, 0.14), (0.30, 0.86)]),
        _traceStroke('middle-arm', const [(0.30, 0.50), (0.62, 0.50)]),
      ],
    );
  }

  factory TraceDefinition.uppercaseG() {
    return TraceDefinition(
      symbol: 'G',
      strokes: [
        _traceStroke('curve', const [
          (0.74, 0.25),
          (0.63, 0.16),
          (0.48, 0.13),
          (0.34, 0.19),
          (0.24, 0.34),
          (0.22, 0.52),
          (0.29, 0.72),
          (0.45, 0.86),
          (0.65, 0.84),
          (0.76, 0.72),
          (0.76, 0.58),
          (0.58, 0.58),
        ]),
      ],
    );
  }

  factory TraceDefinition.uppercaseH() {
    return TraceDefinition(
      symbol: 'H',
      strokes: [
        _traceStroke('left-post', const [
          (0.28, 0.14),
          (0.28, 0.50),
          (0.28, 0.86),
        ]),
        _traceStroke('right-post', const [
          (0.72, 0.14),
          (0.72, 0.50),
          (0.72, 0.86),
        ]),
        _traceStroke('bridge', const [
          (0.28, 0.50),
          (0.50, 0.50),
          (0.72, 0.50),
        ]),
      ],
    );
  }

  factory TraceDefinition.uppercaseI() {
    return TraceDefinition(
      symbol: 'I',
      strokes: [
        _traceStroke('top-bar', const [
          (0.32, 0.14),
          (0.50, 0.14),
          (0.68, 0.14),
        ]),
        _traceStroke('stem', const [(0.50, 0.14), (0.50, 0.50), (0.50, 0.86)]),
        _traceStroke('bottom-bar', const [
          (0.32, 0.86),
          (0.50, 0.86),
          (0.68, 0.86),
        ]),
      ],
    );
  }

  factory TraceDefinition.uppercaseJ() {
    return TraceDefinition(
      symbol: 'J',
      strokes: [
        _traceStroke('top-bar', const [
          (0.30, 0.14),
          (0.52, 0.14),
          (0.74, 0.14),
        ]),
        _traceStroke('hook', const [
          (0.58, 0.14),
          (0.58, 0.34),
          (0.58, 0.58),
          (0.55, 0.76),
          (0.44, 0.86),
          (0.30, 0.82),
        ]),
      ],
    );
  }

  factory TraceDefinition.uppercaseK() {
    return TraceDefinition(
      symbol: 'K',
      strokes: [
        _traceStroke('spine', const [(0.30, 0.14), (0.30, 0.50), (0.30, 0.86)]),
        _traceStroke('upper-arm', const [
          (0.70, 0.14),
          (0.50, 0.34),
          (0.30, 0.50),
        ]),
        _traceStroke('lower-arm', const [
          (0.30, 0.50),
          (0.52, 0.66),
          (0.74, 0.86),
        ]),
      ],
    );
  }

  factory TraceDefinition.uppercaseL() {
    return TraceDefinition(
      symbol: 'L',
      strokes: [
        _traceStroke('corner', const [
          (0.32, 0.14),
          (0.32, 0.38),
          (0.32, 0.62),
          (0.32, 0.86),
          (0.52, 0.86),
          (0.72, 0.86),
        ]),
      ],
    );
  }

  factory TraceDefinition.uppercaseM() {
    return TraceDefinition(
      symbol: 'M',
      strokes: [
        _traceStroke('zigzag', const [
          (0.22, 0.86),
          (0.22, 0.50),
          (0.22, 0.14),
          (0.40, 0.46),
          (0.50, 0.64),
          (0.60, 0.46),
          (0.78, 0.14),
          (0.78, 0.50),
          (0.78, 0.86),
        ]),
      ],
    );
  }

  factory TraceDefinition.uppercaseN() {
    return TraceDefinition(
      symbol: 'N',
      strokes: [
        _traceStroke('left-post', const [
          (0.28, 0.86),
          (0.28, 0.50),
          (0.28, 0.14),
        ]),
        _traceStroke('diagonal', const [
          (0.28, 0.14),
          (0.50, 0.50),
          (0.72, 0.86),
        ]),
        _traceStroke('right-post', const [
          (0.72, 0.86),
          (0.72, 0.50),
          (0.72, 0.14),
        ]),
      ],
    );
  }

  factory TraceDefinition.uppercaseO() {
    return TraceDefinition(symbol: 'O', strokes: [_ovalStroke('oval')]);
  }

  factory TraceDefinition.uppercaseP() {
    return TraceDefinition(
      symbol: 'P',
      strokes: [
        _traceStroke('spine', const [(0.30, 0.86), (0.30, 0.50), (0.30, 0.14)]),
        _traceStroke('bowl', const [
          (0.30, 0.14),
          (0.50, 0.14),
          (0.68, 0.22),
          (0.70, 0.36),
          (0.60, 0.48),
          (0.44, 0.52),
          (0.30, 0.50),
        ]),
      ],
    );
  }

  factory TraceDefinition.uppercaseQ() {
    return TraceDefinition(
      symbol: 'Q',
      strokes: [
        _ovalStroke('oval'),
        _traceStroke('tail', const [(0.58, 0.68), (0.68, 0.78), (0.76, 0.88)]),
      ],
    );
  }

  factory TraceDefinition.uppercaseR() {
    return TraceDefinition(
      symbol: 'R',
      strokes: [
        _traceStroke('spine', const [(0.30, 0.86), (0.30, 0.50), (0.30, 0.14)]),
        _traceStroke('bowl', const [
          (0.30, 0.14),
          (0.50, 0.14),
          (0.68, 0.22),
          (0.70, 0.36),
          (0.58, 0.48),
          (0.42, 0.52),
          (0.30, 0.50),
        ]),
        _traceStroke('leg', const [(0.42, 0.52), (0.56, 0.68), (0.74, 0.86)]),
      ],
    );
  }

  factory TraceDefinition.uppercaseS() {
    return TraceDefinition(
      symbol: 'S',
      strokes: [
        _traceStroke('curve', const [
          (0.70, 0.22),
          (0.58, 0.14),
          (0.42, 0.14),
          (0.30, 0.24),
          (0.34, 0.38),
          (0.50, 0.48),
          (0.66, 0.58),
          (0.70, 0.74),
          (0.56, 0.86),
          (0.38, 0.84),
          (0.28, 0.76),
        ]),
      ],
    );
  }

  factory TraceDefinition.uppercaseT() {
    return TraceDefinition(
      symbol: 'T',
      strokes: [
        _traceStroke('top-bar', const [
          (0.24, 0.16),
          (0.50, 0.16),
          (0.76, 0.16),
        ]),
        _traceStroke('stem', const [(0.50, 0.16), (0.50, 0.50), (0.50, 0.86)]),
      ],
    );
  }

  factory TraceDefinition.uppercaseU() {
    return TraceDefinition(
      symbol: 'U',
      strokes: [
        _traceStroke('curve', const [
          (0.28, 0.14),
          (0.28, 0.42),
          (0.30, 0.68),
          (0.40, 0.84),
          (0.50, 0.88),
          (0.60, 0.84),
          (0.70, 0.68),
          (0.72, 0.42),
          (0.72, 0.14),
        ]),
      ],
    );
  }

  factory TraceDefinition.uppercaseV() {
    return TraceDefinition(
      symbol: 'V',
      strokes: [
        _traceStroke('angle', const [
          (0.24, 0.14),
          (0.36, 0.44),
          (0.50, 0.86),
          (0.64, 0.44),
          (0.76, 0.14),
        ]),
      ],
    );
  }

  factory TraceDefinition.uppercaseW() {
    return TraceDefinition(
      symbol: 'W',
      strokes: [
        _traceStroke('zigzag', const [
          (0.18, 0.14),
          (0.28, 0.86),
          (0.42, 0.54),
          (0.50, 0.86),
          (0.58, 0.54),
          (0.72, 0.86),
          (0.82, 0.14),
        ]),
      ],
    );
  }

  factory TraceDefinition.uppercaseX() {
    return TraceDefinition(
      symbol: 'X',
      strokes: [
        _traceStroke('falling-diagonal', const [
          (0.26, 0.14),
          (0.50, 0.50),
          (0.74, 0.86),
        ]),
        _traceStroke('rising-diagonal', const [
          (0.74, 0.14),
          (0.50, 0.50),
          (0.26, 0.86),
        ]),
      ],
    );
  }

  factory TraceDefinition.uppercaseY() {
    return TraceDefinition(
      symbol: 'Y',
      strokes: [
        _traceStroke('fork', const [(0.26, 0.14), (0.50, 0.46), (0.74, 0.14)]),
        _traceStroke('stem', const [(0.50, 0.46), (0.50, 0.66), (0.50, 0.86)]),
      ],
    );
  }

  factory TraceDefinition.uppercaseZ() {
    return TraceDefinition(
      symbol: 'Z',
      strokes: [
        _traceStroke('zigzag', const [
          (0.26, 0.16),
          (0.50, 0.16),
          (0.74, 0.16),
          (0.50, 0.50),
          (0.26, 0.84),
          (0.50, 0.84),
          (0.74, 0.84),
        ]),
      ],
    );
  }

  factory TraceDefinition.numberFour() {
    return TraceDefinition(
      symbol: '4',
      strokes: [
        _traceStroke('angle', const [(0.66, 0.14), (0.42, 0.54), (0.76, 0.54)]),
        _traceStroke('downstroke', const [
          (0.66, 0.14),
          (0.66, 0.50),
          (0.66, 0.86),
        ]),
      ],
    );
  }

  factory TraceDefinition.numberFive() {
    return TraceDefinition(
      symbol: '5',
      strokes: [
        _traceStroke('top-and-spine', const [
          (0.70, 0.16),
          (0.36, 0.16),
          (0.32, 0.45),
        ]),
        _traceStroke('curve', const [
          (0.32, 0.45),
          (0.50, 0.42),
          (0.68, 0.50),
          (0.72, 0.68),
          (0.62, 0.84),
          (0.42, 0.86),
          (0.28, 0.78),
        ]),
      ],
    );
  }

  factory TraceDefinition.numberSix() {
    return TraceDefinition(
      symbol: '6',
      strokes: [
        _traceStroke('loop', const [
          (0.66, 0.20),
          (0.52, 0.14),
          (0.36, 0.22),
          (0.28, 0.42),
          (0.30, 0.66),
          (0.42, 0.84),
          (0.60, 0.82),
          (0.70, 0.66),
          (0.62, 0.52),
          (0.44, 0.52),
          (0.32, 0.64),
        ]),
      ],
    );
  }

  factory TraceDefinition.numberSeven() {
    return TraceDefinition(
      symbol: '7',
      strokes: [
        _traceStroke('top-and-slide', const [
          (0.28, 0.16),
          (0.52, 0.16),
          (0.76, 0.16),
          (0.62, 0.40),
          (0.50, 0.62),
          (0.38, 0.86),
        ]),
      ],
    );
  }

  factory TraceDefinition.numberEight() {
    return TraceDefinition(
      symbol: '8',
      strokes: [
        _traceStroke('double-loop', const [
          (0.50, 0.12),
          (0.66, 0.18),
          (0.68, 0.36),
          (0.50, 0.48),
          (0.32, 0.36),
          (0.34, 0.18),
          (0.50, 0.12),
          (0.66, 0.58),
          (0.68, 0.78),
          (0.50, 0.88),
          (0.32, 0.78),
          (0.34, 0.58),
          (0.50, 0.48),
        ]),
      ],
    );
  }

  factory TraceDefinition.numberNine() {
    return TraceDefinition(
      symbol: '9',
      strokes: [
        _traceStroke('loop-and-tail', const [
          (0.62, 0.44),
          (0.50, 0.52),
          (0.36, 0.48),
          (0.30, 0.32),
          (0.38, 0.16),
          (0.56, 0.14),
          (0.70, 0.28),
          (0.68, 0.52),
          (0.58, 0.70),
          (0.42, 0.86),
        ]),
      ],
    );
  }

  factory TraceDefinition.numberTen() {
    return TraceDefinition(
      symbol: '10',
      strokes: [
        _traceStroke('one', const [(0.25, 0.28), (0.34, 0.18), (0.34, 0.84)]),
        _traceStroke('zero', const [
          (0.66, 0.14),
          (0.80, 0.24),
          (0.82, 0.50),
          (0.80, 0.76),
          (0.66, 0.86),
          (0.52, 0.76),
          (0.50, 0.50),
          (0.52, 0.24),
          (0.66, 0.14),
        ]),
      ],
    );
  }

  /// Short aliases are convenient for catalog and test code.
  factory TraceDefinition.digit1() => TraceDefinition.numberOne();

  factory TraceDefinition.digit2() => TraceDefinition.numberTwo();

  factory TraceDefinition.digit3() => TraceDefinition.numberThree();

  factory TraceDefinition.digit4() => TraceDefinition.numberFour();

  factory TraceDefinition.digit5() => TraceDefinition.numberFive();

  factory TraceDefinition.digit6() => TraceDefinition.numberSix();

  factory TraceDefinition.digit7() => TraceDefinition.numberSeven();

  factory TraceDefinition.digit8() => TraceDefinition.numberEight();

  factory TraceDefinition.digit9() => TraceDefinition.numberNine();

  factory TraceDefinition.digit10() => TraceDefinition.numberTen();
}

TraceStroke _ovalStroke(String id) {
  return _traceStroke(id, const [
    (0.50, 0.12),
    (0.68, 0.18),
    (0.78, 0.36),
    (0.76, 0.58),
    (0.64, 0.78),
    (0.50, 0.88),
    (0.36, 0.78),
    (0.24, 0.58),
    (0.22, 0.36),
    (0.32, 0.18),
    (0.50, 0.12),
  ]);
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
