import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../ads/ad_service.dart';
import '../analytics/analytics_service.dart';
import '../app/feedback_controller.dart';
import '../app/game_progress.dart';
import '../app/game_settings.dart';
import '../game/challenges/challenge.dart';
import '../game/game_feedback.dart';
import '../game/game_result.dart';
import '../game/rooftop_curve_game.dart';
import 'settings_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.settings,
    required this.analytics,
    required this.ads,
    this.initialChallengeIndex,
  });

  final GameSettings settings;
  final AnalyticsService analytics;
  final AdService ads;
  final int? initialChallengeIndex;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final RooftopCurveGame _game;
  late final FeedbackController _feedback;
  GameResult? _result;
  int _attempts = 1;
  int _challengeNumber = 1;
  int _challengeCount = 1;
  String _challengeName = 'Open Rooftop';
  String _objective = 'Score into the open goal.';
  bool _isAiming = false;
  bool _isPaused = false;
  bool _invalidHintVisible = false;
  bool _resultFlashVisible = false;
  bool _advancingChallenge = false;
  double _aimPower = 0;
  double _aimCurve = 0;
  int _invalidHintToken = 0;
  int _resultFlashToken = 0;
  Color _resultFlashColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _feedback = FeedbackController(widget.settings);
    _game = RooftopCurveGame(
      initialChallengeIndex:
          widget.initialChallengeIndex ??
          widget.settings.progress.highestUnlockedChallengeIndex,
      onChallengeChanged: _handleChallengeChanged,
      onAimingChanged: (isAiming) {
        _setStateSafely(() {
          _isAiming = isAiming;
          if (isAiming) {
            _invalidHintVisible = false;
          }
        });
      },
      onAimUpdated: (power, curve) {
        _setStateSafely(() {
          _aimPower = power;
          _aimCurve = curve;
        });
      },
      onFeedback: _handleFeedback,
      onAttemptsChanged: (attempts) {
        _setStateSafely(() => _attempts = attempts);
      },
      onResult: (result) {
        var stars = 0;
        if (result.type == GameResultType.goal) {
          stars = widget.settings.recordGoal(
            challengeId: result.challengeId,
            challengeIndex: _challengeNumber - 1,
            attempt: result.attempt,
            totalChallenges: _challengeCount,
          );
        }
        _setStateSafely(() => _result = result);
        unawaited(
          widget.analytics.logChallengeResult(
            challengeId: result.challengeId,
            challengeNumber: _challengeNumber,
            result: result.type.name,
            attempts: result.attempt,
            stars: stars,
            completedCount: widget.settings.progress.completedCount,
            totalStars: widget.settings.progress.totalStars,
          ),
        );
        _showResultFlash(result.type);
      },
    );
  }

  void _setStateSafely(VoidCallback update) {
    if (!mounted) {
      return;
    }

    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      setState(update);
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(update);
    });
  }

  void _handleChallengeChanged(
    Challenge challenge,
    int challengeIndex,
    int totalChallenges,
  ) {
    _setStateSafely(() {
      _challengeNumber = challengeIndex + 1;
      _challengeCount = totalChallenges;
      _challengeName = challenge.name;
      _objective = challenge.objective;
      _attempts = 1;
      _result = null;
      _isAiming = false;
      _aimPower = 0;
      _aimCurve = 0;
    });
    unawaited(
      widget.analytics.logChallengeStart(
        challengeId: challenge.id,
        challengeNumber: challengeIndex + 1,
        totalChallenges: totalChallenges,
        challengeName: challenge.name,
      ),
    );
  }

  void _retry() {
    final result = _result;
    unawaited(
      widget.analytics.logRetry(
        challengeNumber: _challengeNumber,
        source: result?.type == GameResultType.goal ? 'replay' : 'retry',
        previousResult: result?.type.name ?? 'manual_restart',
      ),
    );
    setState(() {
      _result = null;
    });
    if (result?.type == GameResultType.goal) {
      _game.restartChallenge();
    } else {
      _game.retry(countAttempt: result != null);
    }
  }

  Future<void> _nextChallenge() async {
    if (_advancingChallenge) {
      return;
    }
    setState(() => _advancingChallenge = true);
    final completedCount = widget.settings.progress.completedCount;
    unawaited(
      widget.analytics.logNextChallenge(
        fromChallengeNumber: _challengeNumber,
        completedCount: completedCount,
      ),
    );

    await widget.ads.maybeShowInterstitial(
      placement: 'challenge_complete',
      completedChallenges: completedCount,
      challengeNumber: _challengeNumber,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _result = null;
      _advancingChallenge = false;
    });
    _game.nextChallenge();
  }

  void _handleFeedback(GameFeedback feedback) {
    _feedback.play(feedback);
    if (feedback == GameFeedback.invalid) {
      _showInvalidHint();
    }
  }

  void _showInvalidHint() {
    final token = ++_invalidHintToken;
    _setStateSafely(() => _invalidHintVisible = true);
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted || token != _invalidHintToken) {
        return;
      }
      setState(() => _invalidHintVisible = false);
    });
  }

  void _showResultFlash(GameResultType type) {
    final token = ++_resultFlashToken;
    _setStateSafely(() {
      _resultFlashColor = switch (type) {
        GameResultType.goal => const Color(0xFF70E000),
        GameResultType.saved => const Color(0xFFFFD166),
        GameResultType.blocked => const Color(0xFFEF476F),
        GameResultType.missed ||
        GameResultType.tooWeak => const Color(0xFFFF6B6B),
      };
      _resultFlashVisible = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 180), () {
      if (!mounted || token != _resultFlashToken) {
        return;
      }
      setState(() => _resultFlashVisible = false);
    });
  }

  void _setPaused(bool paused) {
    if (_isPaused == paused) {
      return;
    }
    _feedback.play(GameFeedback.tap);
    setState(() => _isPaused = paused);
    if (paused) {
      _game.pauseEngine();
    } else {
      _game.resumeEngine();
    }
  }

  void _showHelp() {
    _feedback.play(GameFeedback.tap);
    unawaited(widget.analytics.logMenuAction('game_help'));
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Shot Controls'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Touch the glowing ball or the space just below it.'),
              SizedBox(height: 8),
              Text('Pull down to shoot upward. Pull farther for more power.'),
              SizedBox(height: 8),
              Text('Move left or right while dragging to curve the ball.'),
              SizedBox(height: 8),
              Text('Release to shoot. Retry is always available.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _feedback.play(GameFeedback.tap);
                Navigator.of(context).pop();
              },
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  void _openSettings() {
    _feedback.play(GameFeedback.tap);
    unawaited(widget.analytics.logMenuAction('game_settings'));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          settings: widget.settings,
          analytics: widget.analytics,
        ),
      ),
    );
  }

  int _starsForAttempt(int attempt) {
    return GameProgress.starsForAttempt(attempt);
  }

  Vector2 _pointerToGame(Offset localPosition) {
    return Vector2(localPosition.dx, localPosition.dy);
  }

  String _starLabel(int stars) {
    return '$stars/3';
  }

  String? _bestLabelFor(int challengeId) {
    final bestStars = widget.settings.progress.bestStarsFor(challengeId);
    if (bestStars == 0) {
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
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details) {
                _game.startAimFromWidget(
                  _pointerToGame(details.localPosition),
                );
              },
              onPanUpdate: (details) {
                _game.updateAimFromWidget(
                  _pointerToGame(details.localPosition),
                );
              },
              onPanEnd: (_) => _game.releaseAim(),
              onPanCancel: _game.cancelAim,
            ),
          ),
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
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Pause',
                    onPressed: () => _setPaused(true),
                    icon: const Icon(Icons.pause),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 74,
            child: SafeArea(
              bottom: false,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _isAiming ? 1 : 0,
                  duration: const Duration(milliseconds: 100),
                  child: _AimMeter(power: _aimPower, curve: _aimCurve),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _resultFlashVisible ? 0.18 : 0,
                duration: const Duration(milliseconds: 140),
                child: ColoredBox(color: _resultFlashColor),
              ),
            ),
          ),
          Positioned(
            left: 32,
            right: 32,
            top: 136,
            child: SafeArea(
              bottom: false,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _invalidHintVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 120),
                  child: const _ToastPanel(
                    message: 'Touch the glowing ball, then pull down.',
                  ),
                ),
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
                      isFinalChallenge: !_game.hasNextChallenge,
                      starLabel: _starLabel(_starsForAttempt(_result!.attempt)),
                      bestLabel: _bestLabelFor(_result!.challengeId),
                      onNext: _nextChallenge,
                      onRetry: _retry,
                    ),
            ),
          ),
          if (_isPaused)
            Positioned.fill(
              child: _PauseOverlay(
                onResume: () => _setPaused(false),
                onRestart: () {
                  _setPaused(false);
                  _retry();
                },
                onHelp: _showHelp,
                onSettings: _openSettings,
                onHome: () {
                  _feedback.play(GameFeedback.tap);
                  Navigator.of(context).pop();
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _AimMeter extends StatelessWidget {
  const _AimMeter({required this.power, required this.curve});

  final double power;
  final double curve;

  @override
  Widget build(BuildContext context) {
    final curveLabel = curve.abs() < 0.08
        ? 'Straight'
        : curve < 0
        ? 'Curve left'
        : 'Curve right';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Power', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: power.clamp(0.0, 1.0).toDouble()),
            const SizedBox(height: 8),
            Text(curveLabel, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ToastPanel extends StatelessWidget {
  const _ToastPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({
    required this.onResume,
    required this.onRestart,
    required this.onHelp,
    required this.onSettings,
    required this.onHome,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onHelp;
  final VoidCallback onSettings;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.72),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Paused',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: onResume,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: onRestart,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Restart Challenge'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: onHelp,
                    icon: const Icon(Icons.help_outline),
                    label: const Text('How to Play'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: onSettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('Settings'),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: onHome,
                    icon: const Icon(Icons.home),
                    label: const Text('Main Menu'),
                  ),
                ],
              ),
            ),
          ),
        ),
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
              'Touch the glowing ball, pull down for power, '
              'slide sideways for curve.',
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
    required this.isFinalChallenge,
    required this.starLabel,
    required this.bestLabel,
    required this.onNext,
    required this.onRetry,
  });

  final GameResult result;
  final bool canGoNext;
  final bool isFinalChallenge;
  final String starLabel;
  final String? bestLabel;
  final VoidCallback onNext;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: DecoratedBox(
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(result.message, textAlign: TextAlign.center),
              if (result.type == GameResultType.goal) ...[
                const SizedBox(height: 6),
                Text('Stars: $starLabel'),
                if (bestLabel != null) Text('Best: $bestLabel'),
                if (isFinalChallenge) const Text('All v1 challenges complete.'),
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
                    result.type == GameResultType.goal
                        ? 'Replay Final'
                        : 'Retry',
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
      ),
    );
  }
}
