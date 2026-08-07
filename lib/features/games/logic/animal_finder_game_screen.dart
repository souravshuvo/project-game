import 'package:flutter/material.dart';

import 'logic_game_ui.dart';

class AnimalFinderGameScreen extends StatefulWidget {
  const AnimalFinderGameScreen({super.key, this.onCompleted});

  final VoidCallback? onCompleted;

  @override
  State<AnimalFinderGameScreen> createState() =>
      _AnimalFinderGameScreenState();
}

class _AnimalChoice {
  const _AnimalChoice(this.name, this.emoji);

  final String name;
  final String emoji;
}

class _AnimalRound {
  const _AnimalRound({required this.target, required this.choices});

  final _AnimalChoice target;
  final List<_AnimalChoice> choices;
}

class _AnimalFinderGameScreenState extends State<AnimalFinderGameScreen> {
  static const _rounds = <_AnimalRound>[
    _AnimalRound(
      target: _AnimalChoice('lion', '🦁'),
      choices: [
        _AnimalChoice('lion', '🦁'),
        _AnimalChoice('rabbit', '🐰'),
        _AnimalChoice('frog', '🐸'),
        _AnimalChoice('panda', '🐼'),
        _AnimalChoice('monkey', '🐵'),
        _AnimalChoice('cow', '🐮'),
      ],
    ),
    _AnimalRound(
      target: _AnimalChoice('elephant', '🐘'),
      choices: [
        _AnimalChoice('giraffe', '🦒'),
        _AnimalChoice('dog', '🐶'),
        _AnimalChoice('elephant', '🐘'),
        _AnimalChoice('fox', '🦊'),
        _AnimalChoice('zebra', '🦓'),
        _AnimalChoice('pig', '🐷'),
      ],
    ),
    _AnimalRound(
      target: _AnimalChoice('penguin', '🐧'),
      choices: [
        _AnimalChoice('owl', '🦉'),
        _AnimalChoice('chicken', '🐔'),
        _AnimalChoice('duck', '🦆'),
        _AnimalChoice('penguin', '🐧'),
        _AnimalChoice('eagle', '🦅'),
        _AnimalChoice('parrot', '🦜'),
      ],
    ),
    _AnimalRound(
      target: _AnimalChoice('dolphin', '🐬'),
      choices: [
        _AnimalChoice('fish', '🐠'),
        _AnimalChoice('octopus', '🐙'),
        _AnimalChoice('turtle', '🐢'),
        _AnimalChoice('whale', '🐳'),
        _AnimalChoice('dolphin', '🐬'),
        _AnimalChoice('crab', '🦀'),
      ],
    ),
    _AnimalRound(
      target: _AnimalChoice('tiger', '🐯'),
      choices: [
        _AnimalChoice('koala', '🐨'),
        _AnimalChoice('tiger', '🐯'),
        _AnimalChoice('bear', '🐻'),
        _AnimalChoice('mouse', '🐭'),
        _AnimalChoice('cat', '🐱'),
        _AnimalChoice('hippo', '🦛'),
      ],
    ),
  ];

  int _roundIndex = 0;
  String? _lastChoiceName;
  bool _roundSolved = false;
  bool _completionSent = false;

  _AnimalRound get _round => _rounds[_roundIndex];
  bool get _isLastRound => _roundIndex == _rounds.length - 1;

  void _choose(_AnimalChoice choice) {
    if (_roundSolved) return;

    final solved = choice.name == _round.target.name;
    setState(() {
      _lastChoiceName = choice.name;
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
        _lastChoiceName = null;
        _roundSolved = false;
        _completionSent = false;
      });
      return;
    }

    setState(() {
      _roundIndex += 1;
      _lastChoiceName = null;
      _roundSolved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF16A687);
    final madeWrongChoice = _lastChoiceName != null && !_roundSolved;

    return LogicGameScaffold(
      title: 'Animal Finder',
      prompt: 'Can you find the ${_round.target.name}?',
      accentColor: accent,
      round: _roundIndex + 1,
      totalRounds: _rounds.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(minWidth: 190, minHeight: 112),
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE1F7F1),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFF8AD9C8), width: 3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _round.target.emoji,
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    _round.target.name.toUpperCase(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      color: Color(0xFF267866),
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = constraints.maxWidth >= 600
                  ? 150.0
                  : constraints.maxWidth >= 380
                  ? (constraints.maxWidth - 28) / 3
                  : (constraints.maxWidth - 14) / 2;

              return Wrap(
                alignment: WrapAlignment.center,
                spacing: 14,
                runSpacing: 14,
                children: _round.choices.map((choice) {
                  final selected = _lastChoiceName == choice.name;
                  final correct =
                      _roundSolved && choice.name == _round.target.name;
                  final incorrect = selected && !_roundSolved;

                  return Semantics(
                    button: true,
                    label: choice.name,
                    selected: selected,
                    child: SizedBox(
                      width: tileWidth,
                      height: 112,
                      child: AnimatedScale(
                        scale: selected ? 1.05 : 1,
                        duration: const Duration(milliseconds: 170),
                        child: Material(
                          color: correct
                              ? const Color(0xFFC9F3DE)
                              : incorrect
                              ? const Color(0xFFFFE3A8)
                              : Colors.white,
                          elevation: selected ? 7 : 3,
                          borderRadius: BorderRadius.circular(27),
                          shadowColor: accent.withValues(alpha: 0.2),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(27),
                            onTap: () => _choose(choice),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  choice.emoji,
                                  textScaler: TextScaler.noScaling,
                                  style: const TextStyle(fontSize: 62),
                                ),
                                if (correct)
                                  const Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF25975F),
                                      size: 28,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          LogicFeedbackBanner(
            message: _roundSolved
                ? _isLastRound
                      ? 'You found every animal — fantastic!'
                      : 'You found the ${_round.target.name}!'
                : madeWrongChoice
                ? 'That animal is lovely too. Look again for the ${_round.target.name}!'
                : 'Look carefully, then tap the matching animal.',
            tone: _roundSolved
                ? LogicFeedbackTone.success
                : madeWrongChoice
                ? LogicFeedbackTone.encouragement
                : LogicFeedbackTone.neutral,
          ),
          if (_roundSolved) ...[
            const SizedBox(height: 16),
            LogicRoundButton(
              label: _isLastRound ? 'Find them again' : 'Next animal',
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
