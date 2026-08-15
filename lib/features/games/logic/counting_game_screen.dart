import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/letter_audio_cue.dart';
import 'logic_game_ui.dart';

class CountingGameScreen extends StatefulWidget {
  const CountingGameScreen({
    required this.audioCue,
    super.key,
    this.onCompleted,
    this.onPlayNextGame,
    this.nextGameTitle,
  });

  final LetterAudioCue audioCue;
  final VoidCallback? onCompleted;
  final VoidCallback? onPlayNextGame;
  final String? nextGameTitle;

  static int get contentCount => _CountingGameScreenState.contentCount;

  @override
  State<CountingGameScreen> createState() => _CountingGameScreenState();
}

class _CountingRound {
  const _CountingRound({
    required this.emoji,
    required this.name,
    required this.count,
    required this.answers,
  });

  final String emoji;
  final String name;
  final int count;
  final List<int> answers;
}

class _CountingGameScreenState extends State<CountingGameScreen> {
  static const _rounds = <_CountingRound>[
    _CountingRound(
      emoji: '\u{1F7E3}',
      name: 'dots',
      count: 1,
      answers: [1, 2, 3],
    ),
    _CountingRound(emoji: '⭐', name: 'stars', count: 2, answers: [1, 2, 3]),
    _CountingRound(
      emoji: '🐥',
      name: 'ducklings',
      count: 3,
      answers: [4, 2, 3],
    ),
    _CountingRound(emoji: '🍎', name: 'apples', count: 4, answers: [4, 5, 3]),
    _CountingRound(emoji: '⚽', name: 'balls', count: 5, answers: [6, 5, 4]),
    _CountingRound(emoji: '🐠', name: 'fish', count: 6, answers: [5, 7, 6]),
    _CountingRound(
      emoji: '\u{1F338}',
      name: 'flowers',
      count: 7,
      answers: [7, 6, 8],
    ),
    _CountingRound(
      emoji: '\u{1F697}',
      name: 'cars',
      count: 8,
      answers: [9, 8, 7],
    ),
    _CountingRound(
      emoji: '\u{1F9F8}',
      name: 'toys',
      count: 9,
      answers: [8, 10, 9],
    ),
    _CountingRound(
      emoji: '\u{1F388}',
      name: 'balloons',
      count: 10,
      answers: [10, 9, 8],
    ),
  ];

  static int get contentCount => _rounds.length;

  int _roundIndex = 0;
  int? _selectedAnswer;
  int _streak = 0;
  int _mistakes = 0;
  bool _roundSolved = false;
  bool _completionSent = false;

  _CountingRound get _round => _rounds[_roundIndex];
  bool get _isLastRound => _roundIndex == _rounds.length - 1;

  void _playFeedback(Future<void> Function(LetterAudioCue cue) action) {
    unawaited(action(widget.audioCue).catchError((Object _) {}));
  }

  void _chooseAnswer(int answer) {
    if (_roundSolved) return;

    final solved = answer == _round.count;
    setState(() {
      _selectedAnswer = answer;
      _roundSolved = solved;
      if (solved) {
        _streak += 1;
      } else {
        _streak = 0;
        _mistakes += 1;
      }
    });

    if (solved) {
      if (_isLastRound) {
        _playFeedback((cue) => cue.playWin());
        if (!_completionSent) {
          _completionSent = true;
          widget.onCompleted?.call();
        }
      } else {
        _playFeedback((cue) => cue.playReward());
      }
    } else {
      _playFeedback((cue) => cue.playInvalidAction());
    }
  }

  void _continue() {
    _playFeedback((cue) => cue.playTap());
    if (_isLastRound) {
      setState(() {
        _roundIndex = 0;
        _selectedAnswer = null;
        _streak = 0;
        _mistakes = 0;
        _roundSolved = false;
        _completionSent = false;
      });
      return;
    }

    setState(() {
      _roundIndex += 1;
      _selectedAnswer = null;
      _roundSolved = false;
    });
  }

