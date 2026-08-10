import 'package:flutter/material.dart';

import '../../application/game_mode.dart';
import '../../application/tic_tac_toe_controller.dart';
import '../../domain/round_outcome.dart';
import '../../domain/tic_tac_toe_mark.dart';
import '../theme/pocket_observatory_theme.dart';
import '../widgets/tic_tac_toe_board_widget.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key, required this.controller});

  final TicTacToeController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: controller.changeMode,
          icon: const Icon(Icons.grid_view_rounded),
          tooltip: 'Change mode',
        ),
        title: Text(controller.mode.label),
        actions: [
          IconButton(
            onPressed: controller.showSettings,
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: ObservatoryBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ScoreStrip(controller: controller),
                      const SizedBox(height: 14),
                      _TurnBanner(controller: controller),
                      const SizedBox(height: 18),
                      Center(
                        child: TicTacToeBoardWidget(controller: controller),
                      ),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: controller.round.outcome.isOver
                            ? _ResultPanel(
                                key: ValueKey(
                                  controller.round.outcome.status.name,
                                ),
                                controller: controller,
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: controller.restartRound,
                            icon: Icon(
                              controller.round.outcome.isOver
                                  ? Icons.replay_rounded
                                  : Icons.refresh_rounded,
                            ),
                            label: Text(
                              controller.round.outcome.isOver
                                  ? 'Rematch'
                                  : 'Restart',
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: controller.resetScore,
                            icon: const Icon(Icons.restart_alt_rounded),
                            label: const Text('Reset Score'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScoreStrip extends StatelessWidget {
  const _ScoreStrip({required this.controller});

  final TicTacToeController controller;

  @override
  Widget build(BuildContext context) {
    final oLabel = controller.mode == GameMode.vsAi ? 'AI O' : 'Player O';

    return Row(
      children: [
        Expanded(
          child: _ScoreTile(
            label: 'Player X',
            value: controller.score.xWins,
            color: PocketObservatoryColors.violet,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ScoreTile(
            label: oLabel,
            value: controller.score.oWins,
            color: PocketObservatoryColors.teal,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ScoreTile(
            label: 'Draws',
            value: controller.score.draws,
            color: PocketObservatoryColors.gold,
          ),
        ),
      ],
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ObservatoryPanel(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      color: PocketObservatoryColors.deepInk.withValues(alpha: 0.9),
      borderColor: color.withValues(alpha: 0.42),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: PocketObservatoryColors.mutedOnDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TurnBanner extends StatelessWidget {
  const _TurnBanner({required this.controller});

  final TicTacToeController controller;

  @override
  Widget build(BuildContext context) {
    final text = _turnText();

    return ObservatoryPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: PocketObservatoryColors.panel,
      borderColor: PocketObservatoryColors.gold.withValues(alpha: 0.7),
      child: Row(
        children: [
          Icon(_turnIcon(), color: PocketObservatoryColors.ink),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Semantics(
                key: ValueKey(text),
                liveRegion: true,
                label: text,
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: PocketObservatoryColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _turnIcon() {
    if (controller.round.outcome.isOver) {
      return Icons.flag_rounded;
    }
    if (controller.isAiThinking) {
      return Icons.auto_awesome_rounded;
    }

    return controller.round.currentMark == TicTacToeMark.x
        ? Icons.close_rounded
        : Icons.radio_button_unchecked_rounded;
  }

  String _turnText() {
    final outcome = controller.round.outcome;
    if (outcome.status == RoundStatus.draw) {
      return 'Draw';
    }
    if (outcome.status == RoundStatus.won) {
      return '${outcome.winner?.symbol ?? ''} wins';
    }
    if (controller.isAiThinking) {
      return 'AI is choosing';
    }
    if (controller.mode == GameMode.vsAi) {
      return controller.round.currentMark == TicTacToeController.humanMark
          ? 'Your turn: X'
          : 'AI turn: O';
    }

    return '${controller.round.currentMark.symbol} turn';
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({super.key, required this.controller});

  final TicTacToeController controller;

  @override
  Widget build(BuildContext context) {
    final message = _message();

    return Semantics(
      container: true,
      liveRegion: true,
      label: message,
      child: ObservatoryPanel(
        color: PocketObservatoryColors.panelSoft,
        borderColor: PocketObservatoryColors.gold,
        child: Row(
          children: [
            Icon(_icon(), color: PocketObservatoryColors.ink),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PocketObservatoryColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon() {
    return controller.round.outcome.status == RoundStatus.draw
        ? Icons.handshake_rounded
        : Icons.emoji_events_rounded;
  }

  String _message() {
    final outcome = controller.round.outcome;
    if (outcome.status == RoundStatus.draw) {
      return 'No winner this round.';
    }
    if (controller.mode == GameMode.vsAi) {
      return outcome.winner == TicTacToeController.humanMark
          ? 'You won this round.'
          : 'AI won this round.';
    }

    return '${outcome.winner?.symbol ?? ''} won this round.';
  }
}
