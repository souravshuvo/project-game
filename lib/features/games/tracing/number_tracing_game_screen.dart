import 'package:flutter/material.dart';

import '../../../core/analytics/game_analytics.dart';
import '../../../core/audio/letter_audio_cue.dart';
import '../../tracing/data/progress_repository.dart';
import '../../tracing/domain/trace_definition.dart';
import 'symbol_trace_game_menu.dart';

class NumberTracingGameScreen extends StatelessWidget {
  const NumberTracingGameScreen({
    required this.audioCue,
    required this.progressRepository,
    required this.gameId,
    required this.analytics,
    this.onCompleted,
    this.onPlayNextGame,
    this.nextGameTitle,
    super.key,
  });

  final LetterAudioCue audioCue;
  final ProgressRepository progressRepository;
  final String gameId;
  final GameAnalytics analytics;
  final VoidCallback? onCompleted;
  final VoidCallback? onPlayNextGame;
  final String? nextGameTitle;

  static final List<TraceGameEntry> entries =
      List.unmodifiable(<TraceGameEntry>[
        _number('1', TraceDefinition.numberOne(), 0),
        _number('2', TraceDefinition.numberTwo(), 1),
        _number('3', TraceDefinition.numberThree(), 2),
        _number('4', TraceDefinition.numberFour(), 3),
        _number('5', TraceDefinition.numberFive(), 4),
        _number('6', TraceDefinition.numberSix(), 5),
        _number('7', TraceDefinition.numberSeven(), 6),
        _number('8', TraceDefinition.numberEight(), 7),
        _number('9', TraceDefinition.numberNine(), 8),
        _number('10', TraceDefinition.numberTen(), 9),
      ]);

  static int get contentCount => entries.length;

  @override
  Widget build(BuildContext context) {
    return SymbolTraceGameMenu(
      title: 'Number Tracing',
      subtitle: 'Trace 1 to 10',
      symbolKind: 'Number',
      gameId: gameId,
      entries: entries,
      audioCue: audioCue,
      progressRepository: progressRepository,
      analytics: analytics,
      difficultyTier: 'easy',
      onCompleted: onCompleted,
      onPlayNextGame: onPlayNextGame,
      nextGameTitle: nextGameTitle,
    );
  }

  static TraceGameEntry _number(
    String label,
    TraceDefinition definition,
    int index,
  ) {
    const colors = <(Color, Color)>[
      (Color(0xFFEC6F66), Color(0xFFFF9B72)),
      (Color(0xFF35A7FF), Color(0xFF67C8FF)),
      (Color(0xFFF0A63A), Color(0xFFFFD165)),
      (Color(0xFF7257E8), Color(0xFF9A7CF6)),
      (Color(0xFF2CB9A0), Color(0xFF65D5B7)),
    ];
    final (accent, secondary) = colors[index % colors.length];
    return TraceGameEntry(
      id: 'number-$label',
      label: label,
      definition: definition,
      accentColor: accent,
      secondaryColor: secondary,
    );
  }
}
