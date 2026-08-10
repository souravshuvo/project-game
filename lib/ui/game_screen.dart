import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/challenges/challenge.dart';
import '../game/game_result.dart';
import '../game/rooftop_curve_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final RooftopCurveGame _game;
  GameResult? _result;
  int _attempts = 1;
  int _challengeNumber = 1;
  int _challengeCount = 1;
  String _challengeName = 'Open Rooftop';
  String _objective = 'Score into the open goal.';
  bool _isAiming = false;
  final Map<int, int> _bestStarsByChallenge = {};

  @override
  void initState() {
    super.initState();
    _game = RooftopCurveGame(
      onChallengeChanged: _handleChallengeChanged,
      onAimingChanged: (isAiming) {
        setState(() => _isAiming = isAiming);
      },
      onAttemptsChanged: (attempts) {
        setState(() => _attempts = attempts);
      },
      onResult: (result) {
        setState(() {
          _result = result;
          if (result.type == GameResultType.goal) {
            final stars = _starsForAttempt(result.attempt);
            final previous = _bestStarsByChallenge[result.challengeId] ?? 0;
            if (stars > previous) {
              _bestStarsByChallenge[result.challengeId] = stars;
            }
          }
        });
      },
    );
  }

  void _handleChallengeChanged(
    Challenge challenge,
    int challengeIndex,
    int totalChallenges,
  ) {
    setState(() {
      _challengeNumber = challengeIndex + 1;
      _challengeCount = totalChallenges;
      _challengeName = challenge.name;
      _objective = challenge.objective;
      _attempts = 1;
      _result = null;
      _isAiming = false;
    });
  }

  void _retry() {
    final result = _result;
    setState(() {
      _result = null;
    });
    if (result?.type == GameResultType.goal) {
      _game.restartChallenge();
    } else {
      _game.retry(countAttempt: result != null);
    }
  }

  void _nextChallenge() {
    setState(() => _result = null);
    _game.nextChallenge();
  }

  int _starsForAttempt(int attempt) {
    if (attempt <= 1) {
      return 3;
    }
    if (attempt <= 3) {
      return 2;
    }
    return 1;
  }

  String _starLabel(int stars) {
    return '$stars/3';
  }

  String? _bestLabelFor(int challengeId) {
    final bestStars = _bestStarsByChallenge[challengeId];
    if (bestStars == null) {
      return null;
    }
    return _starLabel(bestStars);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget<RooftopCurveGame>(game: _game)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _HudPill(
                    label: 'Challenge',
                    value: '$_challengeNumber/$_challengeCount',
                  ),
                  const SizedBox(width: 8),
                  _HudPill(label: 'Attempts', value: '$_attempts'),
                  const Spacer(),
                  IconButton.filledTonal(
                    tooltip: 'Restart',
                    onPressed: _retry,
                    icon: const Icon(Icons.restart_alt),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: _result == null
                  ? IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: _isAiming ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 140),
                        child: _InstructionPanel(
                          title: _challengeName,
                          objective: _objective,
                        ),
                      ),
                    )
                  : _ResultPanel(
                      result: _result!,
                      canGoNext: _game.hasNextChallenge,
                      starLabel: _starLabel(_starsForAttempt(_result!.attempt)),
                      bestLabel: _bestLabelFor(_result!.challengeId),
                      onNext: _nextChallenge,
                      onRetry: _retry,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HudPill extends StatelessWidget {
  const _HudPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text('$label: $value'),
      ),
    );
  }
}

class _InstructionPanel extends StatelessWidget {
  const _InstructionPanel({required this.title, required this.objective});

  final String title;
  final String objective;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(objective, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            const Text(
              'Drag from the ball, pull back for power, slide sideways for curve.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.result,
    required this.canGoNext,
    required this.starLabel,
    required this.bestLabel,
    required this.onNext,
    required this.onRetry,
  });

  final GameResult result;
  final bool canGoNext;
  final String starLabel;
  final String? bestLabel;
  final VoidCallback onNext;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              result.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(result.message, textAlign: TextAlign.center),
            if (result.type == GameResultType.goal) ...[
              const SizedBox(height: 6),
              Text('Stars: $starLabel'),
              if (bestLabel != null) Text('Best: $bestLabel'),
            ],
            const SizedBox(height: 12),
            if (result.type == GameResultType.goal && canGoNext)
              FilledButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next Challenge'),
              )
            else
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.restart_alt),
                label: Text(
                  result.type == GameResultType.goal ? 'Play Again' : 'Retry',
                ),
              ),
            if (result.type == GameResultType.goal && canGoNext) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Replay'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