  void _restart() {
    _playFeedback((cue) => cue.playRestart());
    setState(() {
      _roundIndex = 0;
      _selectedAnswer = null;
      _streak = 0;
      _mistakes = 0;
      _roundSolved = false;
      _completionSent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7055DB);
    final triedIncorrectly =
        _selectedAnswer != null && _selectedAnswer != _round.count;

    return LogicGameScaffold(
      title: 'Count & Choose',
      prompt: 'How many ${_round.name} can you see?',
      accentColor: accent,
      round: _roundIndex + 1,
      totalRounds: _rounds.length,
      statusLabel: 'Streak $_streak',
      statusIcon: Icons.local_fire_department_rounded,
      onRestart: _restart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            constraints: const BoxConstraints(minHeight: 190),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: _roundSolved
                    ? const Color(0xFF45B979)
                    : const Color(0xFFE7E0FF),
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  offset: Offset(0, 8),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: List.generate(
                  _round.count,
                  (index) => Semantics(
                    label: '${_round.name} ${index + 1}',
                    child: Text(
                      _round.emoji,
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(fontSize: 62, height: 1.15),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 14,
            children: _round.answers.map((answer) {
              final isSelected = _selectedAnswer == answer;
              final isCorrect = _roundSolved && answer == _round.count;
              final isIncorrect = isSelected && !_roundSolved;
              final background = isCorrect
                  ? const Color(0xFF36B86F)
                  : isIncorrect
                  ? const Color(0xFFFFC85A)
                  : Colors.white;
              final foreground = isCorrect
                  ? Colors.white
                  : const Color(0xFF443869);

              return Semantics(
                button: true,
                label: '$answer',
                selected: isSelected,
                child: SizedBox.square(
                  dimension: 88,
                  child: AnimatedScale(
                    scale: isSelected ? 1.06 : 1,
                    duration: const Duration(milliseconds: 160),
                    child: Material(
                      color: background,
                      elevation: isSelected ? 7 : 3,
                      shadowColor: accent.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(26),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(26),
                        onTap: () => _chooseAnswer(answer),
                        child: Center(
                          child: Text(
                            '$answer',
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: foreground,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          LogicFeedbackBanner(
            message: _roundSolved
                ? _isLastRound
                      ? 'Amazing! You counted every group with ${_starsForMistakes(_mistakes)} stars!'
                      : 'That’s right — ${_round.count}!'
                : triedIncorrectly
                ? 'Nice try! Touch each ${_round.name.substring(0, _round.name.length - (_round.name == 'fish' ? 0 : 1))} and count again.'
                : 'Touch each one, then choose a number.',
            tone: _roundSolved
                ? LogicFeedbackTone.success
                : triedIncorrectly
                ? LogicFeedbackTone.encouragement
                : LogicFeedbackTone.neutral,
          ),
          if (_roundSolved && _isLastRound) ...[
            const SizedBox(height: 12),
            LogicRunSummary(
              stars: _starsForMistakes(_mistakes),
              title: 'Counting quest complete',
              subtitle: _mistakes == 0
                  ? 'Perfect run. Try to keep all three stars.'
                  : 'Replay to improve your star run.',
              color: accent,
            ),
          ],
          if (_roundSolved) ...[
            const SizedBox(height: 16),
            LogicCompletionActions(
              isLastRound: _isLastRound,
              nextRoundLabel: 'Next group',
              replayLabel: 'Play again',
              color: accent,
              onContinue: _continue,
              onPlayNextGame: widget.onPlayNextGame,
              nextGameTitle: widget.nextGameTitle,
            ),
          ],
        ],
      ),
    );
  }

  int _starsForMistakes(int mistakes) {
    if (mistakes == 0) return 3;
    if (mistakes <= 2) return 2;
    return 1;
  }
}
