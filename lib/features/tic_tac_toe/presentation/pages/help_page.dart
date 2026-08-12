import 'package:flutter/material.dart';

import '../../application/tic_tac_toe_controller.dart';
import '../theme/pocket_observatory_theme.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key, required this.controller});

  final TicTacToeController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: controller.closeHelp,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
        title: const Text('How to Play'),
      ),
      body: ObservatoryBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            children: [
              const ObservatoryPanel(
                color: PocketObservatoryColors.panel,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HelpStep(
                      icon: Icons.filter_3_rounded,
                      title: 'Make a line',
                      body:
                          'Place three of your marks in a row, column, or diagonal.',
                    ),
                    SizedBox(height: 16),
                    _HelpStep(
                      icon: Icons.touch_app_rounded,
                      title: 'Tap open cells',
                      body:
                          'Open cells glow. Used cells shake if you tap them again.',
                    ),
                    SizedBox(height: 16),
                    _HelpStep(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Against AI',
                      body:
                          'You play X. The AI plays O after a short thinking beat.',
                    ),
                    SizedBox(height: 16),
                    _HelpStep(
                      icon: Icons.replay_rounded,
                      title: 'Play a match',
                      body:
                          'Single Round saves after one round. Best of 3 and Best of 5 continue until someone reaches the target.',
                    ),
                    SizedBox(height: 16),
                    _HelpStep(
                      icon: Icons.history_rounded,
                      title: 'Check history',
                      body:
                          'Your last 10 completed matches stay on this device.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: controller.closeHelp,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Got it'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpStep extends StatelessWidget {
  const _HelpStep({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: PocketObservatoryColors.gold),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PocketObservatoryColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PocketObservatoryColors.mutedInk,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
