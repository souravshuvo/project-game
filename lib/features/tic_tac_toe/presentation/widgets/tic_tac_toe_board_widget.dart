import 'package:flutter/material.dart';

import '../../application/tic_tac_toe_controller.dart';
import '../../domain/tic_tac_toe_mark.dart';
import '../theme/pocket_observatory_theme.dart';

class TicTacToeBoardWidget extends StatelessWidget {
  const TicTacToeBoardWidget({super.key, required this.controller});

  final TicTacToeController controller;

  @override
  Widget build(BuildContext context) {
    final availableSide = MediaQuery.sizeOf(context).shortestSide - 36;
    final boardSide = availableSide.clamp(220.0, 470.0);

    return SizedBox.square(
      dimension: boardSide,
      child: ObservatoryPanel(
        padding: const EdgeInsets.all(12),
        color: PocketObservatoryColors.panel,
        borderColor: PocketObservatoryColors.gold.withValues(alpha: 0.62),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final mark = controller.round.board.cellAt(index);

            return _BoardCell(
              index: index,
              mark: mark,
              canTap: controller.canTapCell(index),
              isLastMove: controller.lastMoveIndex == index,
              isInvalid: controller.lastInvalidIndex == index,
              invalidTapSequence: controller.invalidTapSequence,
              isWinningCell: controller.round.outcome.winningLine.contains(
                index,
              ),
              onTap: () => controller.tapCell(index),
            );
          },
        ),
      ),
    );
  }
}

class _BoardCell extends StatefulWidget {
  const _BoardCell({
    required this.index,
    required this.mark,
    required this.canTap,
    required this.isLastMove,
    required this.isInvalid,
    required this.invalidTapSequence,
    required this.isWinningCell,
    required this.onTap,
  });

  final int index;
  final TicTacToeMark? mark;
  final bool canTap;
  final bool isLastMove;
  final bool isInvalid;
  final int invalidTapSequence;
  final bool isWinningCell;
  final VoidCallback onTap;

  @override
  State<_BoardCell> createState() => _BoardCellState();
}

class _BoardCellState extends State<_BoardCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
  }

  @override
  void didUpdateWidget(covariant _BoardCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isInvalid &&
        oldWidget.invalidTapSequence != widget.invalidTapSequence) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mark = widget.mark;
    final row = widget.index ~/ 3 + 1;
    final column = widget.index % 3 + 1;
    final label = mark == null
        ? 'Row $row, column $column, empty'
        : 'Row $row, column $column, ${mark.symbol}';

    return Semantics(
      label: label,
      button: widget.canTap,
      enabled: widget.canTap,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeOffset(_shakeController.value), 0),
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: _cellColor(),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor(), width: 2),
            ),
            child: AnimatedScale(
              scale: widget.isLastMove ? 1.04 : 1,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 170),
                child: mark == null
                    ? const SizedBox.shrink()
                    : _MarkGlyph(key: ValueKey(mark), mark: mark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _shakeOffset(double value) {
    if (!widget.isInvalid) {
      return 0;
    }

    final direction = value < 0.25 || (value > 0.5 && value < 0.75) ? 1 : -1;
    return direction * 7 * (1 - value);
  }

  Color _cellColor() {
    if (widget.isWinningCell) {
      return PocketObservatoryColors.gold.withValues(alpha: 0.34);
    }
    if (widget.canTap) {
      return PocketObservatoryColors.panelSoft;
    }

    return PocketObservatoryColors.panel;
  }

  Color _borderColor() {
    if (widget.isWinningCell) {
      return PocketObservatoryColors.gold;
    }
    if (widget.isInvalid) {
      return PocketObservatoryColors.rose;
    }

    return PocketObservatoryColors.line;
  }
}

class _MarkGlyph extends StatelessWidget {
  const _MarkGlyph({super.key, required this.mark});

  final TicTacToeMark mark;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MarkPainter(mark),
      child: const SizedBox.expand(),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter(this.mark);

  final TicTacToeMark mark;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = size.shortestSide;
    if (mark == TicTacToeMark.x) {
      final paint = Paint()
        ..color = PocketObservatoryColors.violet
        ..strokeWidth = shortest * 0.11
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(size.width * 0.27, size.height * 0.27),
        Offset(size.width * 0.73, size.height * 0.73),
        paint,
      );
      canvas.drawLine(
        Offset(size.width * 0.73, size.height * 0.27),
        Offset(size.width * 0.27, size.height * 0.73),
        paint,
      );
      return;
    }

    final paint = Paint()
      ..color = PocketObservatoryColors.teal
      ..strokeWidth = shortest * 0.1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      shortest * 0.26,
      paint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.5),
        width: shortest * 0.76,
        height: shortest * 0.44,
      ),
      -0.42,
      2.24,
      false,
      paint..color = PocketObservatoryColors.teal.withValues(alpha: 0.48),
    );
  }

  @override
  bool shouldRepaint(covariant _MarkPainter oldDelegate) {
    return oldDelegate.mark != mark;
  }
}
