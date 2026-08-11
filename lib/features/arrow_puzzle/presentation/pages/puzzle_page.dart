import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../main.dart';
import '../../application/puzzle_controller.dart';
import '../../domain/board_position.dart';
import '../../domain/puzzle_cell.dart';
import '../theme/arrow_puzzle_theme.dart';

class PuzzlePage extends StatelessWidget {
  const PuzzlePage({super.key, required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    final level = controller.currentLevel;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => _showPauseMenu(context),
          icon: const Icon(Icons.pause_rounded),
          tooltip: 'Pause',
        ),
        title: Text(
          'Level ${controller.currentLevelNumber}: ${level.name}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: controller.canUseHint ? controller.useHint : null,
            icon: Badge(
              label: Text('${controller.hintCount}'),
              child: const Icon(Icons.lightbulb_rounded),
            ),
            tooltip: 'Hint',
          ),
          IconButton(
            onPressed: controller.retryLevel,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Retry',
          ),
          IconButton(
            onPressed: () => _showPauseMenu(context),
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Menu',
          ),
        ],
      ),
      body: GameBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                ArrowPuzzleCard(
                  color: ArrowPuzzleColors.blueSoft,
                  borderColor: const Color(0xFFB7D4FF),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.route_rounded,
                        color: ArrowPuzzleColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          level.lesson,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: PuzzleBoardWidget(controller: controller),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _MoveStatus(
                    key: ValueKey(controller.moveCount),
                    controller: controller,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPauseMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) {
        return _PauseMenu(controller: controller);
      },
    );
  }
}

