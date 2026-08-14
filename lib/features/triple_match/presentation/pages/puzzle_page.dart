import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../application/triple_match_controller.dart';
import '../../domain/level_state.dart';
import '../../domain/tile_instance.dart';
import '../../domain/tile_kind.dart';
import '../../../../shared/ads/ad_mob_service.dart';
import '../feedback/triple_match_feedback.dart';
import '../theme/triple_match_theme.dart';
import '../widgets/pantry_helper.dart';

class PuzzlePage extends StatelessWidget {
  const PuzzlePage({
    super.key,
    required this.controller,
    required this.adMobService,
    required this.onHomePressed,
    required this.onHelpPressed,
    required this.onSettingsPressed,
  });

  final TripleMatchController controller;
  final AdMobService adMobService;
  final VoidCallback onHomePressed;
  final VoidCallback onHelpPressed;
  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: onHomePressed,
          icon: const Icon(Icons.home_rounded),
          tooltip: 'Home',
        ),
        title: const Text('Larder Labels'),
        actions: [
          IconButton(
            onPressed: onHelpPressed,
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Help',
          ),
          IconButton(
            onPressed: onSettingsPressed,
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
          ),
          IconButton(
            onPressed: () => _showPauseSheet(context),
            icon: const Icon(Icons.pause_circle_rounded),
            tooltip: 'Pause',
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TripleMatchColors.canvas,
              TripleMatchColors.softGreen,
              TripleMatchColors.canvas,
            ],
          ),
        ),
        child: SafeArea(
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
                _ResultPanel(
                  controller: controller,
                  adMobService: adMobService,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPauseSheet(BuildContext context) {
    TripleMatchFeedback.play(controller, TripleMatchFeedbackCue.tap);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Paused',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    TripleMatchFeedback.play(
                      controller,
                      TripleMatchFeedbackCue.tap,
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Continue'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    final cue = controller.restart();
                    TripleMatchFeedback.play(controller, cue);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Restart'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onSettingsPressed();
                  },
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text('Settings'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onHelpPressed();
                  },
                  icon: const Icon(Icons.help_outline_rounded),
                  label: const Text('Help'),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onHomePressed();
                  },
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Home'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.controller});

  final TripleMatchController controller;

  @override
  Widget build(BuildContext context) {
    final level = controller.state.level;
    final remaining = controller.boardTiles.length;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border.all(
          color: TripleMatchColors.primary.withValues(alpha: 0.18),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: TripleMatchColors.primaryDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    child: Text(
                      'Level ${controller.currentLevelNumber}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    level.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: TripleMatchColors.primaryDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    '$remaining left',
                    key: ValueKey(remaining),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: TripleMatchColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 380;
                final cards = [
                  _MetricCard(
                    icon: Icons.view_module_rounded,
                    label: 'Shelves',
                    value:
                        '${controller.completedLevelCount}/${controller.totalLevels}',
                  ),
                  _MetricCard(
                    icon: Icons.touch_app_rounded,
                    label: 'Moves',
                    value: '${controller.moves}',
                  ),
                  _MetricCard(
                    icon: Icons.stars_rounded,
                    label: 'Score',
                    value: '${controller.score}',
                  ),
                ];

                if (compact) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final card in cards)
                        SizedBox(
                          width: (constraints.maxWidth - 8) / 2,
                          child: card,
                        ),
                    ],
                  );
                }

                return Row(
                  children: [
                    for (var index = 0; index < cards.length; index++) ...[
                      Expanded(child: cards[index]),
                      if (index != cards.length - 1) const SizedBox(width: 10),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
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
        color: isWarning
            ? TripleMatchColors.softAmber
            : TripleMatchColors.softBlue,
        border: Border.all(
          color: isWarning ? const Color(0xFFE3B842) : const Color(0xFFC8DBEF),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              isWarning
                  ? Icons.warning_amber_rounded
                  : Icons.info_outline_rounded,
              size: 18,
              color: isWarning
                  ? TripleMatchColors.coral
                  : TripleMatchColors.blue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: Text(
                  message,
                  key: ValueKey(message),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
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
            color: const Color(0xFFFFFCF6),
            border: Border.all(
              color: TripleMatchColors.primary.withValues(alpha: 0.28),
              width: 1.6,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: TripleMatchColors.primaryDark.withValues(alpha: 0.14),
                blurRadius: 24,
                offset: const Offset(0, 14),
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
                final hitSide = math.max(
                  tileSide,
                  math.min(cellWidth, cellHeight) * 0.94,
                );

                return Stack(
                  children: [
                    CustomPaint(
                      size: Size.infinite,
                      painter: _ShelfBoardPainter(rows: level.height),
                    ),
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
                        hitSide: hitSide,
                        cellWidth: cellWidth,
                        cellHeight: cellHeight,
                        isSelectable: controller.isSelectable(tile.id),
                        onTap: () {
                          final cue = controller.selectTile(tile.id);
                          TripleMatchFeedback.play(controller, cue);
                        },
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
    required this.hitSide,
    required this.cellWidth,
    required this.cellHeight,
    required this.isSelectable,
    required this.onTap,
  });

  final TileInstance tile;
  final double tileSide;
  final double hitSide;
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
      left: tile.col * cellWidth + (cellWidth - hitSide) / 2 + layerLift,
      top: tile.row * cellHeight + (cellHeight - hitSide) / 2 - layerLift,
      width: hitSide,
      height: hitSide,
      child: Center(
        child: SizedBox.square(
          dimension: tileSide,
          child: AnimatedOpacity(
            opacity: isSelectable ? 1 : 0.42,
            duration: const Duration(milliseconds: 150),
            child: _TileFace(
              tile: tile,
              isSelectable: isSelectable,
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}

class _TileFace extends StatefulWidget {
  const _TileFace({
    super.key,
    required this.tile,
    required this.isSelectable,
    required this.onTap,
    this.compact = false,
  });

  final TileInstance tile;
  final bool isSelectable;
  final VoidCallback? onTap;
  final bool compact;

  @override
  State<_TileFace> createState() => _TileFaceState();
}

class _TileFaceState extends State<_TileFace> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || widget.onTap == null) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(widget.tile.kind);
    final isInteractive = widget.onTap != null;
    final baseScale = widget.isSelectable ? 1.0 : 0.96;
    final pressScale = _pressed ? 0.94 : 1.0;

    return Semantics(
      button: isInteractive,
      enabled: isInteractive && widget.isSelectable,
      label: !isInteractive
          ? '${widget.tile.kind.displayName} label in tray'
          : widget.isSelectable
          ? '${widget.tile.kind.displayName} label'
          : '${widget.tile.kind.displayName} label covered',
      child: AnimatedScale(
        scale: baseScale * pressScale,
        duration: Duration(milliseconds: _pressed ? 70 : 150),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: isInteractive ? (_) => _setPressed(true) : null,
            onTapCancel: isInteractive ? () => _setPressed(false) : null,
            onTapUp: isInteractive ? (_) => _setPressed(false) : null,
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isSelectable
                      ? colors.border
                      : TripleMatchColors.line,
                  width: widget.isSelectable ? 2.4 : 1.4,
                ),
                boxShadow: widget.compact
                    ? null
                    : [
                        BoxShadow(
                          color: colors.border.withValues(
                            alpha: widget.isSelectable ? 0.34 : 0.12,
                          ),
                          blurRadius: widget.isSelectable ? 12 : 4,
                          offset: Offset(0, widget.isSelectable ? 7 : 2),
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
                              widget.tile.kind.shortLabel,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: colors.foreground,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0,
                                  ),
                            ),
                            if (!widget.compact)
                              Text(
                                widget.tile.kind.displayName,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colors.foreground.withValues(
                                        alpha: 0.74,
                                      ),
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 7,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.foreground.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const SizedBox(height: 3),
                    ),
                  ),
                  if (!widget.isSelectable && !widget.compact)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.62),
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
    final danger = controller.isTrayDanger;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: danger ? TripleMatchColors.softCoral : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: danger
              ? TripleMatchColors.coral.withValues(alpha: 0.45)
              : TripleMatchColors.primary.withValues(alpha: 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (danger
                        ? TripleMatchColors.coral
                        : TripleMatchColors.primaryDark)
                    .withValues(alpha: danger ? 0.15 : 0.08),
            blurRadius: danger ? 18 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2_rounded,
                  size: 18,
                  color: danger
                      ? TripleMatchColors.coral
                      : TripleMatchColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tray ${controller.trayTileIds.length}/${controller.trayCapacity}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: danger
                      ? Text(
                          'Careful',
                          key: const ValueKey('danger'),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: TripleMatchColors.coral,
                                fontWeight: FontWeight.w900,
                              ),
                        )
                      : Text(
                          'Match three',
                          key: const ValueKey('calm'),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: TripleMatchColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (
                  var index = 0;
                  index < controller.trayCapacity;
                  index++
                ) ...[
                  Expanded(
                    child: _TraySlot(controller: controller, index: index),
                  ),
                  if (index != controller.trayCapacity - 1)
                    const SizedBox(width: 6),
                ],
              ],
            ),
          ],
        ),
      ),
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
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: hasTile
            ? _TileFace(
                key: ValueKey(controller.trayTileIds[index]),
                tile: controller.tileById(controller.trayTileIds[index]),
                isSelectable: true,
                compact: true,
                onTap: null,
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
                    Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: TripleMatchColors.line,
                  ),
                ),
              ),
      ),
    );
  }
}

