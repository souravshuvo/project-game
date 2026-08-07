import 'package:flutter/material.dart';

import 'logic_game_ui.dart';

class CountingGameScreen extends StatefulWidget {
  const CountingGameScreen({super.key, this.onCompleted});

  final VoidCallback? onCompleted;

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
      emoji: '⭐',
      name: 'stars',
      count: 2,
      answers: [1, 2, 3],
    ),
    _CountingRound(
      emoji: '🐥',
      name: 'ducklings',
      count: 3,
      answers: [4, 2, 3],
    ),
    _CountingRound(
      emoji: '🍎',
      name: 'apples',
      count: 4,
      answers: [4, 5, 3],
    ),
    _CountingRound(
      emoji: '⚽',
      name: 'balls',
      count: 5,
      answers: [6, 5, 4],
    ),
    _CountingRound(
      emoji: '🐠',
      name: 'fish',
      count: 6,
      answers: [5, 7, 6],
    ),
  ];

  int _roundIndex = 0;
  int? _selectedAnswer;
  bool _roundSolved = false;
  bool _completionSent = false;

  _CountingRound get _round => _rounds[_roundIndex];
  bool get _isLastRound => _roundIndex == _rounds.length - 1;

  void _chooseAnswer(int answer) {
    if (_roundSolved) return;

    final solved = answer == _round.count;
    setState(() {
      _selectedAnswer = answer;
      _roundSolved = solved;
    });

    if (solved && _isLastRound && !_completionSent) {
      _completionSent = true;
      widget.onCompleted?.call();
    }
  }

  void _continue() {
    if (_isLastRound) {
      setState(() {
        _roundIndex = 0;
        _selectedAnswer = null;
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
                      ? 'Amazing! You counted every group!'
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
          if (_roundSolved) ...[
            const SizedBox(height: 16),
            LogicRoundButton(
              label: _isLastRound ? 'Play again' : 'Next group',
              color: accent,
              icon: _isLastRound
                  ? Icons.replay_rounded
                  : Icons.arrow_forward_rounded,
              onPressed: _continue,
            ),
          ],
        ],
      ),
    );
  }
}
