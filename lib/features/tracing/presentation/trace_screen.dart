import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/letter_audio_cue.dart';
import '../application/trace_controller.dart';
import '../data/progress_repository.dart';
import '../domain/trace_definition.dart';
import 'trace_painter.dart';

typedef TraceCompletionCallback = FutureOr<void> Function();

/// Backwards-compatible letter-A activity used by the original MVP shell.
///
/// New catalog games use [SymbolTraceScreen] directly, but keeping this
/// wrapper means existing routes, persistence, keys, and widget tests continue
/// to work unchanged.
class TraceScreen extends StatelessWidget {
  const TraceScreen({
    required this.progressRepository,
    required this.audioCue,
    super.key,
  });

  final ProgressRepository progressRepository;
  final LetterAudioCue audioCue;

  @override
  Widget build(BuildContext context) {
    return SymbolTraceScreen(
      definition: TraceDefinition.uppercaseA(),
      symbolKind: 'Letter',
      audioCue: audioCue,
      onCompleted: () async {
        if (progressRepository.isLetterAComplete) {
          return;
        }
        await progressRepository.markLetterAComplete();
      },
    );
  }
}

/// Reusable, offline tracing experience for one letter or number definition.
///
/// Geometry comes entirely from [definition]. [header] can contain a catalog
/// selector, while all guidance, progress, semantics, and celebration labels
/// adapt to the selected symbol.
class SymbolTraceScreen extends StatefulWidget {
  const SymbolTraceScreen({
    required this.definition,
    required this.symbolKind,
    this.audioCue,
    this.onCompleted,
    this.header,
    this.accentColor = const Color(0xFF7257E8),
    this.secondaryColor = const Color(0xFFFFA62B),
    super.key,
  });

  final TraceDefinition definition;
  final String symbolKind;
  final LetterAudioCue? audioCue;
  final TraceCompletionCallback? onCompleted;
  final Widget? header;
  final Color accentColor;
  final Color secondaryColor;

  @override
  State<SymbolTraceScreen> createState() => _SymbolTraceScreenState();
}

