import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/board_spec.dart';
import '../../domain/models.dart';
import 'board_painter.dart';
import 'board_palette.dart';

class BoardView extends StatelessWidget {
  const BoardView({
    super.key,
    required this.state,
    required this.selectedNode,
    required this.legalMoves,
    required this.hintMove,
    required this.palette,
    required this.onNodeTap,
  });

  final MatchState state;
  final int? selectedNode;
  final List<GameMove> legalMoves;
  final GameMove? hintMove;
  final BoardPalette palette;
  final ValueChanged<int> onNodeTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final beadSize = side * 0.072;
        final hitSize = side * 0.12;

        return SizedBox.square(
          dimension: side,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.board,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: palette.border),
                  ),
                  child: CustomPaint(
                    painter: BoardPainter(
                      selectedNode: selectedNode,
                      legalMoves: legalMoves,
                      hintMove: hintMove,
                      palette: palette,
                    ),
                  ),
                ),
              ),
              for (final node in BoardSpec.nodes)
                _NodeHitTarget(
                  nodeId: node.id,
                  state: state,
                  palette: palette,
                  position: BoardGeometry.pointFor(Size.square(side), node),
                  beadSize: beadSize,
                  hitSize: hitSize,
                  onTap: () => onNodeTap(node.id),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NodeHitTarget extends StatelessWidget {
  const _NodeHitTarget({
    required this.nodeId,
    required this.state,
    required this.palette,
    required this.position,
    required this.beadSize,
    required this.hitSize,
    required this.onTap,
  });

  final int nodeId;
  final MatchState state;
  final BoardPalette palette;
  final Offset position;
  final double beadSize;
  final double hitSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final occupant = state.occupancy[nodeId];

    return Positioned(
      left: position.dx - hitSize / 2,
      top: position.dy - hitSize / 2,
      width: hitSize,
      height: hitSize,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: occupant == null ? beadSize * 0.35 : beadSize,
            height: occupant == null ? beadSize * 0.35 : beadSize,
            decoration: BoxDecoration(
              color: _colorFor(occupant),
              shape: BoxShape.circle,
              border: occupant == null
                  ? null
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: 2,
                    ),
              boxShadow: occupant == null
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  Color _colorFor(Player? player) {
    return switch (player) {
      Player.player1 => palette.player1,
      Player.player2 => palette.player2,
      null => palette.emptyNode,
    };
  }
}
