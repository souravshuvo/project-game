import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/analytics/game_analytics.dart';
import '../../../core/audio/letter_audio_cue.dart';
import '../../tracing/data/progress_repository.dart';
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
    required this.gameId,
    required this.entries,
    required this.audioCue,
    required this.progressRepository,
    required this.analytics,
    required this.difficultyTier,
    this.onCompleted,
    this.onPlayNextGame,
    this.nextGameTitle,
    super.key,
  });

  final String title;
  final String subtitle;
  final String symbolKind;
  final String gameId;
  final List<TraceGameEntry> entries;
  final LetterAudioCue audioCue;
  final ProgressRepository progressRepository;
  final GameAnalytics analytics;
  final String difficultyTier;
  final VoidCallback? onCompleted;
  final VoidCallback? onPlayNextGame;
  final String? nextGameTitle;

  @override
  State<SymbolTraceGameMenu> createState() => _SymbolTraceGameMenuState();
}

class _SymbolTraceGameMenuState extends State<SymbolTraceGameMenu> {
  late Set<String> _completedEntryIds;
  final Map<String, DateTime> _contentStartedAt = <String, DateTime>{};
  bool _completionReported = false;

  @override
  void initState() {
    super.initState();
    _completedEntryIds = _savedEntryIds();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportCompletionIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant SymbolTraceGameMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameId != widget.gameId ||
        oldWidget.entries.length != widget.entries.length) {
      _completedEntryIds = _savedEntryIds();
      _completionReported = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _reportCompletionIfNeeded();
      });
    }
  }

  Future<void> _openEntry(TraceGameEntry entry) async {
    unawaited(widget.audioCue.playTap().catchError((Object _) {}));
    final entryIndex = _entryIndex(entry.id);
    final nextEntry = _nextEntryAfterCompleting(entry.id);
    _contentStartedAt[entry.id] = DateTime.now();
    widget.analytics.contentStarted(
      gameId: widget.gameId,
      contentId: entry.id,
      contentIndex: entryIndex,
      contentTotal: widget.entries.length,
      difficultyTier: widget.difficultyTier,
    );
    final result = await Navigator.of(context).push<_TraceRouteAction>(
      MaterialPageRoute<_TraceRouteAction>(
        settings: RouteSettings(name: '/games/trace/${entry.id}'),
        builder: (context) => SymbolTraceScreen(
          definition: entry.definition,
          symbolKind: widget.symbolKind,
          audioCue: widget.audioCue,
          accentColor: entry.accentColor,
          secondaryColor: entry.secondaryColor,
          nextSymbolLabel: nextEntry?.label ?? widget.nextGameTitle,
          onPlayNext: nextEntry != null
              ? () => Navigator.of(context).pop(_TraceRouteAction.playNext)
              : widget.onPlayNextGame == null
              ? null
              : () => Navigator.of(context).pop(_TraceRouteAction.playNextGame),
          onCompleted: () => _markEntryComplete(entry.id),
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }

    if (mounted && result == _TraceRouteAction.playNext && nextEntry != null) {
      await _openEntry(nextEntry);
    }

    if (mounted && result == _TraceRouteAction.playNextGame) {
      widget.onPlayNextGame?.call();
    }
  }

  void _markEntryComplete(String id) {
    if (!_completedEntryIds.add(id)) {
      return;
    }
    final startedAt = _contentStartedAt.remove(id);
    widget.analytics.contentCompleted(
      gameId: widget.gameId,
      contentId: id,
      contentIndex: _entryIndex(id),
      contentTotal: widget.entries.length,
      difficultyTier: widget.difficultyTier,
      durationMs: startedAt == null
          ? null
          : DateTime.now().difference(startedAt).inMilliseconds,
    );
    unawaited(
      widget.progressRepository
          .markContentComplete(widget.gameId, id)
          .catchError((Object _) {}),
    );

    if (mounted) {
      setState(() {});
    }

    _reportCompletionIfNeeded();
  }

  int _entryIndex(String id) {
    final index = widget.entries.indexWhere((entry) => entry.id == id);
    return index < 0 ? 0 : index + 1;
  }

  Set<String> _savedEntryIds() {
    final knownIds = widget.entries.map((entry) => entry.id).toSet();
    return widget.progressRepository
        .completedContentIds(widget.gameId)
        .where(knownIds.contains)
        .toSet();
  }

  void _reportCompletionIfNeeded() {
    if (!mounted ||
        _completionReported ||
        _completedEntryIds.length != widget.entries.length) {
      return;
    }
    _completionReported = true;
    widget.onCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final completed = _completedEntryIds.length;
    final total = widget.entries.length;
    final progress = total == 0 ? 0.0 : completed / total;
    final nextEntry = _nextEntry();

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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _TraceMissionPanel(
                  entry: nextEntry,
                  symbolKind: widget.symbolKind,
                  completed: completed,
                  total: total,
                  onPressed: () => _openEntry(nextEntry),
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

  TraceGameEntry _nextEntry() {
    return widget.entries.firstWhere(
      (entry) => !_completedEntryIds.contains(entry.id),
      orElse: () => widget.entries.first,
    );
  }

  TraceGameEntry? _nextEntryAfterCompleting(String completedId) {
    final completedAfterThis = <String>{..._completedEntryIds, completedId};
    for (final entry in widget.entries) {
      if (!completedAfterThis.contains(entry.id)) {
        return entry;
      }
    }
    return null;
  }
}

enum _TraceRouteAction { playNext, playNextGame }

class _TraceMissionPanel extends StatelessWidget {
  const _TraceMissionPanel({
    required this.entry,
    required this.symbolKind,
    required this.completed,
    required this.total,
    required this.onPressed,
  });

  final TraceGameEntry entry;
  final String symbolKind;
  final int completed;
  final int total;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final allDone = total > 0 && completed >= total;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: entry.accentColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [entry.accentColor, entry.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: SizedBox.square(
              dimension: 58,
              child: Center(
                child: Text(
                  entry.label,
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allDone ? 'Replay challenge' : 'Trace next',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF392C68),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  allDone
                      ? 'Practice your favorite $symbolKind again.'
                      : '$completed/$total complete. Start at ${entry.label}.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF746A87),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox.square(
            dimension: 58,
            child: IconButton.filled(
              tooltip: allDone ? 'Replay trace' : 'Trace next',
              onPressed: onPressed,
              style: IconButton.styleFrom(
                backgroundColor: entry.accentColor,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 30),
            ),
          ),
        ],
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
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      completed ? 'Replay path' : 'Trace path',
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
          ),
        ),
      ),
    );
  }
}
