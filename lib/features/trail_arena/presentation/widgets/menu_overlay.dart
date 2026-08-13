import 'package:flutter/material.dart';

import '../../domain/trail_goal.dart';
import 'trail_goal_widgets.dart';

class MenuOverlay extends StatelessWidget {
  const MenuOverlay({
    super.key,
    required this.bestScore,
    required this.gamesPlayed,
    required this.completedGoalCount,
    required this.totalGoalCount,
    required this.nextGoals,
    required this.onPlay,
    required this.onSettings,
    required this.onHelp,
    this.adSlot,
  });

  final int bestScore;
  final int gamesPlayed;
  final int completedGoalCount;
  final int totalGoalCount;
  final List<TrailGoalDefinition> nextGoals;
  final VoidCallback onPlay;
  final VoidCallback onSettings;
  final VoidCallback onHelp;
  final Widget? adSlot;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF101510)),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _BrandMark(),
                const SizedBox(height: 22),
                const Text(
                  'Trail Arena',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Drag to steer, collect seeds, and avoid every trail.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFB8C9BD),
                    fontSize: 15,
                    height: 1.35,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MenuMetric(label: 'Best', value: bestScore.toString()),
                    const SizedBox(width: 12),
                    _MenuMetric(label: 'Runs', value: gamesPlayed.toString()),
                  ],
                ),
                const SizedBox(height: 24),
                TrailGoalPanel(
                  completedCount: completedGoalCount,
                  totalCount: totalGoalCount,
                  nextGoals: nextGoals,
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Play'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onHelp,
                        icon: const Icon(Icons.help_outline_rounded),
                        label: const Text('Help'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSettings,
                        icon: const Icon(Icons.tune_rounded),
                        label: const Text('Settings'),
                      ),
                    ),
                  ],
                ),
                if (adSlot != null) ...[const SizedBox(height: 14), adSlot!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: const Color(0xFF193528),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF46735A), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x4433DFA0), blurRadius: 22, spreadRadius: 2),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.radio_button_checked_rounded,
          color: Color(0xFF65F0B4),
          size: 52,
        ),
      ),
    );
  }
}

class _MenuMetric extends StatelessWidget {
  const _MenuMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF9AB5A5), letterSpacing: 0),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
