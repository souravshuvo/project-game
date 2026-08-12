import 'package:flutter/material.dart';

import '../../application/game_mode.dart';
import '../../application/tic_tac_toe_controller.dart';
import '../../domain/match_format.dart';
import '../../domain/match_record.dart';
import '../theme/pocket_observatory_theme.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({super.key, required this.controller});

  final TicTacToeController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ObservatoryBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: controller.showHelp,
                    icon: const Icon(Icons.help_outline_rounded),
                    tooltip: 'How to play',
                  ),
                  IconButton(
                    onPressed: controller.showSettings,
                    icon: const Icon(Icons.tune_rounded),
                    tooltip: 'Settings',
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Center(child: ObservatoryMark(size: 84)),
              const SizedBox(height: 20),
              Text(
                'Tik Tak Toe',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Text(
                'A tiny star-map duel for quick rounds.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PocketObservatoryColors.mutedOnDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),
              const _GoalPanel(),
              const SizedBox(height: 18),
              SegmentedButton<GameMode>(
                segments: const [
                  ButtonSegment(
                    value: GameMode.localTwoPlayer,
                    icon: Icon(Icons.people_alt_rounded),
                    label: Text('Two Players'),
                  ),
                  ButtonSegment(
                    value: GameMode.vsAi,
                    icon: Icon(Icons.auto_awesome_rounded),
                    label: Text('Vs AI'),
                  ),
                ],
                selected: {controller.mode},
                onSelectionChanged: (selection) {
                  controller.selectMode(selection.first);
                },
              ),
              const SizedBox(height: 18),
              _MatchFormatPicker(controller: controller),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: controller.startGame,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Round'),
              ),
              const SizedBox(height: 18),
              ObservatoryPanel(
                color: PocketObservatoryColors.deepInk.withValues(alpha: 0.82),
                child: Row(
                  children: [
                    Icon(
                      controller.mode == GameMode.vsAi
                          ? Icons.memory_rounded
                          : Icons.swap_horiz_rounded,
                      color: PocketObservatoryColors.gold,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.mode == GameMode.vsAi
                            ? 'Solo orbit: X vs AI'
                            : 'Shared board: X vs O',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: PocketObservatoryColors.mutedOnDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _RecentMatchesPanel(records: controller.recentMatches),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchFormatPicker extends StatelessWidget {
  const _MatchFormatPicker({required this.controller});

  final TicTacToeController controller;

  @override
  Widget build(BuildContext context) {
    return ObservatoryPanel(
      color: PocketObservatoryColors.panel,
      borderColor: PocketObservatoryColors.teal.withValues(alpha: 0.58),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: PocketObservatoryColors.ink,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Match Format',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: PocketObservatoryColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<MatchFormat>(
            showSelectedIcon: false,
            segments: [
              for (final format in MatchFormat.values)
                ButtonSegment(value: format, label: Text(format.shortLabel)),
            ],
            selected: {controller.matchFormat},
            onSelectionChanged: (selection) {
              controller.selectMatchFormat(selection.first);
            },
          ),
          const SizedBox(height: 10),
          Text(
            controller.matchFormat.setupDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: PocketObservatoryColors.mutedInk,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentMatchesPanel extends StatelessWidget {
  const _RecentMatchesPanel({required this.records});

  final List<MatchRecord> records;

  @override
  Widget build(BuildContext context) {
    return ObservatoryPanel(
      color: PocketObservatoryColors.deepInk.withValues(alpha: 0.82),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history_rounded,
                color: PocketObservatoryColors.gold,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Recent Matches',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: PocketObservatoryColors.textOnDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (records.isEmpty)
            Text(
              'Completed matches will appear here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PocketObservatoryColors.mutedOnDark,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            for (final record in records.take(10)) _RecentMatchRow(record),
        ],
      ),
    );
  }
}

class _RecentMatchRow extends StatelessWidget {
  const _RecentMatchRow(this.record);

  final MatchRecord record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(_icon(), color: _color(), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${record.resultLabel} ${record.scoreLabel}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PocketObservatoryColors.textOnDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            record.format.shortLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: PocketObservatoryColors.mutedOnDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon() {
    return record.winner == null
        ? Icons.handshake_rounded
        : Icons.emoji_events_rounded;
  }

  Color _color() {
    return record.winner == null
        ? PocketObservatoryColors.gold
        : PocketObservatoryColors.teal;
  }
}

class _GoalPanel extends StatelessWidget {
  const _GoalPanel();

  @override
  Widget build(BuildContext context) {
    return ObservatoryPanel(
      color: PocketObservatoryColors.panel,
      borderColor: PocketObservatoryColors.gold.withValues(alpha: 0.78),
      child: Row(
        children: [
          const Icon(
            Icons.filter_3_rounded,
            color: PocketObservatoryColors.ink,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tap an open cell. First to make three in a row wins.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: PocketObservatoryColors.ink,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
