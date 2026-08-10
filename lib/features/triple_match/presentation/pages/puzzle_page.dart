import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../application/triple_match_controller.dart';
import '../../domain/level_state.dart';
import '../../domain/tile_instance.dart';
import '../../domain/tile_kind.dart';
import '../theme/triple_match_theme.dart';

class PuzzlePage extends StatelessWidget {
  const PuzzlePage({super.key, required this.controller});

  final TripleMatchController controller;

  @override
  Widget build(BuildContext context) {
    final level = controller.state.level;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Larder Labels'),
        actions: [
          IconButton(
            onPressed: controller.restart,
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Restart',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              _Hud(controller: controller),
              const SizedBox(height: 12),
              _MessageBar(
                message: controller.message,
                isWarning: controller.isTrayDanger,
              ),
              const SizedBox(height: 12),
              Expanded(child: _BoardView(controller: controller)),
              const SizedBox(height: 14),
              _TrayView(controller: controller),
              const SizedBox(height: 12),
              _ResultPanel(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.controller});

  final TripleMatchController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.view_module_rounded,
            label: 'Level',
            value: '${controller.currentLevelNumber}/${controller.totalLevels}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.touch_app_rounded,
            label: 'Moves',
            value: '${controller.moves}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.stars_rounded,
            label: 'Score',
            value: '${controller.score}',
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
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
        border: Border.all(color: TripleMatchColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: TripleMatchColors.primary),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: TripleMatchColors.mutedInk,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBar extends StatelessWidget {
  const _MessageBar({required this.message, required this.isWarning});

  final String message;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isWarning ? TripleMatchColors.softAmber : TripleMatchColors.softBlue,
        border: Border.all(
          color: isWarning ? const Color(0xFFE3B842) : const Color(0xFFC8DBEF),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: TripleMatchColors.blue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardView extends StatelessWidget {
  const _BoardView({required this.controller});

  final TripleMatchController controller;

  @override
  Widget build(BuildContext context) {
    final level = controller.state.level;
    final tiles = controller.boardTiles.toList()
      ..sort((a, b) {
        final layerCompare = a.layer.compareTo(b.layer);
        if (layerCompare != 0) {
          return layerCompare;
        }
        final rowCompare = a.row.compareTo(b.row);
        return rowCompare != 0 ? rowCompare : a.col.compareTo(b.col);
      });

    return Center(
      child: AspectRatio(
        aspectRatio: level.width / level.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: TripleMatchColors.line, width: 1.4),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cellWidth = constraints.maxWidth / level.width;
                final cellHeight = constraints.maxHeight / level.height;
                final tileSide = math.min(cellWidth, cellHeight) * 0.82;

                return Stack(
                  children: [
                    CustomPaint(
                      size: Size.infinite,
                      painter: _BoardGridPainter(
                        columns: level.width,
                        rows: level.height,
                      ),
                    ),
                    for (final tile in tiles)
                      _PositionedBoardTile(
                        tile: tile,
                        tileSide: tileSide,
                        cellWidth: cellWidth,
                        cellHeight: cellHeight,
                        isSelectable: controller.isSelectable(tile.id),
                        onTap: () => controller.selectTile(tile.id),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PositionedBoardTile extends StatelessWidget {
  const _PositionedBoardTile({
    required this.tile,
    required this.tileSide,
    required this.cellWidth,
    required this.cellHeight,
    required this.isSelectable,
    required this.onTap,
  });

  final TileInstance tile;
  final double tileSide;
  final double cellWidth;
  final double cellHeight;
  final bool isSelectable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final layerLift = tile.layer * 5.0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      left: tile.col * cellWidth + (cellWidth - tileSide) / 2 + layerLift,
      top: tile.row * cellHeight + (cellHeight - tileSide) / 2 - layerLift,
      width: tileSide,
      height: tileSide,
      child: AnimatedOpacity(
        opacity: isSelectable ? 1 : 0.42,
        duration: const Duration(milliseconds: 150),
        child: _TileFace(tile: tile, isSelectable: isSelectable, onTap: onTap),
      ),
    );
  }
}

class _TileFace extends StatelessWidget {
  const _TileFace({
    super.key,
    required this.tile,
    required this.isSelectable,
    required this.onTap,
    this.compact = false,
  });

  final TileInstance tile;
  final bool isSelectable;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(tile.kind);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelectable ? colors.border : TripleMatchColors.line,
              width: isSelectable ? 2 : 1.4,
            ),
            boxShadow: compact
                ? null
                : [
                    BoxShadow(
                      color: colors.border.withValues(alpha: 0.28),
                      blurRadius: isSelectable ? 10 : 4,
                      offset: Offset(0, isSelectable ? 5 : 2),
                    ),
                  ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tile.kind.shortLabel,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colors.foreground,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        if (!compact)
                          Text(
                            tile.kind.displayName,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colors.foreground.withValues(alpha: 0.74),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isSelectable && !compact)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.58),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.layers_rounded,
                      color: TripleMatchColors.mutedInk,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrayView extends StatelessWidget {
  const _TrayView({required this.controller});

  final TripleMatchController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Tray ${controller.trayTileIds.length}/${controller.trayCapacity}',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            if (controller.isTrayDanger)
              Text(
                'Careful',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: TripleMatchColors.coral,
                  fontWeight: FontWeight.w900,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var index = 0; index < controller.trayCapacity; index++) ...[
              Expanded(child: _TraySlot(controller: controller, index: index)),
              if (index != controller.trayCapacity - 1)
                const SizedBox(width: 6),
            ],
          ],
        ),
      ],
    );
  }
}

class _TraySlot extends StatelessWidget {
  const _TraySlot({required this.controller, required this.index});

  final TripleMatchController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    final hasTile = index < controller.trayTileIds.length;
    final isDanger = controller.isTrayDanger && !hasTile;

    return AspectRatio(
      aspectRatio: 1,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        child: hasTile
            ? _TileFace(
                key: ValueKey(controller.trayTileIds[index]),
                tile: controller.tileById(controller.trayTileIds[index]),
                isSelectable: true,
                compact: true,
                onTap: () {},
              )
            : DecoratedBox(
                key: ValueKey('empty-$index'),
                decoration: BoxDecoration(
                  color: isDanger ? TripleMatchColors.softCoral : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDanger
                        ? const Color(0xFFFFB5AD)
                        : TripleMatchColors.line,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: TripleMatchColors.line,
                  ),
                ),
              ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.controller});

  final TripleMatchController controller;

  @override
  Widget build(BuildContext context) {
    final status = controller.status;
    if (status == LevelStatus.playing) {
      return const SizedBox(height: 48);
    }

    final won = status == LevelStatus.won;
    final actionLabel = won && !controller.isLastLevel ? 'Next' : 'Restart';
    final actionIcon = won && !controller.isLastLevel
        ? Icons.arrow_forward_rounded
        : Icons.restart_alt_rounded;
    final action = won && !controller.isLastLevel
        ? controller.nextLevel
        : controller.restart;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: won ? TripleMatchColors.softGreen : TripleMatchColors.softCoral,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: won ? const Color(0xFF9BD5B3) : const Color(0xFFFFB5AD),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(
              won ? Icons.check_circle_rounded : Icons.error_rounded,
              color: won ? TripleMatchColors.primary : TripleMatchColors.coral,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                won
                    ? controller.isLastLevel
                          ? 'All shelves cleared in ${controller.moves} moves.'
                          : 'Cleared in ${controller.moves} moves.'
                    : 'Tray full. Try a different order.',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            FilledButton.icon(
              onPressed: action,
              icon: Icon(actionIcon),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardGridPainter extends CustomPainter {
  const _BoardGridPainter({required this.columns, required this.rows});

  final int columns;
  final int rows;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TripleMatchColors.line.withValues(alpha: 0.72)
      ..strokeWidth = 1;

    for (var col = 1; col < columns; col++) {
      final x = size.width * col / columns;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var row = 1; row < rows; row++) {
      final y = size.height * row / rows;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BoardGridPainter oldDelegate) {
    return oldDelegate.columns != columns || oldDelegate.rows != rows;
  }
}

_TileColors _colorsFor(TileKind kind) {
  return switch (kind) {
    TileKind.jarLabel => const _TileColors(
      background: Color(0xFFE9F6EE),
      foreground: Color(0xFF276B43),
      border: Color(0xFF8ACAA4),
    ),
    TileKind.foldedNote => const _TileColors(
      background: Color(0xFFEAF1FF),
      foreground: Color(0xFF345AA6),
      border: Color(0xFF9BB8F1),
    ),
    TileKind.berryTin => const _TileColors(
      background: Color(0xFFFFE9E5),
      foreground: Color(0xFFB54138),
      border: Color(0xFFFFA59B),
    ),
    TileKind.flourTag => const _TileColors(
      background: Color(0xFFFFF5D8),
      foreground: Color(0xFF926C00),
      border: Color(0xFFF0C24D),
    ),
    TileKind.teaPacket => const _TileColors(
      background: Color(0xFFE2F7F2),
      foreground: Color(0xFF176B62),
      border: Color(0xFF77CDBE),
    ),
    TileKind.seedCard => const _TileColors(
      background: Color(0xFFF2EEFF),
      foreground: Color(0xFF6848A8),
      border: Color(0xFFC0AFE8),
    ),
    TileKind.honeyMark => const _TileColors(
      background: Color(0xFFFFEFD6),
      foreground: Color(0xFFB15E00),
      border: Color(0xFFFFB55D),
    ),
    TileKind.ribbonTab => const _TileColors(
      background: Color(0xFFE9F3F7),
      foreground: Color(0xFF2B6D88),
      border: Color(0xFF93C9DD),
    ),
    TileKind.oatStamp => const _TileColors(
      background: Color(0xFFF3F1E6),
      foreground: Color(0xFF6C6642),
      border: Color(0xFFD4C981),
    ),
    TileKind.cocoaSeal => const _TileColors(
      background: Color(0xFFF4E6DF),
      foreground: Color(0xFF7A4531),
      border: Color(0xFFD6A08E),
    ),
  };
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