class _ResultPanel extends StatefulWidget {
  const _ResultPanel({required this.controller, required this.adMobService});

  final TripleMatchController controller;
  final AdMobService adMobService;

  @override
  State<_ResultPanel> createState() => _ResultPanelState();
}

class _ResultPanelState extends State<_ResultPanel> {
  bool _isTransitioning = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final status = controller.status;
    if (status == LevelStatus.playing) {
      return const SizedBox(height: 48);
    }

    final won = status == LevelStatus.won;
    final actionLabel = won && !controller.isLastLevel ? 'Next' : 'Restart';
    final actionIcon = won && !controller.isLastLevel
        ? Icons.arrow_forward_rounded
        : Icons.restart_alt_rounded;
    final action = () => _runResultAction(won: won);
    final resultMessage = won
        ? controller.isLastLevel
              ? 'All shelves cleared in ${controller.moves} moves.'
              : 'Cleared in ${controller.moves} moves.'
        : 'Tray full. Try a different order.';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: won
                ? const [TripleMatchColors.surface, TripleMatchColors.softGreen]
                : const [
                    TripleMatchColors.surface,
                    TripleMatchColors.softCoral,
                  ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: won ? const Color(0xFF9BD5B3) : const Color(0xFFFFB5AD),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (won ? TripleMatchColors.primary : TripleMatchColors.coral)
                  .withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final messageRow = Row(
                children: [
                  PantryHelper(
                    size: 48,
                    mood: won
                        ? PantryHelperMood.happy
                        : PantryHelperMood.worried,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          won ? 'Shelf cleared' : 'Tray filled',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: won
                                    ? TripleMatchColors.primaryDark
                                    : TripleMatchColors.coral,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        Text(
                          resultMessage,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final actionButton = FilledButton.icon(
                onPressed: _isTransitioning ? null : action,
                icon: Icon(actionIcon),
                label: Text(_isTransitioning ? 'Loading' : actionLabel),
              );

              if (constraints.maxWidth < 360) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    messageRow,
                    const SizedBox(height: 10),
                    actionButton,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: messageRow),
                  const SizedBox(width: 10),
                  actionButton,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _runResultAction({required bool won}) async {
    if (_isTransitioning) {
      return;
    }

    setState(() => _isTransitioning = true);
    final controller = widget.controller;
    final levelNumber = controller.currentLevelNumber;

    await widget.adMobService.showLevelEndInterstitialIfAllowed(
      levelNumber: levelNumber,
      completed: won,
      onContinue: () {
        final cue = won && !controller.isLastLevel
            ? controller.nextLevel()
            : controller.restart();
        TripleMatchFeedback.play(controller, cue);
      },
    );

    if (mounted) {
      setState(() => _isTransitioning = false);
    }
  }
}

class _ShelfBoardPainter extends CustomPainter {
  const _ShelfBoardPainter({required this.rows});

  final int rows;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFFFFFCF6);
    canvas.drawRect(Offset.zero & size, background);

    final shelfPaint = Paint()
      ..color = TripleMatchColors.amber.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final lipPaint = Paint()
      ..color = TripleMatchColors.primary.withValues(alpha: 0.14)
      ..strokeWidth = 2;

    for (var row = 0; row < rows; row++) {
      final y = size.height * (row + 1) / rows;
      final shelfRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(12, y - 9, size.width - 24, 8),
        const Radius.circular(8),
      );
      canvas.drawRRect(shelfRect, shelfPaint);
      canvas.drawLine(
        Offset(12, y - 1),
        Offset(size.width - 12, y - 1),
        lipPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShelfBoardPainter oldDelegate) {
    return oldDelegate.rows != rows;
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