class _PauseMenu extends StatelessWidget {
  const _PauseMenu({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    void closeAndRun(VoidCallback action) {
      Navigator.of(context).pop();
      action();
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Paused',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: ArrowPuzzleColors.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Level ${controller.currentLevelNumber} - ${controller.currentLevel.name}',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ArrowPuzzleColors.mutedInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Continue'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PauseAction(
                      icon: Icons.refresh_rounded,
                      label: 'Restart',
                      onTap: () => closeAndRun(controller.retryLevel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PauseAction(
                      icon: Icons.grid_view_rounded,
                      label: 'Levels',
                      onTap: () => closeAndRun(controller.showLevelSelect),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PauseAction(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      onTap: () => closeAndRun(controller.backHome),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ArrowPuzzleCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _PauseToggle(
                      icon: Icons.volume_up_rounded,
                      title: 'Sound',
                      value: controller.soundEnabled,
                      onChanged: controller.toggleSound,
                    ),
                    const Divider(height: 1),
                    _PauseToggle(
                      icon: Icons.vibration_rounded,
                      title: 'Haptics',
                      value: controller.hapticsEnabled,
                      onChanged: controller.toggleHaptics,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PauseAction extends StatelessWidget {
  const _PauseAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: FittedBox(child: Text(label)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _PauseToggle extends StatelessWidget {
  const _PauseToggle({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _MoveStatus extends StatelessWidget {
  const _MoveStatus({super.key, required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    final bestMoves = controller.currentLevelBestMoves;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        _StatusChip(
          icon: Icons.touch_app_rounded,
          label: 'Moves',
          value: '${controller.moveCount}',
        ),
        _StatusChip(
          icon: Icons.military_tech_rounded,
          label: 'Best',
          value: bestMoves == null ? '-' : '$bestMoves',
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              '$label: $value',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class PuzzleBoardWidget extends StatelessWidget {
  const PuzzleBoardWidget({super.key, required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    final board = controller.board;

    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      scale: controller.hintedPosition == null ? 1 : 1.01,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width - 36;
          final availableHeight = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : MediaQuery.sizeOf(context).height - 220;
          final maxSide = math.min(availableWidth, availableHeight);
          final boardSide = maxSide.clamp(180.0, 520.0).toDouble();
          final denseBoard = math.max(board.rowCount, board.colCount) >= 7;
          final gridGap = denseBoard ? 5.0 : 8.0;
          final boardPadding = denseBoard ? 8.0 : 12.0;

          return SizedBox.square(
            dimension: boardSide,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ArrowPuzzleColors.line),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(boardPadding),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: board.colCount,
                    mainAxisSpacing: gridGap,
                    crossAxisSpacing: gridGap,
                  ),
                  itemCount: board.rowCount * board.colCount,
                  itemBuilder: (context, index) {
                    final row = index ~/ board.colCount;
                    final col = index % board.colCount;
                    final position = BoardPosition(row, col);
                    final cell = board.cellAt(position);

                    return ArrowTile(
                      cell: cell,
                      position: position,
                      isInvalid: controller.lastInvalidTap == position,
                      isHinted: controller.hintedPosition == position,
                      removedCell: controller.lastRemovedPosition == position
                          ? controller.lastRemovedCell
                          : null,
                      onTap: cell.isArrow
                          ? () => controller.tap(position)
                          : null,
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ArrowTile extends StatefulWidget {
  const ArrowTile({
    super.key,
    required this.cell,
    required this.position,
    required this.isInvalid,
    required this.isHinted,
    required this.removedCell,
    required this.onTap,
  });

  final PuzzleCell cell;
  final BoardPosition position;
  final bool isInvalid;
  final bool isHinted;
  final PuzzleCell? removedCell;
  final VoidCallback? onTap;

  @override
  State<ArrowTile> createState() => _ArrowTileState();
}

class _ArrowTileState extends State<ArrowTile> with TickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void didUpdateWidget(covariant ArrowTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isInvalid && oldWidget.isInvalid != widget.isInvalid) {
      _shakeController.forward(from: 0);
    }
    if (widget.removedCell != null &&
        oldWidget.removedCell != widget.removedCell) {
      _slideController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final removedCell = widget.removedCell;

    return Semantics(
      button: widget.cell.isArrow,
      label: widget.cell.isArrow ? '${widget.cell.name} arrow' : 'Empty space',
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_shakeController, _slideController]),
          builder: (context, child) {
            final shake = widget.isInvalid
                ? _shakeOffset(_shakeController.value)
                : Offset.zero;

            if (removedCell != null) {
              final end = exitAlignment(widget.position, removedCell);
              final progress = Curves.easeOutCubic.transform(
                _slideController.value,
              );
              return Transform.translate(
                offset:
                    shake +
                    Offset(end.x * 48 * progress, end.y * 48 * progress),
                child: Transform.scale(
                  scale: 1 + 0.08 * (1 - progress),
                  child: Opacity(
                    opacity: 1 - progress,
                    child: _TileFace(cell: removedCell),
                  ),
                ),
              );
            }

            return Transform.translate(offset: shake, child: child);
          },
          child: _TileFace(cell: widget.cell, isHinted: widget.isHinted),
        ),
      ),
    );
  }

  Offset _shakeOffset(double value) {
    final direction = value < 0.25 || (value > 0.5 && value < 0.75) ? 1 : -1;
    return Offset(direction * 8 * (1 - value), 0);
  }
}

class _TileFace extends StatelessWidget {
  const _TileFace({required this.cell, this.isHinted = false});

  final PuzzleCell cell;
  final bool isHinted;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(cell);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileSide = math.min(constraints.maxWidth, constraints.maxHeight);
        final radius = (tileSide * 0.18).clamp(8.0, 18.0).toDouble();
        final iconSize = (tileSide * 0.48).clamp(20.0, 34.0).toDouble();

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isHinted ? const Color(0xFFFFF9C7) : colors.background,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isHinted ? const Color(0xFFFFC531) : colors.border,
              width: isHinted ? 3 : 2,
            ),
            boxShadow: isHinted
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFC531).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: cell.isArrow
                ? Icon(
                    arrowIcon(cell),
                    color: colors.foreground,
                    size: iconSize,
                  )
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  _TileColors _colorsFor(PuzzleCell cell) {
    return switch (cell) {
      PuzzleCell.up => const _TileColors(
        background: Color(0xFFE4F4FF),
        foreground: Color(0xFF0877B9),
        border: Color(0xFF8BD3FF),
      ),
      PuzzleCell.down => const _TileColors(
        background: Color(0xFFEAF7E7),
        foreground: Color(0xFF268A3E),
        border: Color(0xFFA6D99C),
      ),
      PuzzleCell.left => const _TileColors(
        background: ArrowPuzzleColors.amberSoft,
        foreground: Color(0xFFC76F00),
        border: Color(0xFFFFCA78),
      ),
      PuzzleCell.right => const _TileColors(
        background: Color(0xFFF2E9FF),
        foreground: Color(0xFF7444CE),
        border: Color(0xFFC5A8FF),
      ),
      PuzzleCell.empty => const _TileColors(
        background: Color(0xFFF8FAFF),
        foreground: Color(0xFF8D98AA),
        border: Color(0xFFE1E7F5),
      ),
    };
  }
}

class _TileColors {
  const _TileColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}
