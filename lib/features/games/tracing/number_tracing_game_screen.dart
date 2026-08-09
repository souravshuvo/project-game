import 'package:flutter/material.dart';

import '../../../core/audio/letter_audio_cue.dart';
import '../../tracing/domain/trace_definition.dart';
import 'symbol_trace_game_menu.dart';

class NumberTracingGameScreen extends StatelessWidget {
  const NumberTracingGameScreen({
    required this.audioCue,
    this.onCompleted,
    super.key,
  });

  final LetterAudioCue audioCue;
  final VoidCallback? onCompleted;

  static final List<TraceGameEntry> _entries = <TraceGameEntry>[
    TraceGameEntry(
      id: 'number-1',
      label: '1',
      definition: TraceDefinition.numberOne(),
      accentColor: const Color(0xFFEC6F66),
      secondaryColor: const Color(0xFFFF9B72),
    ),
    TraceGameEntry(
      id: 'number-2',
      label: '2',
      definition: TraceDefinition.numberTwo(),
      accentColor: const Color(0xFF35A7FF),
      secondaryColor: const Color(0xFF67C8FF),
    ),
    TraceGameEntry(
      id: 'number-3',
      label: '3',
      definition: TraceDefinition.numberThree(),
      accentColor: const Color(0xFFF0A63A),
      secondaryColor: const Color(0xFFFFD165),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SymbolTraceGameMenu(
      title: 'Number Tracing',
      subtitle: 'Trace 1, 2, and 3',
      symbolKind: 'Number',
      entries: _entries,
      audioCue: audioCue,
      onCompleted: onCompleted,
    );
  }
}
