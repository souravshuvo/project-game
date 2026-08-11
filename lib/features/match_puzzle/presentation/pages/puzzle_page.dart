import 'package:flutter/material.dart';

import '../../application/puzzle_controller.dart';
import '../../domain/board_position.dart';
import '../../domain/puzzle_board.dart';
import '../../domain/puzzle_state.dart';
import '../../domain/tile_kind.dart';

class PuzzlePage extends StatelessWidget {
  const PuzzlePage({super.key, required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F4EE),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(controller: controller),
                      const SizedBox(height: 12),
                      _GoalHud(state: state),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Center(
                          child: _PuzzleBoardView(controller: controller),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MessageBar(
                        message: controller.message,
                        status: state.status,
                        canGoNext: controller.canGoNext,
                        onNext: controller.nextLevel,
                        onRestart: controller.restart,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Signal Workshop',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF1D2B2A),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Level ${controller.currentLevelNumber}/${controller.totalLevels}: ${state.level.name}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF66716E),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        _LevelMenu(controller: controller),
        const SizedBox(width: 8),
        _MetricPill(label: 'Moves', value: '${state.movesLeft}'),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: controller.restart,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Restart',
        ),
      ],
    );
  }
}

class _LevelMenu extends StatelessWidget {
  const _LevelMenu({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'Levels',
      icon: const Icon(Icons.grid_view_rounded),
      onSelected: controller.selectLevel,
      itemBuilder: (context) {
        return List.generate(controller.totalLevels, (index) {
          final level = controller.levels[index];
          final unlocked = controller.isLevelUnlocked(index);
          final complete = controller.isLevelComplete(level.id);
          final best = controller.bestMovesLeftForLevel(level.id);

          return PopupMenuItem<int>(
            value: index,
            enabled: unlocked,
            child: Row(
              children: [
                Icon(
                  complete
                      ? Icons.check_circle_rounded
                      : unlocked
                      ? Icons.radio_button_unchecked_rounded
                      : Icons.lock_rounded,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text('${index + 1}. ${level.name}')),
                if (best != null)
                  Text(
                    '+$best',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
              ],
            ),
          );
        });
      },
    );
  }
}

class _GoalHud extends StatelessWidget {
  const _GoalHud({required this.state});

  final PuzzleState state;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3DED4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Goals',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xFF66716E),
                fontWeight: FontWeight.w800,
              ),
            ),
            for (final entry in state.goalsRemaining.entries)
              _GoalChip(tile: entry.key, remaining: entry.value),
            _MetricPill(label: 'Score', value: '${state.score}'),
          ],
        ),
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({required this.tile, required this.remaining});

  final TileKind tile;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final colors = _tileColors(tile);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_tileIcon(tile), size: 18, color: colors.foreground),
            const SizedBox(width: 6),
            Text(
              '${tile.label}: $remaining',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF1D2B2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFFCFD8D4),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PuzzleBoardView extends StatelessWidget {
  const _PuzzleBoardView({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    final board = controller.state.board;
    final side = (MediaQuery.sizeOf(context).shortestSide - 36).clamp(
      280.0,
      520.0,
    );

    return SizedBox.square(
      dimension: side,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF2C3634),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF17211F), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 24,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: board.width,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: board.width * board.height,
            itemBuilder: (context, index) {
              final position = BoardPosition(
                index ~/ board.width,
                index % board.width,
              );
              return _PuzzleTile(
                board: board,
                position: position,
                isSelected: controller.selectedPosition == position,
                isInvalid: controller.lastInvalidPosition == position,
                onTap: () => controller.select(position),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PuzzleTile extends StatelessWidget {
  const _PuzzleTile({
    required this.board,
    required this.position,
    required this.isSelected,
    required this.isInvalid,
    required this.onTap,
  });

  final PuzzleBoard board;
  final BoardPosition position;
  final bool isSelected;
  final bool isInvalid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tile = board.tileAt(position);
    final colors = tile == null ? _emptyColors : _tileColors(tile);

    return Semantics(
      button: true,
      label: tile?.label ?? 'Empty',
      child: GestureDetector(
        onTap: tile == null ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(isInvalid ? 4 : 0, 0, 0),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFFFFFFFF) : colors.border,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.foreground.withValues(
                  alpha: isSelected ? 0.28 : 0.16,
                ),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: tile == null
                ? const SizedBox.shrink()
                : Icon(_tileIcon(tile), color: colors.foreground, size: 28),
          ),
        ),
      ),
    );
  }
}

class _MessageBar extends StatelessWidget {
  const _MessageBar({
    required this.message,
    required this.status,
    required this.canGoNext,
    required this.onNext,
    required this.onRestart,
  });

  final String message;
  final PuzzleStatus status;
  final bool canGoNext;
  final VoidCallback onNext;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final isFinished = status != PuzzleStatus.playing;
    final color = switch (status) {
      PuzzleStatus.won => const Color(0xFF1F7A4D),
      PuzzleStatus.lost => const Color(0xFFB64E3B),
      PuzzleStatus.playing => const Color(0xFF3E6B5A),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3DED4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isFinished ? Icons.flag_rounded : Icons.bolt_rounded,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF1D2B2A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (isFinished) _buildAction(status),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(PuzzleStatus status) {
    if (canGoNext) {
      return FilledButton.icon(
        onPressed: onNext,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: const Text('Next'),
      );
    }

    return TextButton.icon(
      onPressed: onRestart,
      icon: const Icon(Icons.refresh_rounded),
      label: Text(status == PuzzleStatus.won ? 'Replay' : 'Retry'),
    );
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

const _emptyColors = _TileColors(
  background: Color(0xFF46514E),
  foreground: Color(0xFF97A39F),
  border: Color(0xFF596662),
);

_TileColors _tileColors(TileKind tile) {
  return switch (tile) {
    TileKind.pulse => const _TileColors(
      background: Color(0xFFFFE4DF),
      foreground: Color(0xFFB64E3B),
      border: Color(0xFFFFB3A7),
    ),
    TileKind.coil => const _TileColors(
      background: Color(0xFFE4F0FF),
      foreground: Color(0xFF315FAD),
      border: Color(0xFFAFCBFA),
    ),
    TileKind.lens => const _TileColors(
      background: Color(0xFFFFF3CE),
      foreground: Color(0xFF9B6A00),
      border: Color(0xFFFFD675),
    ),
    TileKind.node => const _TileColors(
      background: Color(0xFFE5F6EC),
      foreground: Color(0xFF247A4D),
      border: Color(0xFFA7DDBD),
    ),
    TileKind.spark => const _TileColors(
      background: Color(0xFFF0E8FF),
      foreground: Color(0xFF7251A8),
      border: Color(0xFFC6B3EF),
    ),
  };
}

IconData _tileIcon(TileKind tile) {
  return switch (tile) {
    TileKind.pulse => Icons.graphic_eq_rounded,
    TileKind.coil => Icons.all_inclusive_rounded,
    TileKind.lens => Icons.adjust_rounded,
    TileKind.node => Icons.hub_rounded,
    TileKind.spark => Icons.auto_awesome_rounded,
  };
}
