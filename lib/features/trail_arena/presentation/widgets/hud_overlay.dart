import 'package:flutter/material.dart';

import '../../domain/run_stats.dart';
import '../../domain/trail_goal.dart';
import 'trail_goal_widgets.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({
    super.key,
    required this.score,
    required this.bestScore,
    required this.activeGoal,
    required this.runStats,
    required this.onPause,
  });

  final int score;
  final int bestScore;
  final TrailGoalDefinition? activeGoal;
  final RunStats runStats;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final goal = activeGoal;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              _HudMetric(label: 'Score', value: score.toString()),
              const SizedBox(width: 10),
              _HudMetric(label: 'Best', value: bestScore.toString()),
              const Spacer(),
              IconButton.filledTonal(
                tooltip: 'Pause',
                onPressed: onPause,
                style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                icon: const Icon(Icons.pause_rounded),
              ),
            ],
          ),
        ),
        if (goal != null) ActiveGoalStrip(goal: goal, stats: runStats),
      ],
    );
  }
}

class _HudMetric extends StatelessWidget {
  const _HudMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 86),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF193528),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF315940)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9AB5A5),
              fontSize: 11,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: Tween(begin: 0.9, end: 1.0).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Text(
              value,
              key: ValueKey(value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
