import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/letter_audio_cue.dart';
import 'logic_game_ui.dart';

class PatternPuzzleGameScreen extends StatefulWidget {
  const PatternPuzzleGameScreen({
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

  static int get contentCount => _PatternPuzzleGameScreenState.contentCount;

  @override
  State<PatternPuzzleGameScreen> createState() =>
      _PatternPuzzleGameScreenState();
}

class _PatternRound {
  const _PatternRound({
    required this.sequence,
    required this.answer,
    required this.options,
    required this.hint,
  });

  final List<String> sequence;
  final String answer;
  final List<String> options;
  final String hint;
}

class _PatternPuzzleGameScreenState extends State<PatternPuzzleGameScreen> {
  static const _rounds = <_PatternRound>[
    _PatternRound(
      sequence: ['🔴', '🔵', '🔴', '🔵', '🔴'],
      answer: '🔵',
      options: ['🟢', '🔵', '🔴'],
      hint: 'Red, blue, red, blue…',
    ),
    _PatternRound(
      sequence: ['⭐', '⭐', '🌙', '⭐', '⭐'],
      answer: '🌙',
      options: ['⭐', '☀️', '🌙'],
      hint: 'Two stars, then one moon…',
    ),
    _PatternRound(
      sequence: ['🍎', '🍌', '🍇', '🍎', '🍌'],
      answer: '🍇',
      options: ['🍌', '🍇', '🍎'],
      hint: 'Apple, banana, grapes…',
    ),
    _PatternRound(
      sequence: ['🐟', '🐢', '🐢', '🐟', '🐢'],
      answer: '🐢',
      options: ['🐟', '🐢', '🐙'],
      hint: 'One fish, then two turtles…',
    ),
    _PatternRound(
      sequence: ['🟨', '🟩', '🟨', '🟨', '🟩'],
      answer: '🟨',
      options: ['🟩', '🟦', '🟨'],
      hint: 'Yellow, green, yellow…',
    ),
    _PatternRound(
      sequence: [
        '\u{1F43E}',
        '\u{1F33F}',
        '\u{1F43E}',
        '\u{1F33F}',
        '\u{1F43E}',
      ],
      answer: '\u{1F33F}',
      options: ['\u{1F33F}', '\u{1F43E}', '\u{1F337}'],
      hint: 'Paw, leaf, paw, leaf…',
    ),
    _PatternRound(
      sequence: [
        '\u{1F534}',
        '\u{1F534}',
        '\u{1F535}',
        '\u{1F535}',
        '\u{1F534}',
      ],
      answer: '\u{1F534}',
      options: ['\u{1F535}', '\u{1F7E2}', '\u{1F534}'],
      hint: 'Two red, two blue…',
    ),
    _PatternRound(
      sequence: [
        '\u{1F34E}',
        '\u{1F34C}',
        '\u{1F34C}',
        '\u{1F34E}',
        '\u{1F34C}',
      ],
      answer: '\u{1F34C}',
      options: ['\u{1F34E}', '\u{1F347}', '\u{1F34C}'],
      hint: 'Apple, two bananas…',
    ),
    _PatternRound(
      sequence: [
        '\u{1F31E}',
        '\u{1F319}',
        '\u{1F31F}',
        '\u{1F31E}',
        '\u{1F319}',
      ],
      answer: '\u{1F31F}',
      options: ['\u{1F319}', '\u{1F31F}', '\u{2601}\u{FE0F}'],
      hint: 'Sun, moon, star…',
    ),
    _PatternRound(
      sequence: [
        '\u{1F697}',
        '\u{1F697}',
        '\u{1F6B2}',
        '\u{1F697}',
        '\u{1F697}',
      ],
      answer: '\u{1F6B2}',
      options: ['\u{1F697}', '\u{1F6B2}', '\u{1F68C}'],
      hint: 'Two cars, then one bike…',
    ),
  ];

  static int get contentCount => _rounds.length;

  int _roundIndex = 0;
  String? _selectedOption;
  int _streak = 0;
  int _mistakes = 0;
  bool _roundSolved = false;
  bool _completionSent = false;

  _PatternRound get _round => _rounds[_roundIndex];
  bool get _isLastRound => _roundIndex == _rounds.length - 1;

  void _playFeedback(Future<void> Function(LetterAudioCue cue) action) {
    unawaited(action(widget.audioCue).catchError((Object _) {}));
  }

  void _choose(String option) {
    if (_roundSolved) return;

    final solved = option == _round.answer;
    setState(() {
      _selectedOption = option;
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
        _selectedOption = null;
        _streak = 0;
        _mistakes = 0;
        _roundSolved = false;
        _completionSent = false;
      });
      return;
    }

    setState(() {
      _roundIndex += 1;
      _selectedOption = null;
      _roundSolved = false;
    });
  }

  void _restart() {
    _playFeedback((cue) => cue.playRestart());
    setState(() {
      _roundIndex = 0;
      _selectedOption = null;
      _streak = 0;
      _mistakes = 0;
      _roundSolved = false;
      _completionSent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFF08B35);
    final madeWrongChoice = _selectedOption != null && !_roundSolved;

    return LogicGameScaffold(
      title: 'Pattern Puzzle',
      prompt: 'What comes next?',
      accentColor: accent,
      round: _roundIndex + 1,
      totalRounds: _rounds.length,
      statusLabel: 'Streak $_streak',
      statusIcon: Icons.local_fire_department_rounded,
      onRestart: _restart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFFFDAB9), width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  offset: Offset(0, 7),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._round.sequence.map(
                      (symbol) => _PatternCell(symbol: symbol),
                    ),
                    _PatternCell(
                      symbol: _roundSolved ? _round.answer : '?',
                      isAnswer: true,
                      solved: _roundSolved,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _round.hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF746B81),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 14,
            children: _round.options.map((option) {
              final selected = _selectedOption == option;
              final correct = _roundSolved && option == _round.answer;
              final incorrect = selected && !_roundSolved;

              return Semantics(
                button: true,
                label: 'Choose $option',
                selected: selected,
                child: SizedBox.square(
                  dimension: 94,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 160),
                    scale: selected ? 1.07 : 1,
                    child: Material(
                      color: correct
                          ? const Color(0xFFCFF3DA)
                          : incorrect
                          ? const Color(0xFFFFE4AE)
                          : Colors.white,
                      elevation: selected ? 7 : 3,
                      borderRadius: BorderRadius.circular(28),
                      shadowColor: accent.withValues(alpha: 0.23),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: () => _choose(option),
                        child: Center(
                          child: Text(
                            option,
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(fontSize: 49),
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
                      ? 'Pattern champion! ${_starsForMistakes(_mistakes)} star run!'
                      : 'Yes! The pattern keeps going.'
                : madeWrongChoice
                ? 'Almost! Say the pattern slowly and try again.'
                : 'Look for what repeats, then choose.',
            tone: _roundSolved
                ? LogicFeedbackTone.success
                : madeWrongChoice
                ? LogicFeedbackTone.encouragement
                : LogicFeedbackTone.neutral,
          ),
          if (_roundSolved && _isLastRound) ...[
            const SizedBox(height: 12),
            LogicRunSummary(
              stars: _starsForMistakes(_mistakes),
              title: 'Pattern path complete',
              subtitle: _mistakes == 0
                  ? 'Perfect pattern run.'
                  : 'Replay to chase a cleaner pattern streak.',
              color: accent,
            ),
          ],
          if (_roundSolved) ...[
            const SizedBox(height: 16),
            LogicCompletionActions(
              isLastRound: _isLastRound,
              nextRoundLabel: 'Next pattern',
              replayLabel: 'Play patterns again',
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

class _PatternCell extends StatelessWidget {
  const _PatternCell({
    required this.symbol,
    this.isAnswer = false,
    this.solved = false,
  });

  final String symbol;
  final bool isAnswer;
  final bool solved;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 72,
      height: 78,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isAnswer
            ? solved
                  ? const Color(0xFFDCF5E5)
                  : const Color(0xFFFFF1D7)
            : const Color(0xFFF7F3FC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isAnswer
              ? solved
                    ? const Color(0xFF4CB978)
                    : const Color(0xFFF0A352)
              : const Color(0xFFE9E1F2),
          width: isAnswer ? 3 : 2,
        ),
      ),
      child: Text(
        symbol,
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          color: const Color(0xFFE3842F),
          fontSize: symbol == '?' ? 42 : 37,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
