import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/letter_audio_cue.dart';
import 'logic_game_ui.dart';

class AnimalFinderGameScreen extends StatefulWidget {
  const AnimalFinderGameScreen({
    required this.audioCue,
    super.key,
    this.onCompleted,
  });

  final LetterAudioCue audioCue;
  final VoidCallback? onCompleted;

  static int get contentCount => _AnimalFinderGameScreenState.contentCount;

  @override
  State<AnimalFinderGameScreen> createState() => _AnimalFinderGameScreenState();
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
    _AnimalRound(
      target: _AnimalChoice('bee', '\u{1F41D}'),
      choices: [
        _AnimalChoice('butterfly', '\u{1F98B}'),
        _AnimalChoice('bee', '\u{1F41D}'),
        _AnimalChoice('ladybug', '\u{1F41E}'),
        _AnimalChoice('snail', '\u{1F40C}'),
        _AnimalChoice('ant', '\u{1F41C}'),
        _AnimalChoice('worm', '\u{1FAB1}'),
      ],
    ),
    _AnimalRound(
      target: _AnimalChoice('horse', '\u{1F434}'),
      choices: [
        _AnimalChoice('goat', '\u{1F410}'),
        _AnimalChoice('sheep', '\u{1F411}'),
        _AnimalChoice('horse', '\u{1F434}'),
        _AnimalChoice('cow', '\u{1F42E}'),
        _AnimalChoice('pig', '\u{1F437}'),
        _AnimalChoice('dog', '\u{1F436}'),
      ],
    ),
    _AnimalRound(
      target: _AnimalChoice('shark', '\u{1F988}'),
      choices: [
        _AnimalChoice('whale', '\u{1F433}'),
        _AnimalChoice('fish', '\u{1F420}'),
        _AnimalChoice('dolphin', '\u{1F42C}'),
        _AnimalChoice('crab', '\u{1F980}'),
        _AnimalChoice('shark', '\u{1F988}'),
        _AnimalChoice('turtle', '\u{1F422}'),
      ],
    ),
    _AnimalRound(
      target: _AnimalChoice('kangaroo', '\u{1F998}'),
      choices: [
        _AnimalChoice('deer', '\u{1F98C}'),
        _AnimalChoice('llama', '\u{1F999}'),
        _AnimalChoice('camel', '\u{1F42A}'),
        _AnimalChoice('kangaroo', '\u{1F998}'),
        _AnimalChoice('sloth', '\u{1F9A5}'),
        _AnimalChoice('otter', '\u{1F9A6}'),
      ],
    ),
    _AnimalRound(
      target: _AnimalChoice('unicorn', '\u{1F984}'),
      choices: [
        _AnimalChoice('horse', '\u{1F434}'),
        _AnimalChoice('unicorn', '\u{1F984}'),
        _AnimalChoice('dragon', '\u{1F409}'),
        _AnimalChoice('dinosaur', '\u{1F995}'),
        _AnimalChoice('swan', '\u{1F9A2}'),
        _AnimalChoice('flamingo', '\u{1F9A9}'),
      ],
    ),
  ];

  static int get contentCount => _rounds.length;

  int _roundIndex = 0;
  String? _lastChoiceName;
  bool _roundSolved = false;
  bool _completionSent = false;

  _AnimalRound get _round => _rounds[_roundIndex];
  bool get _isLastRound => _roundIndex == _rounds.length - 1;

  void _playFeedback(Future<void> Function(LetterAudioCue cue) action) {
    unawaited(action(widget.audioCue).catchError((Object _) {}));
  }

  void _choose(_AnimalChoice choice) {
    if (_roundSolved) return;

    final solved = choice.name == _round.target.name;
    setState(() {
      _lastChoiceName = choice.name;
      _roundSolved = solved;
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

  void _restart() {
    _playFeedback((cue) => cue.playRestart());
    setState(() {
      _roundIndex = 0;
      _lastChoiceName = null;
      _roundSolved = false;
      _completionSent = false;
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
      onRestart: _restart,
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
