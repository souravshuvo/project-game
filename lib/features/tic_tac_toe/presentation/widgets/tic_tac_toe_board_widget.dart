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
    final winningLine = controller.round.outcome.winningLine;
    final canReceiveTap =
        !controller.round.isOver &&
        !controller.isAiThinking &&
        controller.isHumanTurn;

    return SizedBox.square(
      dimension: boardSide,
      child: ObservatoryPanel(
        padding: const EdgeInsets.all(12),
        color: PocketObservatoryColors.panel,
        borderColor: PocketObservatoryColors.gold.withValues(alpha: 0.62),
        child: Stack(
          children: [
            GridView.builder(
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
                  canReceiveTap: canReceiveTap,
                  isLastMove: controller.lastMoveIndex == index,
                  isInvalid: controller.lastInvalidIndex == index,
                  invalidTapSequence: controller.invalidTapSequence,
                  isWinningCell: winningLine.contains(index),
                  onTap: () => controller.tapCell(index),
                );
              },
            ),
            if (winningLine.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(winningLine.join('-')),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    builder: (context, progress, _) {
                      return CustomPaint(
                        painter: _WinningLinePainter(
                          winningLine: winningLine,
                          progress: progress,
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
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
    required this.canReceiveTap,
    required this.isLastMove,
    required this.isInvalid,
    required this.invalidTapSequence,
    required this.isWinningCell,
    required this.onTap,
  });

  final int index;
  final TicTacToeMark? mark;
  final bool canTap;
  final bool canReceiveTap;
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
  var _isPressed = false;

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
    final hint = mark == null && widget.canTap
        ? 'Tap to place your mark.'
        : mark == null
        ? 'Wait for your turn.'
        : 'Cell already used.';

    return Semantics(
      label: label,
      hint: hint,
      button: widget.canTap,
      enabled: widget.canTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: widget.canReceiveTap ? (_) => _setPressed(true) : null,
        onTapCancel: widget.canReceiveTap ? () => _setPressed(false) : null,
        onTapUp: widget.canReceiveTap ? (_) => _setPressed(false) : null,
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
              scale: _scale,
              duration: const Duration(milliseconds: 140),
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

  double get _scale {
    if (_isPressed) {
      return 0.96;
    }
    if (widget.isLastMove) {
      return 1.04;
    }

    return 1;
  }

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }

    setState(() {
      _isPressed = value;
    });
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

class _WinningLinePainter extends CustomPainter {
  const _WinningLinePainter({
    required this.winningLine,
    required this.progress,
  });

  final List<int> winningLine;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (winningLine.length < 3) {
      return;
    }

    const gap = 8.0;
    final cellSide = (size.shortestSide - gap * 2) / 3;
    final start = _cellCenter(winningLine.first, cellSide, gap);
    final end = _cellCenter(winningLine.last, cellSide, gap);
    final vector = end - start;
    final distance = vector.distance;
    if (distance == 0) {
      return;
    }

    final unit = vector / distance;
    final extendedStart = start - unit * cellSide * 0.28;
    final extendedEnd = end + unit * cellSide * 0.28;
    final currentEnd = Offset.lerp(extendedStart, extendedEnd, progress)!;
    final shadowPaint = Paint()
      ..color = PocketObservatoryColors.ink.withValues(alpha: 0.18)
      ..strokeWidth = cellSide * 0.14
      ..strokeCap = StrokeCap.round;
    final linePaint = Paint()
      ..color = PocketObservatoryColors.gold
      ..strokeWidth = cellSide * 0.08
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(extendedStart, currentEnd, shadowPaint);
    canvas.drawLine(extendedStart, currentEnd, linePaint);
  }

  Offset _cellCenter(int index, double cellSide, double gap) {
    final row = index ~/ 3;
    final column = index % 3;

    return Offset(
      column * (cellSide + gap) + cellSide / 2,
      row * (cellSide + gap) + cellSide / 2,
    );
  }

  @override
  bool shouldRepaint(covariant _WinningLinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.winningLine != winningLine;
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