class _SymbolTraceScreenState extends State<SymbolTraceScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TraceController _traceController;
  late final AnimationController _pulseController;
  late LetterAudioCue _audioCue;

  int? _activePointer;
  bool _handlingCompletion = false;
  bool _completionReported = false;
  bool _showCelebration = false;

  TraceState get _traceState => _traceController.state;
  String get _symbol => widget.definition.symbol;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _traceController = TraceController(definition: widget.definition);
    _audioCue = widget.audioCue ?? const _SilentLetterAudioCue();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_playSymbolCue());
    });
  }

  @override
  void didUpdateWidget(covariant SymbolTraceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _audioCue = widget.audioCue ?? const _SilentLetterAudioCue();
    if (oldWidget.definition.symbol != widget.definition.symbol ||
        oldWidget.definition.strokes.length !=
            widget.definition.strokes.length) {
      _activePointer = null;
      _traceController = TraceController(definition: widget.definition);
      _handlingCompletion = false;
      _completionReported = false;
      _showCelebration = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_playSymbolCue());
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (animationsDisabled) {
      _pulseController
        ..stop()
        ..value = 0.5;
    } else if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final animationsDisabled =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (!animationsDisabled && !_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    super.dispose();
  }

  TracePoint _normalize(Offset position, Size size) {
    return TracePoint(
      (position.dx / size.width).clamp(0.0, 1.0).toDouble(),
      (position.dy / size.height).clamp(0.0, 1.0).toDouble(),
    );
  }

  void _onPointerDown(PointerDownEvent event, Size size) {
    if (_activePointer != null || _showCelebration) {
      return;
    }
    _activePointer = event.pointer;
    setState(() {
      _traceController.start(_normalize(event.localPosition, size));
    });
  }

  void _onPointerMove(PointerMoveEvent event, Size size) {
    if (_activePointer != event.pointer || _showCelebration) {
      return;
    }

    setState(() {
      _traceController.update(_normalize(event.localPosition, size));
    });

    if (_traceState.isCompleted) {
      _activePointer = null;
      unawaited(_completeSymbol());
    }
  }

  void _onPointerEnd(PointerEvent event) {
    if (_activePointer != event.pointer) {
      return;
    }
    _activePointer = null;
    setState(_traceController.end);
  }

  Future<void> _completeSymbol() async {
    if (_handlingCompletion) {
      return;
    }
    _handlingCompletion = true;

    if (!_completionReported) {
      _completionReported = true;
      try {
        await widget.onCompleted?.call();
      } on Object {
        // Progress callbacks are optional feedback and cannot undo success.
      }
    }

    try {
      await _audioCue.playSuccess();
    } on Object {
      // Audio feedback must never block this fully offline activity.
    }

    if (mounted) {
      setState(() {
        _showCelebration = true;
      });
    }
  }

  Future<void> _playSymbolCue() async {
    try {
      // LetterAudioCue is the legacy offline hook. Catalog callers can supply
      // it for consistent tap feedback; null intentionally stays silent.
      await _audioCue.playLetterA();
    } on Object {
      // Missing device audio cannot block tracing.
    }
  }

  void _resetTrace() {
    _activePointer = null;
    setState(() {
      _traceController.reset();
      _handlingCompletion = false;
      _showCelebration = false;
    });
  }

  void _playAgain() {
    _resetTrace();
    unawaited(_playSymbolCue());
  }

  String get _instruction {
    return switch (_traceState.status) {
      TraceStatus.ready => 'Start at the glowing dot',
      TraceStatus.tracing => 'Keep following the path',
      TraceStatus.offPath => 'Nice try â€” find the glowing dot',
      TraceStatus.completed => 'You traced $_symbol!',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFFBF4),
              widget.accentColor.withValues(alpha: 0.08),
              widget.secondaryColor.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                left: -34,
                top: 120,
                child: _BackgroundBubble(size: 110, color: Color(0x1FFFF0A6)),
              ),
              const Positioned(
                right: -42,
                bottom: 82,
                child: _BackgroundBubble(size: 132, color: Color(0x1F96E6D1)),
              ),
              IgnorePointer(
                ignoring: _showCelebration,
                child: ExcludeSemantics(
                  excluding: _showCelebration,
                  child: Column(
                    children: [
                      _buildTopBar(context),
                      if (widget.header case final header?)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                          child: header,
                        ),
                      Expanded(child: _buildCanvas()),
                      _buildGuidance(context),
                    ],
                  ),
                ),
              ),
              if (_showCelebration)
                _CelebrationOverlay(
                  symbol: _symbol,
                  symbolKind: widget.symbolKind,
                  accentColor: widget.accentColor,
                  onAgain: _playAgain,
                  onHome: () => Navigator.of(context).maybePop(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          _TraceControl(
            key: const ValueKey('home-control'),
            icon: Icons.home_rounded,
            label: 'Back home',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Trace $_symbol',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF392C68),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${widget.symbolKind} adventure',
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF776B90),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _TraceControl(
            key: const ValueKey('replay-audio-control'),
            icon: Icons.volume_up_rounded,
            label: 'Hear ${widget.symbolKind.toLowerCase()} $_symbol',
            onPressed: () => unawaited(_playSymbolCue()),
          ),
          const SizedBox(width: 4),
          _TraceControl(
            key: const ValueKey('reset-trace-control'),
            icon: Icons.refresh_rounded,
            label: 'Start this trace again',
            onPressed: _resetTrace,
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dimension = math.max(
          0.0,
          math.min(constraints.maxWidth - 28, constraints.maxHeight - 8),
        );
        final canvasSize = Size.square(dimension);

        return Center(
          child: SizedBox.square(
            dimension: dimension,
            child: Semantics(
              container: true,
              label:
                  '${widget.symbolKind} $_symbol tracing canvas. $_instruction.',
              child: Listener(
                key: const ValueKey('trace-canvas'),
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) => _onPointerDown(event, canvasSize),
                onPointerMove: (event) => _onPointerMove(event, canvasSize),
                onPointerUp: _onPointerEnd,
                onPointerCancel: _onPointerEnd,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: widget.accentColor.withValues(alpha: 0.18),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.16),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(33),
                    child: CustomPaint(
                      painter: TracePainter(
                        state: _traceState,
                        pulse: _pulseController,
                        activeColor: widget.accentColor,
                        hintColor: widget.secondaryColor,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuidance(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            liveRegion: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _traceState.status == TraceStatus.offPath
                      ? Icons.touch_app_rounded
                      : Icons.auto_awesome_rounded,
                  color: _traceState.status == TraceStatus.offPath
                      ? const Color(0xFFD67700)
                      : widget.accentColor,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _instruction,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF4D4660),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _StrokeProgress(state: _traceState, accentColor: widget.accentColor),
        ],
      ),
    );
  }
}

class _SilentLetterAudioCue implements LetterAudioCue {
  const _SilentLetterAudioCue();

  @override
  Future<void> playLetterA() async {}

  @override
  Future<void> playSuccess() async {}
}

class _TraceControl extends StatelessWidget {
  const _TraceControl({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: IconButton.filledTonal(
          onPressed: onPressed,
          icon: Icon(icon, size: 30),
          style: IconButton.styleFrom(
            minimumSize: const Size.square(64),
            foregroundColor: const Color(0xFF4B377E),
          ),
        ),
      ),
    );
  }
}

class _StrokeProgress extends StatelessWidget {
  const _StrokeProgress({required this.state, required this.accentColor});

  final TraceState state;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final total = state.definition.strokes.length;
    final complete = state.currentStrokeIndex.clamp(0, total);
    return Semantics(
      label: '$complete of $total strokes complete',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(total, (index) {
              final isComplete = index < state.currentStrokeIndex;
              final isCurrent = index == state.currentStrokeIndex;
              return AnimatedContainer(
                key: ValueKey('stroke-progress-$index'),
                duration: const Duration(milliseconds: 180),
                width: isCurrent ? 42 : 24,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: isComplete
                      ? const Color(0xFF25A97A)
                      : isCurrent
                      ? accentColor
                      : const Color(0xFFD8D2E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isComplete
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              );
            }),
          ),
          const SizedBox(height: 7),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                key: const ValueKey('trace-total-progress'),
                value: state.progress,
                minHeight: 7,
                backgroundColor: const Color(0xFFEAE5F2),
                color: const Color(0xFF25A97A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CelebrationOverlay extends StatelessWidget {
  const _CelebrationOverlay({
    required this.symbol,
    required this.symbolKind,
    required this.accentColor,
    required this.onAgain,
    required this.onHome,
  });

  final String symbol;
  final String symbolKind;
  final Color accentColor;
  final VoidCallback onAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      key: const ValueKey('celebration-overlay'),
      child: ColoredBox(
        color: const Color(0xB33A2A66),
        child: Stack(
          children: [
            const Positioned(
              top: 44,
              left: 34,
              child: Icon(Icons.star_rounded, color: Color(0xFFFFD45C), size: 46),
            ),
            const Positioned(
              top: 110,
              right: 38,
              child: Icon(Icons.star_rounded, color: Color(0xFF8DE0CD), size: 34),
            ),
            Center(
              child: Semantics(
                container: true,
                liveRegion: true,
                label: 'Great tracing. You completed $symbolKind $symbol.',
                child: Card(
                  margin: const EdgeInsets.all(28),
                  elevation: 16,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DecoratedBox(
                            decoration: const BoxDecoration(
                              color: Color(0xFF25A97A),
                              shape: BoxShape.circle,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: Icon(
                                Icons.check_rounded,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'You traced $symbol!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: const Color(0xFF392C68),
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Amazing finger work!',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: const Color(0xFF6D6380),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  key: const ValueKey('celebration-home'),
                                  onPressed: onHome,
                                  icon: const Icon(Icons.home_rounded),
                                  label: const Text('Home'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 60),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  key: const ValueKey('celebration-again'),
                                  onPressed: onAgain,
                                  icon: const Icon(Icons.replay_rounded),
                                  label: const Text('Again'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: accentColor,
                                    minimumSize: const Size(0, 60),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundBubble extends StatelessWidget {
  const _BackgroundBubble({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: SizedBox.square(dimension: size),
    );
  }
}
