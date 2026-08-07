import 'package:flutter/material.dart';

import 'logic_game_ui.dart';

class PatternPuzzleGameScreen extends StatefulWidget {
  const PatternPuzzleGameScreen({super.key, this.onCompleted});

  final VoidCallback? onCompleted;

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
  ];

  int _roundIndex = 0;
  String? _selectedOption;
  bool _roundSolved = false;
  bool _completionSent = false;

  _PatternRound get _round => _rounds[_roundIndex];
  bool get _isLastRound => _roundIndex == _rounds.length - 1;

  void _choose(String option) {
    if (_roundSolved) return;

    final solved = option == _round.answer;
    setState(() {
      _selectedOption = option;
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
        _selectedOption = null;
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
                      ? 'Pattern champion! You solved them all!'
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
          if (_roundSolved) ...[
            const SizedBox(height: 16),
            LogicRoundButton(
              label: _isLastRound ? 'Play patterns again' : 'Next pattern',
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
