import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/board_spec.dart';
import '../../domain/models.dart';

class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.state,
    required this.selectedNode,
    required this.legalMoves,
    required this.feedbackAnimation,
    this.lastMove,
  }) : super(repaint: feedbackAnimation);

  final MatchState state;
  final int? selectedNode;
  final List<GameMove> legalMoves;
  final GameMove? lastMove;
  final Animation<double> feedbackAnimation;

  static Offset positionFor(BoardNode node, Size size) {
    final padding = min(size.width, size.height) * 0.07;
    final rect = Rect.fromLTWH(
      padding,
      padding,
      size.width - padding * 2,
      size.height - padding * 2,
    );
    return Offset(
      rect.left + node.xRatio * rect.width,
      rect.top + node.yRatio * rect.height,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final boardRect = Offset.zero & size;
    final backgroundPaint = Paint()..color = const Color(0xFFF5E6C8);
    final borderPaint = Paint()
      ..color = const Color(0xFF5F4631)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect.deflate(2), const Radius.circular(8)),
      backgroundPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect.deflate(2), const Radius.circular(8)),
      borderPaint,
    );

    _drawEdges(canvas, size);
    _drawLastMove(canvas, size);
    _drawHighlights(canvas, size);
    _drawBeads(canvas, size);
    _drawNodeDots(canvas, size);
  }

  void _drawEdges(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3E2A1E)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    for (final edge in BoardSpec.edges) {
      canvas.drawLine(
        positionFor(BoardSpec.nodesById[edge.a]!, size),
        positionFor(BoardSpec.nodesById[edge.b]!, size),
        paint,
      );
    }
  }

  void _drawHighlights(Canvas canvas, Size size) {
    final normalPaint = Paint()..color = const Color(0xFF2E7D32);
    final normalRingPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final capturePaint = Paint()..color = const Color(0xFFC77800);
    final captureRingPaint = Paint()
      ..color = const Color(0xFFC77800)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final captureLinePaint = Paint()
      ..color = const Color(0x99C77800)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    for (final move in legalMoves.where((move) => move.isCapture)) {
      final from = positionFor(BoardSpec.nodesById[move.from]!, size);
      final over = positionFor(BoardSpec.nodesById[move.capturedNode]!, size);
      final to = positionFor(BoardSpec.nodesById[move.to]!, size);
      canvas.drawLine(from, to, captureLinePaint);
      canvas.drawCircle(
        over,
        _beadRadius(size) + 6,
        Paint()
          ..color = const Color(0xFFC77800)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.drawCircle(to, _highlightRadius(size), capturePaint);
      canvas.drawCircle(to, _beadRadius(size) + 7, captureRingPaint);
    }

    for (final move in legalMoves.where((move) => !move.isCapture)) {
      final to = positionFor(BoardSpec.nodesById[move.to]!, size);
      canvas.drawCircle(to, _highlightRadius(size), normalPaint);
      canvas.drawCircle(to, _beadRadius(size) + 5, normalRingPaint);
    }

    final selected = selectedNode;
    if (selected != null) {
      final selectedPaint = Paint()
        ..color = const Color(0xFF111111)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(
        positionFor(BoardSpec.nodesById[selected]!, size),
        _beadRadius(size) + 5,
        selectedPaint,
      );
    }
  }

  void _drawLastMove(Canvas canvas, Size size) {
    final move = lastMove;
    if (move == null) {
      return;
    }

    final progress = feedbackAnimation.value.clamp(0.0, 1.0).toDouble();
    final opacity = (1 - progress).clamp(0.0, 1.0).toDouble();
    if (opacity <= 0) {
      return;
    }

    final from = positionFor(BoardSpec.nodesById[move.from]!, size);
    final to = positionFor(BoardSpec.nodesById[move.to]!, size);
    final flashColor = move.isCapture
        ? const Color(0xFFC77800)
        : const Color(0xFF2E7D32);
    final linePaint = Paint()
      ..color = flashColor.withValues(alpha: opacity * 0.55)
      ..strokeWidth = 7 - progress * 2
      ..strokeCap = StrokeCap.round;
    final ringPaint = Paint()
      ..color = flashColor.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawLine(from, to, linePaint);
    canvas.drawCircle(to, _beadRadius(size) + 9 + progress * 12, ringPaint);

    final captured = move.capturedNode;
    if (captured != null) {
      final center = positionFor(BoardSpec.nodesById[captured]!, size);
      final radius = _beadRadius(size) + 8 + progress * 8;
      canvas.drawCircle(center, radius, ringPaint);
      canvas.drawLine(
        center.translate(-radius * 0.55, -radius * 0.55),
        center.translate(radius * 0.55, radius * 0.55),
        ringPaint,
      );
      canvas.drawLine(
        center.translate(radius * 0.55, -radius * 0.55),
        center.translate(-radius * 0.55, radius * 0.55),
        ringPaint,
      );
    }
  }

  void _drawBeads(Canvas canvas, Size size) {
    for (var nodeId = 0; nodeId < state.occupancy.length; nodeId++) {
      final player = state.occupancy[nodeId];
      if (player == null) {
        continue;
      }

      final center = positionFor(BoardSpec.nodesById[nodeId]!, size);
      final radius = _beadRadius(size);
      final shadowPaint = Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      final beadPaint = Paint()..color = _playerColor(player);
      final shinePaint = Paint()..color = const Color(0x66FFFFFF);

      canvas.drawCircle(center.translate(1.5, 2), radius, shadowPaint);
      canvas.drawCircle(center, radius, beadPaint);
      canvas.drawCircle(
        center.translate(-radius * 0.32, -radius * 0.32),
        radius * 0.28,
        shinePaint,
      );
    }
  }

  void _drawNodeDots(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF3E2A1E);
    for (final node in BoardSpec.nodes) {
      if (state.occupancy[node.id] == null) {
        canvas.drawCircle(positionFor(node, size), 3, paint);
      }
    }
  }

  double _beadRadius(Size size) => min(size.width, size.height) * 0.034;

  double _highlightRadius(Size size) => _beadRadius(size) * 0.65;

  Color _playerColor(Player player) {
    return player == Player.player1
        ? const Color(0xFFB74135)
        : const Color(0xFF265C9E);
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.selectedNode != selectedNode ||
        oldDelegate.legalMoves != legalMoves ||
        oldDelegate.lastMove != lastMove ||
        oldDelegate.feedbackAnimation != feedbackAnimation;
  }
}
