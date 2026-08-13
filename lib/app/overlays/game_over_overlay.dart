import 'package:flutter/material.dart';

import '../../game/models/run_state.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.score,
    required this.bestScore,
    required this.routeLabel,
    required this.routeTitle,
    required this.goalLabel,
    required this.progressLabel,
    required this.pickups,
    required this.deathReason,
    required this.isNewBest,
    required this.routeCompleted,
    required this.onRestart,
    required this.onHome,
    this.canRewardedRevive = false,
    this.onRewardedRevive,
  });

  final int score;
  final int bestScore;
  final String routeLabel;
  final String routeTitle;
  final String goalLabel;
  final String progressLabel;
  final int pickups;
  final DeathReason deathReason;
  final bool isNewBest;
  final bool routeCompleted;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  final bool canRewardedRevive;
  final VoidCallback? onRewardedRevive;

  @override
  Widget build(BuildContext context) {
    final resultTitle = routeCompleted
        ? 'ROUTE COMPLETE'
        : isNewBest
        ? 'NEW BEST'
        : 'RUN ENDED';
    final resultMessage = routeCompleted
        ? '$routeLabel - $routeTitle\n$goalLabel\nSignals $pickups   Score $score'
        : isNewBest
        ? 'New best route.\nScore $score   Best $bestScore'
        : '${deathReason.message}\n$progressLabel\nScore $score   Best $bestScore';

    return ColoredBox(
      color: const Color(0xff062d33).withAlpha(96),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xfffff8df).withAlpha(238),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xff163d3f), width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        resultTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xff163d3f),
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        resultMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xff274c48),
                          fontSize: 16,
                          height: 1.35,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (canRewardedRevive && onRewardedRevive != null) ...[
                        FilledButton(
                          onPressed: onRewardedRevive,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(172, 52),
                            backgroundColor: const Color(0xff1d6f78),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'WATCH TO REVIVE',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      FilledButton(
                        onPressed: onRestart,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(172, 52),
                          backgroundColor: const Color(0xffd64c35),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'RESTART',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: onHome,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(172, 44),
                          foregroundColor: const Color(0xff163d3f),
                          side: const BorderSide(
                            color: Color(0xff163d3f),
                            width: 1.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'HOME',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
