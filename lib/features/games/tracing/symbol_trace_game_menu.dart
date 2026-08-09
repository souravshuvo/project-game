import 'package:flutter/material.dart';

import '../../../core/audio/letter_audio_cue.dart';
import '../../tracing/domain/trace_definition.dart';
import '../../tracing/presentation/trace_screen.dart';
import '../shared/kid_celebration.dart';

@immutable
class TraceGameEntry {
  const TraceGameEntry({
    required this.id,
    required this.label,
    required this.definition,
    required this.accentColor,
    required this.secondaryColor,
  });

  final String id;
  final String label;
  final TraceDefinition definition;
  final Color accentColor;
  final Color secondaryColor;
}

class SymbolTraceGameMenu extends StatefulWidget {
  const SymbolTraceGameMenu({
    required this.title,
    required this.subtitle,
    required this.symbolKind,
    required this.entries,
    required this.audioCue,
    this.onCompleted,
    super.key,
  });

  final String title;
  final String subtitle;
  final String symbolKind;
  final List<TraceGameEntry> entries;
  final LetterAudioCue audioCue;
  final VoidCallback? onCompleted;

  @override
  State<SymbolTraceGameMenu> createState() => _SymbolTraceGameMenuState();
}

class _SymbolTraceGameMenuState extends State<SymbolTraceGameMenu> {
  final Set<String> _completedEntryIds = <String>{};
  bool _completionReported = false;

  Future<void> _openEntry(TraceGameEntry entry) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/games/trace/${entry.id}'),
        builder: (context) => SymbolTraceScreen(
          definition: entry.definition,
          symbolKind: widget.symbolKind,
          audioCue: widget.audioCue,
          accentColor: entry.accentColor,
          secondaryColor: entry.secondaryColor,
          onCompleted: () => _markEntryComplete(entry.id),
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void _markEntryComplete(String id) {
    if (!_completedEntryIds.add(id)) {
      return;
    }

    final completedAll = _completedEntryIds.length == widget.entries.length;
    if (mounted) {
      setState(() {});
    }

    if (completedAll && !_completionReported) {
      _completionReported = true;
      widget.onCompleted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = _completedEntryIds.length;
    final total = widget.entries.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF3D7), Color(0xFFECE8FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: 64,
                      child: IconButton.filledTonal(
                        tooltip: 'Back',
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back_rounded, size: 30),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: const Color(0xFF392C68),
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          Text(
                            widget.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF746A87),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(
                        minWidth: 66,
                        minHeight: 52,
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7257E8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        '$completed/$total',
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.white.withValues(alpha: 0.86),
                    color: const Color(0xFF25A97A),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  key: const ValueKey('trace-entry-grid'),
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 22),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240,
                    mainAxisExtent: 216,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: widget.entries.length,
                  itemBuilder: (context, index) {
                    final entry = widget.entries[index];
                    return _TraceEntryCard(
                      entry: entry,
                      completed: _completedEntryIds.contains(entry.id),
                      onPressed: () => _openEntry(entry),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TraceEntryCard extends StatelessWidget {
  const _TraceEntryCard({
    required this.entry,
    required this.completed,
    required this.onPressed,
  });

  final TraceGameEntry entry;
  final bool completed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: completed
          ? 'Trace ${entry.label}. Completed.'
          : 'Trace ${entry.label}.',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [entry.accentColor, entry.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: entry.accentColor.withValues(alpha: 0.22),
                offset: const Offset(0, 8),
                blurRadius: 16,
              ),
            ],
          ),
          child: InkWell(
            key: ValueKey('trace-entry-${entry.id}'),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: completed
                          ? const DecoratedBox(
                              key: ValueKey('complete'),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(7),
                                child: Icon(
                                  Icons.check_rounded,
                                  color: Color(0xFF24966C),
                                  size: 25,
                                ),
                              ),
                            )
                          : const Icon(
                              key: ValueKey('spark'),
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                    ),
                  ),
                  Center(
                    child: KidFloaty(
                      phase: entry.id.length * 0.07,
                      amplitude: 3,
                      sway: 2,
                      child: Text(
                        entry.label,
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 86,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Trace path',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
