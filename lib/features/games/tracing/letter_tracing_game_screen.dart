import 'package:flutter/material.dart';

import '../../../core/audio/letter_audio_cue.dart';
import '../../tracing/domain/trace_definition.dart';
import 'symbol_trace_game_menu.dart';

class LetterTracingGameScreen extends StatelessWidget {
  const LetterTracingGameScreen({
    required this.audioCue,
    this.onCompleted,
    super.key,
  });

  final LetterAudioCue audioCue;
  final VoidCallback? onCompleted;

  static final List<TraceGameEntry> _entries = <TraceGameEntry>[
    TraceGameEntry(
      id: 'letter-a',
      label: 'A',
      definition: TraceDefinition.uppercaseA(),
      accentColor: const Color(0xFF7257E8),
      secondaryColor: const Color(0xFF9A7CF6),
    ),
    TraceGameEntry(
      id: 'letter-b',
      label: 'B',
      definition: TraceDefinition.uppercaseB(),
      accentColor: const Color(0xFFEF5DA8),
      secondaryColor: const Color(0xFFFF8DC7),
    ),
    TraceGameEntry(
      id: 'letter-c',
      label: 'C',
      definition: TraceDefinition.uppercaseC(),
      accentColor: const Color(0xFF2CB9A0),
      secondaryColor: const Color(0xFF65D5B7),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SymbolTraceGameMenu(
      title: 'Letter Tracing',
      subtitle: 'Trace A, B, and C',
      symbolKind: 'Letter',
      entries: _entries,
      audioCue: audioCue,
      onCompleted: onCompleted,
    );
  }
}
