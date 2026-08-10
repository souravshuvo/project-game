import 'dart:math' as math;

import 'dots_and_boxes.dart';

class BoardMetrics {
  const BoardMetrics({
    required this.originX,
    required this.originY,
    required this.cellSize,
    required this.boardWidth,
    required this.boardHeight,
  });

  final double originX;
  final double originY;
  final double cellSize;
  final double boardWidth;
  final double boardHeight;

  double dotX(int column) => originX + column * cellSize;

  double dotY(int row) => originY + row * cellSize;
}

class BoardHitTester {
  const BoardHitTester({
    required this.rows,
    required this.columns,
    required this.width,
    required this.height,
    this.edgePadding = 28,
    this.touchTolerance = 22,
    this.ambiguityMargin = 7,
  }) : assert(rows > 0),
       assert(columns > 0),
       assert(width >= 0),
       assert(height >= 0),
       assert(edgePadding >= 0),
       assert(touchTolerance > 0),
       assert(ambiguityMargin >= 0);

  final int rows;
  final int columns;
  final double width;
  final double height;
  final double edgePadding;
  final double touchTolerance;
  final double ambiguityMargin;

  BoardMetrics get metrics {
    final availableWidth = math.max(0.0, width - edgePadding * 2);
    final availableHeight = math.max(0.0, height - edgePadding * 2);
    final cellSize = math.min(availableWidth / columns, availableHeight / rows);
    final boardWidth = cellSize * columns;
    final boardHeight = cellSize * rows;

    return BoardMetrics(
      originX: (width - boardWidth) / 2,
      originY: (height - boardHeight) / 2,
      cellSize: cellSize,
      boardWidth: boardWidth,
      boardHeight: boardHeight,
    );
  }

  BoardLine? hitTest(double x, double y) {
    final layout = metrics;
    if (layout.cellSize <= 0) {
      return null;
    }

    final capSlop = math.min(touchTolerance * 0.4, layout.cellSize * 0.14);
    final candidates = <_LineCandidate>[];

    for (var row = 0; row <= rows; row += 1) {
      final lineY = layout.dotY(row);
      for (var column = 0; column < columns; column += 1) {
        final x1 = layout.dotX(column);
        final x2 = layout.dotX(column + 1);
        if (x < x1 - capSlop || x > x2 + capSlop) {
          continue;
        }

        final distance = _distanceToSegment(x, y, x1, lineY, x2, lineY);
        if (distance <= touchTolerance) {
          candidates.add(
            _LineCandidate(BoardLine.horizontal(row, column), distance),
          );
        }
      }
    }

    for (var row = 0; row < rows; row += 1) {
      final y1 = layout.dotY(row);
      final y2 = layout.dotY(row + 1);
      for (var column = 0; column <= columns; column += 1) {
        final lineX = layout.dotX(column);
        if (y < y1 - capSlop || y > y2 + capSlop) {
          continue;
        }

        final distance = _distanceToSegment(x, y, lineX, y1, lineX, y2);
        if (distance <= touchTolerance) {
          candidates.add(
            _LineCandidate(BoardLine.vertical(row, column), distance),
          );
        }
      }
    }

    if (candidates.isEmpty) {
      return null;
    }

    candidates.sort((a, b) => a.distance.compareTo(b.distance));
    if (candidates.length > 1 &&
        candidates[1].distance - candidates[0].distance < ambiguityMargin) {
      return null;
    }

    return candidates.first.line;
  }

  double _distanceToSegment(
    double px,
    double py,
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final lengthSquared = dx * dx + dy * dy;
    if (lengthSquared == 0) {
      return math.sqrt((px - x1) * (px - x1) + (py - y1) * (py - y1));
    }

    final projection = ((px - x1) * dx + (py - y1) * dy) / lengthSquared;
    final t = math.max(0.0, math.min(1.0, projection));
    final nearestX = x1 + t * dx;
    final nearestY = y1 + t * dy;
    return math.sqrt(
      (px - nearestX) * (px - nearestX) + (py - nearestY) * (py - nearestY),
    );
  }
}

class _LineCandidate {
  const _LineCandidate(this.line, this.distance);

  final BoardLine line;
  final double distance;
}
