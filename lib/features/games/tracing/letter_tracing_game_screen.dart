import 'package:flutter/material.dart';

import '../../../core/analytics/game_analytics.dart';
import '../../../core/audio/letter_audio_cue.dart';
import '../../tracing/data/progress_repository.dart';
import '../../tracing/domain/trace_definition.dart';
import 'symbol_trace_game_menu.dart';

class LetterTracingGameScreen extends StatelessWidget {
  const LetterTracingGameScreen({
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
        _letter('A', TraceDefinition.uppercaseA(), 0),
        _letter('B', TraceDefinition.uppercaseB(), 1),
        _letter('C', TraceDefinition.uppercaseC(), 2),
        _letter('D', TraceDefinition.uppercaseD(), 3),
        _letter('E', TraceDefinition.uppercaseE(), 4),
        _letter('F', TraceDefinition.uppercaseF(), 5),
        _letter('G', TraceDefinition.uppercaseG(), 6),
        _letter('H', TraceDefinition.uppercaseH(), 7),
        _letter('I', TraceDefinition.uppercaseI(), 8),
        _letter('J', TraceDefinition.uppercaseJ(), 9),
        _letter('K', TraceDefinition.uppercaseK(), 10),
        _letter('L', TraceDefinition.uppercaseL(), 11),
        _letter('M', TraceDefinition.uppercaseM(), 12),
        _letter('N', TraceDefinition.uppercaseN(), 13),
        _letter('O', TraceDefinition.uppercaseO(), 14),
        _letter('P', TraceDefinition.uppercaseP(), 15),
        _letter('Q', TraceDefinition.uppercaseQ(), 16),
        _letter('R', TraceDefinition.uppercaseR(), 17),
        _letter('S', TraceDefinition.uppercaseS(), 18),
        _letter('T', TraceDefinition.uppercaseT(), 19),
        _letter('U', TraceDefinition.uppercaseU(), 20),
        _letter('V', TraceDefinition.uppercaseV(), 21),
        _letter('W', TraceDefinition.uppercaseW(), 22),
        _letter('X', TraceDefinition.uppercaseX(), 23),
        _letter('Y', TraceDefinition.uppercaseY(), 24),
        _letter('Z', TraceDefinition.uppercaseZ(), 25),
      ]);

  static int get contentCount => entries.length;

  @override
  Widget build(BuildContext context) {
    return SymbolTraceGameMenu(
      title: 'Letter Tracing',
      subtitle: 'Trace A to Z',
      symbolKind: 'Letter',
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

  static TraceGameEntry _letter(
    String label,
    TraceDefinition definition,
    int index,
  ) {
    const colors = <(Color, Color)>[
      (Color(0xFF7257E8), Color(0xFF9A7CF6)),
      (Color(0xFFEF5DA8), Color(0xFFFF8DC7)),
      (Color(0xFF2CB9A0), Color(0xFF65D5B7)),
      (Color(0xFFEC6F66), Color(0xFFFF9B72)),
      (Color(0xFF3F8FEF), Color(0xFF67B8F7)),
      (Color(0xFFF0A63A), Color(0xFFFFD165)),
    ];
    final (accent, secondary) = colors[index % colors.length];
    return TraceGameEntry(
      id: 'letter-${label.toLowerCase()}',
      label: label,
      definition: definition,
      accentColor: accent,
      secondaryColor: secondary,
    );
  }
}
