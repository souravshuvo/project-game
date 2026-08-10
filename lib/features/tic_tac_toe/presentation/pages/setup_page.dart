import 'package:flutter/material.dart';

import '../../application/game_mode.dart';
import '../../application/tic_tac_toe_controller.dart';
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
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: controller.showSettings,
                  icon: const Icon(Icons.tune_rounded),
                  tooltip: 'Settings',
                ),
              ),
              const SizedBox(height: 48),
              const Center(child: ObservatoryMark(size: 88)),
              const SizedBox(height: 24),
              Text(
                'Pocket Observatory',
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
              const SizedBox(height: 38),
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
              FilledButton.icon(
                onPressed: controller.startGame,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start'),
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
            ],
          ),
        ),
      ),
    );
  }
}
