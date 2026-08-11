import 'package:flutter/material.dart';

import '../../domain/board_spec.dart';
import '../../domain/models.dart';
import 'board_palette.dart';

class BoardGeometry {
  const BoardGeometry._();

  static Offset pointFor(Size size, BoardNode node) {
    final inset = size.shortestSide * 0.08;
    final width = size.width - inset * 2;
    final height = size.height - inset * 2;
    return Offset(inset + node.xRatio * width, inset + node.yRatio * height);
  }
}

class BoardPainter extends CustomPainter {
  const BoardPainter({
    required this.selectedNode,
    required this.legalMoves,
    required this.hintMove,
    required this.palette,
  });

  final int? selectedNode;
  final List<GameMove> legalMoves;
  final GameMove? hintMove;
  final BoardPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = palette.line
      ..strokeWidth = size.shortestSide * 0.006
      ..strokeCap = StrokeCap.round;
    final nodePaint = Paint()..color = palette.node;

    for (final edge in BoardSpec.edges) {
      final a = BoardGeometry.pointFor(size, BoardSpec.nodesById[edge.a]!);
      final b = BoardGeometry.pointFor(size, BoardSpec.nodesById[edge.b]!);
      canvas.drawLine(a, b, linePaint);
    }

    for (final node in BoardSpec.nodes) {
      canvas.drawCircle(
        BoardGeometry.pointFor(size, node),
        size.shortestSide * 0.012,
        nodePaint,
      );
    }

    _drawSelection(canvas, size);
    _drawMoveHighlights(canvas, size);
    _drawHint(canvas, size);
  }

  void _drawSelection(Canvas canvas, Size size) {
    final selected = selectedNode;
    if (selected == null) {
      return;
    }

    final point = BoardGeometry.pointFor(size, BoardSpec.nodesById[selected]!);
    final paint = Paint()
      ..color = palette.selected
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.008;
    canvas.drawCircle(point, size.shortestSide * 0.048, paint);
  }

  void _drawMoveHighlights(Canvas canvas, Size size) {
    final normalPaint = Paint()
      ..color = palette.normalMove.withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;
    final capturePaint = Paint()
      ..color = palette.captureMove
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.01;
    final capturedPaint = Paint()
      ..color = palette.capturedBead
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.007;

    for (final move in legalMoves) {
      final destination = BoardGeometry.pointFor(
        size,
        BoardSpec.nodesById[move.to]!,
      );

      if (move.isCapture) {
        canvas.drawCircle(destination, size.shortestSide * 0.042, capturePaint);
        final capturedNode = move.capturedNode;
        if (capturedNode != null) {
          canvas.drawCircle(
            BoardGeometry.pointFor(size, BoardSpec.nodesById[capturedNode]!),
            size.shortestSide * 0.04,
            capturedPaint,
          );
        }
      } else {
        canvas.drawCircle(destination, size.shortestSide * 0.026, normalPaint);
      }
    }
  }

  void _drawHint(Canvas canvas, Size size) {
    final move = hintMove;
    if (move == null) {
      return;
    }

    final from = BoardGeometry.pointFor(size, BoardSpec.nodesById[move.from]!);
    final to = BoardGeometry.pointFor(size, BoardSpec.nodesById[move.to]!);
    final paint = Paint()
      ..color = palette.hint
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.01
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
    canvas.drawCircle(from, size.shortestSide * 0.055, paint);
    canvas.drawCircle(to, size.shortestSide * 0.05, paint);
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.selectedNode != selectedNode ||
        oldDelegate.legalMoves != legalMoves ||
        oldDelegate.hintMove != hintMove ||
        oldDelegate.palette != palette;
  }
}
