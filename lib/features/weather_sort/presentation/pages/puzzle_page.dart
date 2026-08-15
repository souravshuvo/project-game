import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../application/water_sort_controller.dart';
import '../../domain/water_board.dart';
import '../../domain/weather_essence.dart';
import '../theme/weather_sort_theme.dart';
import '../widgets/essence_legend.dart';
import '../widgets/tube_widget.dart';
import '../widgets/weather_essence_view.dart';

class WaterPuzzlePage extends StatefulWidget {
  const WaterPuzzlePage({super.key, required this.controller});

  final WaterSortController controller;

  @override
  State<WaterPuzzlePage> createState() => _WaterPuzzlePageState();
}

class _WaterPuzzlePageState extends State<WaterPuzzlePage>
    with SingleTickerProviderStateMixin {
  static const _pourDuration = Duration(milliseconds: 520);

  late final AnimationController _pourController;
  bool _isPourAnimating = false;
  OverlayEntry? _toastEntry;
  Timer? _toastTimer;

  WaterSortController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _pourController = AnimationController(vsync: this, duration: _pourDuration);
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _toastEntry?.remove();
    _pourController.dispose();
    super.dispose();
  }

  void _handleTubeTap(int tubeIndex) {
    if (_isPourAnimating || controller.isCompletionPending) {
      return;
    }

    final moveFeedbackBeforeTap = controller.moveFeedbackToken;
    final actionFeedbackBeforeTap = controller.actionFeedbackToken;
    controller.tapTube(tubeIndex);

    if (controller.actionFeedbackToken != actionFeedbackBeforeTap) {
      _showInteractionToast();
    }

    if (controller.moveFeedbackToken == moveFeedbackBeforeTap) {
      return;
    }

    setState(() {
      _isPourAnimating = true;
    });
    _pourController.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      controller.finishPourAnimation();
      setState(() {
        _isPourAnimating = false;
      });
      if (controller.isCompletionPending) {
        Future<void>.delayed(const Duration(milliseconds: 280), () {
          if (!mounted) return;
          controller.finishCompletionAnimation();
        });
      }
    });
  }

  void _showInteractionToast() {
    final feedback = controller.lastActionFeedback;
    final message = switch (feedback) {
      WaterActionFeedback.sourceSelected =>
        'Choose a destination. It will pour only if it fits.',
      WaterActionFeedback.invalid => invalidMoveMessage(
        controller.lastInvalidReason,
      ),
      _ => '',
    };
    if (message.isEmpty || !mounted) {
      return;
    }

    _toastTimer?.cancel();
    _toastEntry?.remove();
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    final isError = feedback == WaterActionFeedback.invalid;
    final entry = OverlayEntry(
      builder: (context) => _GameplayToast(message: message, isError: isError),
    );
    _toastEntry = entry;
    overlay.insert(entry);
    _toastTimer = Timer(const Duration(milliseconds: 1300), () {
      if (_toastEntry == entry) {
        entry.remove();
        _toastEntry = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final level = controller.currentLevel;
    final activeEssences = <WeatherEssence>{
      for (final tube in controller.board.tubes) ...tube.layers,
    };
    final isInputLocked = _isPourAnimating || controller.isCompletionPending;
    final guidance = _guidanceFor(controller);
    final compactHeight = MediaQuery.sizeOf(context).height < 720;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: isInputLocked ? null : controller.backHome,
          icon: const Icon(Icons.home_rounded),
          tooltip: 'Home',
        ),
        title: Text('Level ${controller.currentLevelNumber}'),
        actions: [
          IconButton(
            onPressed: () => _showHowToPlay(context),
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'How to play',
          ),
          IconButton(
            onPressed: isInputLocked
                ? null
                : () => _showPauseMenu(context, controller),
            icon: const Icon(Icons.pause_rounded),
            tooltip: 'Pause',
          ),
        ],
      ),
      body: WeatherBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WeatherPanel(
                  color: WeatherSortColors.wash,
                  borderColor: const Color(0xFFC9DAE8),
                  child: Column(
                    children: [
                      Text(
                        level.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: WeatherSortColors.primaryDark,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        level.lesson,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: WeatherSortColors.mutedInk,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
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
                      icon: Icons.flag_rounded,
                      label: 'Par',
                      value: '${level.parMoves}',
                    ),
                    _StatusChip(
                      icon: Icons.star_rounded,
                      label: 'Pace',
                      value: '${controller.starsForCurrentAttempt}/3',
                    ),
                    _StatusChip(
                      icon: Icons.bolt_rounded,
                      label: 'Flow',
                      value: '${controller.flowStreak}',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _MoveGuidanceBanner(
                    key: ValueKey(guidance.message),
                    guidance: guidance,
                  ),
                ),
                const SizedBox(height: 10),
                _AttemptPaceBar(controller: controller),
                const SizedBox(height: 12),
                Flexible(
                  fit: FlexFit.loose,
                  child: _TubeGrid(
                    controller: controller,
                    board: controller.board,
                    isPourAnimating: _isPourAnimating,
                    pourAnimation: _pourController,
                    onTubeTap: _handleTubeTap,
                  ),
                ),
                if (!compactHeight) ...[
                  const SizedBox(height: 10),
                  EssenceLegend(
                    essences: WeatherEssence.values
                        .where(activeEssences.contains)
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                ] else
                  const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.canUndo && !isInputLocked
                            ? controller.undo
                            : null,
                        icon: const Icon(Icons.undo_rounded),
                        label: const Text('Undo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isInputLocked
                            ? null
                            : controller.restartLevel,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Restart'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TubeGrid extends StatelessWidget {
  const _TubeGrid({
    required this.controller,
    required this.board,
    required this.isPourAnimating,
    required this.pourAnimation,
    required this.onTubeTap,
  });

  final WaterSortController controller;
  final WaterBoard board;
  final bool isPourAnimating;
  final Animation<double> pourAnimation;
  final ValueChanged<int> onTubeTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = board.tubeCount <= 4
            ? board.tubeCount
            : constraints.maxWidth < 430
            ? 3
            : 5;
        final lastMove = isPourAnimating ? controller.lastValidMove : null;
        final validTargets = controller.validTargetIndexes;
        const spacing = 12.0;
        const verticalPadding = 12.0;
        const childAspectRatio = 0.48;
        final rows = (board.tubeCount / crossAxisCount).ceil();
        final tubeWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * spacing) /
            crossAxisCount;
        final tubeHeight = tubeWidth / childAspectRatio;
        final naturalHeight =
            rows * tubeHeight + (rows - 1) * spacing + verticalPadding;
        final gridHeight = math
            .min(constraints.maxHeight, math.max(0, naturalHeight))
            .toDouble();
        final isScrollable = naturalHeight > constraints.maxHeight;

        return SizedBox(
          height: gridHeight,
          child: Stack(
            children: [
              GridView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                primary: false,
                physics: isScrollable
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: board.tubeCount,
                itemBuilder: (context, index) {
                  return TubeWidget(
                    tube: board.tubeAt(index),
                    index: index,
                    isSelected: controller.selectedTubeIndex == index,
                    isValidTarget:
                        !isPourAnimating && validTargets.contains(index),
                    isInvalid:
                        !isPourAnimating &&
                        controller.invalidTubeIndex == index,
                    isRecentSource: lastMove?.sourceIndex == index,
                    isRecentDestination: lastMove?.destinationIndex == index,
                    feedbackToken: controller.feedbackToken,
                    moveFeedbackToken: controller.moveFeedbackToken,
                    isPourAnimating: isPourAnimating,
                    pourAnimation:
                        lastMove?.sourceIndex == index ||
                            lastMove?.destinationIndex == index
                        ? pourAnimation
                        : null,
                    pourDirection: lastMove == null
                        ? 0
                        : lastMove.destinationIndex.compareTo(
                            lastMove.sourceIndex,
                          ),
                    onTap: () => onTubeTap(index),
                    transferringEssence: lastMove?.destinationIndex == index
                        ? controller.pendingPourEssence
                        : null,
                    transferringLayerCount: lastMove?.destinationIndex == index
                        ? controller.pendingPourLayerCount
                        : 0,
                    drainingLayerCount: lastMove?.sourceIndex == index
                        ? controller.pendingPourLayerCount
                        : 0,
                  );
                },
              ),
              if (lastMove != null)
                Positioned.fill(
                  child: _PourStream(
                    key: ValueKey(controller.moveFeedbackToken),
                    sourcePoint: _tubePourPoint(
                      index: lastMove.sourceIndex,
                      crossAxisCount: crossAxisCount,
                      tubeWidth: tubeWidth,
                      tubeHeight: tubeHeight,
                    ),
                    destinationPoint: _tubePourPoint(
                      index: lastMove.destinationIndex,
                      crossAxisCount: crossAxisCount,
                      tubeWidth: tubeWidth,
                      tubeHeight: tubeHeight,
                    ),
                    color: board.tubeAt(lastMove.sourceIndex).top?.color,
                    animation: pourAnimation,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Offset _tubePourPoint({
    required int index,
    required int crossAxisCount,
    required double tubeWidth,
    required double tubeHeight,
  }) {
    const spacing = 12.0;
    final row = index ~/ crossAxisCount;
    final column = index % crossAxisCount;
    return Offset(
      column * (tubeWidth + spacing) + tubeWidth / 2,
      6 + row * (tubeHeight + spacing) + tubeHeight * 0.18,
    );
  }
}

class _PourStream extends StatelessWidget {
  const _PourStream({
    super.key,
    required this.sourcePoint,
    required this.destinationPoint,
    required this.color,
    required this.animation,
  });

  final Offset sourcePoint;
  final Offset destinationPoint;
  final Color? color;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final progress = animation.value;
            final easedProgress = Curves.easeInOutCubicEmphasized.transform(
              progress,
            );
            final point = _streamPoint(easedProgress);
            final streamColor = color ?? WeatherSortColors.primary;
            final fade = progress > 0.72 ? (1 - progress) / 0.28 : 1.0;

            return Stack(
              children: [
                Positioned(
                  left: point.dx - 14,
                  top: point.dy - 14,
                  child: Opacity(
                    opacity: fade.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.72 + math.sin(progress * math.pi) * 0.18,
                      child: Icon(
                        Icons.water_drop_rounded,
                        color: streamColor,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Offset _streamPoint(double t) {
    final linear = Offset.lerp(sourcePoint, destinationPoint, t)!;
    final distance = (destinationPoint - sourcePoint).distance;
    final arcHeight = math.min(40.0, distance * 0.08);
    return Offset(linear.dx, linear.dy - math.sin(t * math.pi) * arcHeight);
  }
}

class _GameplayToast extends StatelessWidget {
  const _GameplayToast({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? WeatherSortColors.coral : WeatherSortColors.primary;
    return Positioned(
      top: MediaQuery.paddingOf(context).top + kToolbarHeight + 10,
      left: 24,
      right: 24,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isError
                        ? Icons.error_outline_rounded
                        : Icons.near_me_rounded,
                    color: color,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
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

_MoveGuidance _guidanceFor(WaterSortController controller) {
  final invalidReason = controller.lastInvalidReason;
  if (invalidReason != null) {
    return _MoveGuidance(
      message: invalidMoveMessage(invalidReason),
      icon: Icons.error_outline_rounded,
      color: WeatherSortColors.coral,
    );
  }

  if (controller.selectedTubeIndex != null) {
    final targetCount = controller.validTargetIndexes.length;
    final message = targetCount == 0
        ? 'No landing is open for this vessel. Choose another source.'
        : '$targetCount highlighted landing${targetCount == 1 ? '' : 's'} can receive this pour.';
    return _MoveGuidance(
      message: message,
      icon: Icons.near_me_rounded,
      color: WeatherSortColors.mint,
    );
  }

  if (controller.flowStreak >= 3) {
    return _MoveGuidance(
      message:
          'Flow streak ${controller.flowStreak}. Keep chaining clean pours.',
      icon: Icons.bolt_rounded,
      color: WeatherSortColors.sun,
    );
  }

  if (controller.moveCount > 0 && controller.isOnThreeStarPace) {
    final remaining = controller.movesLeftForThreeStars;
    return _MoveGuidance(
      message: remaining == 0
          ? 'Last par move. Finish now to keep 3 stars.'
          : '$remaining par move${remaining == 1 ? '' : 's'} left for 3 stars.',
      icon: Icons.star_rounded,
      color: WeatherSortColors.sun,
    );
  }

  if (controller.moveCount > controller.currentLevel.parMoves) {
    return const _MoveGuidance(
      message: 'Par missed. Finish the puzzle, then replay a tighter route.',
      icon: Icons.replay_rounded,
      color: WeatherSortColors.coral,
    );
  }

  if (controller.moveCount == 0) {
    return const _MoveGuidance(
      message: 'Tap a vessel with weather, then tap a highlighted landing.',
      icon: Icons.touch_app_rounded,
      color: WeatherSortColors.primary,
    );
  }

  return const _MoveGuidance(
    message: 'Choose the next source and keep one helper vessel open.',
    icon: Icons.lightbulb_outline_rounded,
    color: WeatherSortColors.primary,
  );
}

class _MoveGuidance {
  const _MoveGuidance({
    required this.message,
    required this.icon,
    required this.color,
  });

  final String message;
  final IconData icon;
  final Color color;
}

class _MoveGuidanceBanner extends StatelessWidget {
  const _MoveGuidanceBanner({super.key, required this.guidance});

  final _MoveGuidance guidance;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: guidance.color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: guidance.color.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(guidance.icon, color: guidance.color, size: 20),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                guidance.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: WeatherSortColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttemptPaceBar extends StatelessWidget {
  const _AttemptPaceBar({required this.controller});

  final WaterSortController controller;

  @override
  Widget build(BuildContext context) {
    final parMoves = controller.currentLevel.parMoves;
    final progress = (controller.moveCount / parMoves)
        .clamp(0.0, 1.0)
        .toDouble();
    final color = controller.isOnThreeStarPace
        ? WeatherSortColors.mint
        : WeatherSortColors.coral;
    final label = controller.isOnThreeStarPace
        ? '${controller.movesLeftForThreeStars} moves left on 3-star pace'
        : '${controller.moveCount - parMoves} moves over par';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WeatherSortColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.stacked_line_chart_rounded, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: WeatherSortColors.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${controller.moveCount}/$parMoves',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: WeatherSortColors.mutedInk,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                color: color,
                backgroundColor: color.withValues(alpha: 0.14),
              ),
            ),
          ],
        ),
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 7),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$label: ',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Text(
                    value,
                    key: ValueKey(value),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showHowToPlay(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'How to Play',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              const _HelpRow(
                icon: Icons.touch_app_rounded,
                text:
                    'Tap a vessel with liquid, then tap where it should pour.',
              ),
              const _HelpRow(
                icon: Icons.compare_arrows_rounded,
                text:
                    'You can pour into an empty vessel or onto matching top liquid.',
              ),
              const _HelpRow(
                icon: Icons.check_circle_rounded,
                text:
                    'Win when every non-empty vessel contains one weather essence.',
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showPauseMenu(BuildContext context, WaterSortController controller) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Paused',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Continue'),
                  ),
                  const SizedBox(height: 10),
                  WeatherPanel(
                    color: WeatherSortColors.wash,
                    borderColor: const Color(0xFFC9DAE8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: controller.soundEnabled,
                          onChanged: (value) {
                            controller.toggleSound(value);
                            setModalState(() {});
                          },
                          secondary: const Icon(Icons.volume_up_rounded),
                          title: const Text('Sound'),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          value: controller.hapticsEnabled,
                          onChanged: (value) {
                            controller.toggleHaptics(value);
                            setModalState(() {});
                          },
                          secondary: const Icon(Icons.vibration_rounded),
                          title: const Text('Haptics'),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      controller.restartLevel();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Restart Level'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      controller.backHome();
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
    },
  );
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: WeatherSortColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: WeatherSortColors.mutedInk,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
