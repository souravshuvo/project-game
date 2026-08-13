import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/board_spec.dart';
import '../../domain/models.dart';
import 'board_painter.dart';

class BoardView extends StatelessWidget {
  const BoardView({
    super.key,
    required this.state,
    required this.selectedNode,
    required this.legalMoves,
    required this.onNodeTap,
    required this.onEmptyTap,
    this.lastMove,
    this.feedbackAnimation,
  });

  final MatchState state;
  final int? selectedNode;
  final List<GameMove> legalMoves;
  final ValueChanged<int> onNodeTap;
  final VoidCallback onEmptyTap;
  final GameMove? lastMove;
  final Animation<double>? feedbackAnimation;

  @override
  Widget build(BuildContext context) {
    return _BoardGestureLayer(
      state: state,
      selectedNode: selectedNode,
      legalMoves: legalMoves,
      onNodeTap: onNodeTap,
      onEmptyTap: onEmptyTap,
      lastMove: lastMove,
      feedbackAnimation: feedbackAnimation,
    );
  }
}

class _BoardGestureLayer extends StatefulWidget {
  const _BoardGestureLayer({
    required this.state,
    required this.selectedNode,
    required this.legalMoves,
    required this.onNodeTap,
    required this.onEmptyTap,
    required this.lastMove,
    required this.feedbackAnimation,
  });

  final MatchState state;
  final int? selectedNode;
  final List<GameMove> legalMoves;
  final ValueChanged<int> onNodeTap;
  final VoidCallback onEmptyTap;
  final GameMove? lastMove;
  final Animation<double>? feedbackAnimation;

  @override
  State<_BoardGestureLayer> createState() => _BoardGestureLayerState();
}

class _BoardGestureLayerState extends State<_BoardGestureLayer> {
  int? _dragStartNode;
  Offset? _latestDragPosition;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = min(constraints.maxWidth, 460.0);
        final maxHeight = constraints.maxHeight;
        var width = maxWidth;
        var height = width / 0.72;
        if (height > maxHeight) {
          height = maxHeight;
          width = height * 0.72;
        }
        final size = Size(width, height);

        return SizedBox(
          width: width,
          height: height,
          child: Semantics(
            label:
                'Sixteen Breed board. Tap or drag beads to highlighted points.',
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                _dispatchPosition(details.localPosition, size);
              },
              onPanStart: (details) {
                _latestDragPosition = details.localPosition;
                _dragStartNode = _nearestNode(details.localPosition, size);
                final node = _dragStartNode;
                if (node != null) {
                  widget.onNodeTap(node);
                }
              },
              onPanUpdate: (details) {
                _latestDragPosition = details.localPosition;
              },
              onPanEnd: (_) {
                final position = _latestDragPosition;
                final startNode = _dragStartNode;
                _latestDragPosition = null;
                _dragStartNode = null;
                if (position == null || startNode == null) {
                  return;
                }

                final endNode = _nearestNode(position, size);
                if (endNode == null) {
                  widget.onEmptyTap();
                  return;
                }
                if (endNode != startNode) {
                  widget.onNodeTap(endNode);
                }
              },
              onPanCancel: () {
                _latestDragPosition = null;
                _dragStartNode = null;
              },
              child: CustomPaint(
                painter: BoardPainter(
                  state: widget.state,
                  selectedNode: widget.selectedNode,
                  legalMoves: widget.legalMoves,
                  lastMove: widget.lastMove,
                  feedbackAnimation:
                      widget.feedbackAnimation ??
                      const AlwaysStoppedAnimation<double>(1),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _dispatchPosition(Offset position, Size size) {
    final node = _nearestNode(position, size);
    if (node == null) {
      widget.onEmptyTap();
    } else {
      widget.onNodeTap(node);
    }
  }

  int? _nearestNode(Offset tap, Size size) {
    final hitRadius = max(26.0, min(size.width, size.height) * 0.07);
    int? nearest;
    var nearestDistance = double.infinity;

    for (final node in BoardSpec.nodes) {
      final position = BoardPainter.positionFor(node, size);
      final distance = (position - tap).distance;
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = node.id;
      }
    }

    return nearestDistance <= hitRadius ? nearest : null;
  }
}
