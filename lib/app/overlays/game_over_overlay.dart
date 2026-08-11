import 'package:flutter/material.dart';

import '../../game/models/run_state.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.score,
    required this.bestScore,
    required this.deathReason,
    required this.isNewBest,
    required this.onRestart,
  });

  final int score;
  final int bestScore;
  final DeathReason deathReason;
  final bool isNewBest;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final resultMessage = isNewBest
        ? 'New best route.\nScore $score   Best $bestScore'
        : '${deathReason.message}\nScore $score   Best $bestScore';

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
                        isNewBest ? 'NEW BEST' : 'RUN ENDED',
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
