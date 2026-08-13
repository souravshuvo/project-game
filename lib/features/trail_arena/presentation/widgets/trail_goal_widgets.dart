import 'package:flutter/material.dart';

import '../../domain/run_stats.dart';
import '../../domain/trail_goal.dart';

class TrailGoalPanel extends StatelessWidget {
  const TrailGoalPanel({
    super.key,
    required this.completedCount,
    required this.totalCount,
    required this.nextGoals,
  });

  final int completedCount;
  final int totalCount;
  final List<TrailGoalDefinition> nextGoals;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF142018),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF315940)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.flag_rounded,
                  color: Color(0xFF65F0B4),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Trail Goals $completedCount/$totalCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (nextGoals.isEmpty)
              const Text(
                'All goals complete. Keep chasing your best score.',
                style: TextStyle(
                  color: Color(0xFFB8C9BD),
                  fontSize: 13,
                  height: 1.25,
                  letterSpacing: 0,
                ),
              )
            else
              for (final goal in nextGoals)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _GoalDescription(goal: goal),
                ),
          ],
        ),
      ),
    );
  }
}

class ActiveGoalStrip extends StatelessWidget {
  const ActiveGoalStrip({super.key, required this.goal, required this.stats});

  final TrailGoalDefinition goal;
  final RunStats stats;

  @override
  Widget build(BuildContext context) {
    final progress = goal.progressFrom(stats);
    final ratio = goal.target == 0 ? 0.0 : progress / goal.target;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF142018),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF315940)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.flag_rounded,
                    color: Color(0xFF65F0B4),
                    size: 16,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      goal.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  Text(
                    goal.progressLabel(stats),
                    style: const TextStyle(
                      color: Color(0xFFB8C9BD),
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 5,
                  value: ratio.clamp(0.0, 1.0).toDouble(),
                  backgroundColor: const Color(0xFF24382D),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF65F0B4)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompletedGoalsPanel extends StatelessWidget {
  const CompletedGoalsPanel({super.key, required this.goals});

  final List<TrailGoalDefinition> goals;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return const SizedBox.shrink();
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF193528),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF65F0B4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFFFFD166),
                  size: 18,
                ),
                SizedBox(width: 7),
                Text(
                  'Goals Complete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            for (final goal in goals.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    color: Color(0xFFB8C9BD),
                    fontSize: 12,
                    letterSpacing: 0,
                  ),
                ),
              ),
            if (goals.length > 3)
              Text(
                '+${goals.length - 3} more',
                style: const TextStyle(
                  color: Color(0xFFFFD166),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GoalDescription extends StatelessWidget {
  const _GoalDescription({required this.goal});

  final TrailGoalDefinition goal;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(Icons.circle, color: Color(0xFF65F0B4), size: 6),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              Text(
                goal.description,
                style: const TextStyle(
                  color: Color(0xFFB8C9BD),
                  fontSize: 12,
                  height: 1.25,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
