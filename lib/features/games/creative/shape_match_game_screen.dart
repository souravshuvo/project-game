import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/letter_audio_cue.dart';
import '../logic/logic_game_ui.dart';

class ShapeMatchGameScreen extends StatefulWidget {
  const ShapeMatchGameScreen({
    required this.audioCue,
    this.onCompleted,
    this.onPlayNextGame,
    this.nextGameTitle,
    super.key,
  });

  final LetterAudioCue audioCue;
  final VoidCallback? onCompleted;
  final VoidCallback? onPlayNextGame;
  final String? nextGameTitle;

  static int get contentCount => _ShapeMatchGameScreenState.contentCount;

  @override
  State<ShapeMatchGameScreen> createState() => _ShapeMatchGameScreenState();
}

class _ShapePiece {
  const _ShapePiece({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  final int id;
  final String name;
  final IconData icon;
  final Color color;
}

class _ShapeMatchGameScreenState extends State<ShapeMatchGameScreen> {
  static const _rounds = <List<_ShapePiece>>[
    [
      _ShapePiece(
        id: 0,
        name: 'circle',
        icon: Icons.circle,
        color: Color(0xFF35A7FF),
      ),
      _ShapePiece(
        id: 1,
        name: 'star',
        icon: Icons.star_rounded,
        color: Color(0xFFFFA928),
      ),
      _ShapePiece(
        id: 2,
        name: 'square',
        icon: Icons.square_rounded,
        color: Color(0xFF7257E8),
      ),
      _ShapePiece(
        id: 3,
        name: 'heart',
        icon: Icons.favorite_rounded,
        color: Color(0xFFFF5D7D),
      ),
    ],
    [
      _ShapePiece(
        id: 0,
        name: 'triangle',
        icon: Icons.change_history_rounded,
        color: Color(0xFFFF8A3D),
      ),
      _ShapePiece(
        id: 1,
        name: 'diamond',
        icon: Icons.diamond_rounded,
        color: Color(0xFF2DBE88),
      ),
      _ShapePiece(
        id: 2,
        name: 'hexagon',
        icon: Icons.hexagon_rounded,
        color: Color(0xFF8D57D9),
      ),
      _ShapePiece(
        id: 3,
        name: 'circle',
        icon: Icons.circle,
        color: Color(0xFF43C8D9),
      ),
    ],
    [
      _ShapePiece(
        id: 0,
        name: 'square',
        icon: Icons.square_rounded,
        color: Color(0xFFEF5DA8),
      ),
      _ShapePiece(
        id: 1,
        name: 'star',
        icon: Icons.star_rounded,
        color: Color(0xFFFFC14F),
      ),
      _ShapePiece(
        id: 2,
        name: 'heart',
        icon: Icons.favorite_rounded,
        color: Color(0xFFEC6F66),
      ),
      _ShapePiece(
        id: 3,
        name: 'diamond',
        icon: Icons.diamond_rounded,
        color: Color(0xFF2CB9A0),
      ),
    ],
    [
      _ShapePiece(
        id: 0,
        name: 'diamond',
        icon: Icons.diamond_rounded,
        color: Color(0xFF35A7FF),
      ),
      _ShapePiece(
        id: 1,
        name: 'triangle',
        icon: Icons.change_history_rounded,
        color: Color(0xFFFF8A3D),
      ),
      _ShapePiece(
        id: 2,
        name: 'circle',
        icon: Icons.circle,
        color: Color(0xFF2DBE88),
      ),
      _ShapePiece(
        id: 3,
        name: 'star',
        icon: Icons.star_rounded,
        color: Color(0xFFFFC14F),
      ),
    ],
    [
      _ShapePiece(
        id: 0,
        name: 'hexagon',
        icon: Icons.hexagon_rounded,
        color: Color(0xFF7257E8),
      ),
      _ShapePiece(
        id: 1,
        name: 'heart',
        icon: Icons.favorite_rounded,
        color: Color(0xFFFF5D7D),
      ),
      _ShapePiece(
        id: 2,
        name: 'diamond',
        icon: Icons.diamond_rounded,
        color: Color(0xFF35A7FF),
      ),
      _ShapePiece(
        id: 3,
        name: 'square',
        icon: Icons.square_rounded,
        color: Color(0xFF2CB9A0),
      ),
    ],
    [
      _ShapePiece(
        id: 0,
        name: 'circle',
        icon: Icons.circle,
        color: Color(0xFFFFA928),
      ),
      _ShapePiece(
        id: 1,
        name: 'triangle',
        icon: Icons.change_history_rounded,
        color: Color(0xFFEF5DA8),
      ),
      _ShapePiece(
        id: 2,
        name: 'hexagon',
        icon: Icons.hexagon_rounded,
        color: Color(0xFF8D57D9),
      ),
      _ShapePiece(
        id: 3,
        name: 'star',
        icon: Icons.star_rounded,
        color: Color(0xFF43C8D9),
      ),
    ],
    [
      _ShapePiece(
        id: 0,
        name: 'heart',
        icon: Icons.favorite_rounded,
        color: Color(0xFFEC6F66),
      ),
      _ShapePiece(
        id: 1,
        name: 'hexagon',
        icon: Icons.hexagon_rounded,
        color: Color(0xFF2DBE88),
      ),
      _ShapePiece(
        id: 2,
        name: 'triangle',
        icon: Icons.change_history_rounded,
        color: Color(0xFFFF8A3D),
      ),
      _ShapePiece(
        id: 3,
        name: 'diamond',
        icon: Icons.diamond_rounded,
        color: Color(0xFF35A7FF),
      ),
    ],
    [
      _ShapePiece(
        id: 0,
        name: 'square',
        icon: Icons.square_rounded,
        color: Color(0xFF43C8D9),
      ),
      _ShapePiece(
        id: 1,
        name: 'circle',
        icon: Icons.circle,
        color: Color(0xFF7257E8),
      ),
      _ShapePiece(
        id: 2,
        name: 'star',
        icon: Icons.star_rounded,
        color: Color(0xFFFFA928),
      ),
      _ShapePiece(
        id: 3,
        name: 'heart',
        icon: Icons.favorite_rounded,
        color: Color(0xFFFF5D7D),
      ),
    ],
    [
      _ShapePiece(
        id: 0,
        name: 'diamond',
        icon: Icons.diamond_rounded,
        color: Color(0xFF2CB9A0),
      ),
      _ShapePiece(
        id: 1,
        name: 'triangle',
        icon: Icons.change_history_rounded,
        color: Color(0xFFEC6F66),
      ),
      _ShapePiece(
        id: 2,
        name: 'hexagon',
        icon: Icons.hexagon_rounded,
        color: Color(0xFF8D57D9),
      ),
      _ShapePiece(
        id: 3,
        name: 'heart',
        icon: Icons.favorite_rounded,
        color: Color(0xFFFFC14F),
      ),
    ],
    [
      _ShapePiece(
        id: 0,
        name: 'circle',
        icon: Icons.circle,
        color: Color(0xFF2DBE88),
      ),
      _ShapePiece(
        id: 1,
        name: 'square',
        icon: Icons.square_rounded,
        color: Color(0xFF7257E8),
      ),
      _ShapePiece(
        id: 2,
        name: 'diamond',
        icon: Icons.diamond_rounded,
        color: Color(0xFF35A7FF),
      ),
      _ShapePiece(
        id: 3,
        name: 'star',
        icon: Icons.star_rounded,
        color: Color(0xFFFFA928),
      ),
    ],
  ];

  static int get contentCount => _rounds.length;

  int _roundIndex = 0;
  late Set<int> _remainingIds;
  int? _selectedId;
  int _streak = 0;
  int _mistakes = 0;
  bool _roundSolved = false;
  bool _completionReported = false;
  String _feedback = 'Drag a shape, or tap it and then tap its home.';
  LogicFeedbackTone _feedbackTone = LogicFeedbackTone.neutral;

  List<_ShapePiece> get _pieces => _rounds[_roundIndex];
  bool get _isLastRound => _roundIndex == _rounds.length - 1;

  void _playFeedback(Future<void> Function(LetterAudioCue cue) action) {
    unawaited(action(widget.audioCue).catchError((Object _) {}));
  }

  @override
  void initState() {
    super.initState();
    _remainingIds = _idsForRound(0);
  }

  Set<int> _idsForRound(int roundIndex) =>
      _rounds[roundIndex].map((shape) => shape.id).toSet();

  _ShapePiece _shapeWithId(int id) =>
      _pieces.firstWhere((shape) => shape.id == id);

  void _selectShape(int id) {
    if (!_remainingIds.contains(id) || _roundSolved) {
      return;
    }

    setState(() {
      _selectedId = id;
      final shape = _shapeWithId(id);
      _feedback = 'Now find the ${shape.name} home.';
      _feedbackTone = LogicFeedbackTone.neutral;
    });
    _playFeedback((cue) => cue.playTap());
  }

  void _tapHome(int homeId) {
    final selectedId = _selectedId;
    if (selectedId == null) {
      setState(() {
        _feedback = 'Choose a shape first.';
        _feedbackTone = LogicFeedbackTone.encouragement;
      });
      _playFeedback((cue) => cue.playInvalidAction());
      return;
    }
    _tryPlace(selectedId, homeId);
  }

  void _tryPlace(int shapeId, int homeId) {
    if (!_remainingIds.contains(shapeId) || _roundSolved) {
      return;
    }

    final shape = _shapeWithId(shapeId);
    final isCorrect = shapeId == homeId;
    var completedNow = false;

    setState(() {
      if (isCorrect) {
        _streak += 1;
        _remainingIds.remove(shapeId);
        _selectedId = null;
        _feedback = 'Yes! The ${shape.name} fits right there.';
        _feedbackTone = LogicFeedbackTone.success;
        if (_remainingIds.isEmpty) {
          _roundSolved = true;
          completedNow = _isLastRound;
          _feedback = _isLastRound
              ? 'Every shape found a home!'
              : 'This shape board is complete.';
        }
      } else {
        _streak = 0;
        _mistakes += 1;
        _selectedId = shapeId;
        _feedback = 'Close! Match the shape, not just the color.';
        _feedbackTone = LogicFeedbackTone.encouragement;
      }
    });

    if (completedNow && !_completionReported) {
      _playFeedback((cue) => cue.playWin());
      _completionReported = true;
      widget.onCompleted?.call();
    } else if (isCorrect) {
      _playFeedback((cue) => cue.playReward());
    } else {
      _playFeedback((cue) => cue.playInvalidAction());
    }
  }

  void _continue() {
    _playFeedback((cue) => cue.playTap());
    if (_isLastRound) {
      setState(() {
        _roundIndex = 0;
        _remainingIds = _idsForRound(0);
        _selectedId = null;
        _streak = 0;
        _mistakes = 0;
        _roundSolved = false;
        _completionReported = false;
        _feedback = 'Drag a shape, or tap it and then tap its home.';
        _feedbackTone = LogicFeedbackTone.neutral;
      });
      return;
    }

    setState(() {
      _roundIndex += 1;
      _remainingIds = _idsForRound(_roundIndex);
      _selectedId = null;
      _roundSolved = false;
      _feedback = 'New shapes are ready.';
      _feedbackTone = LogicFeedbackTone.neutral;
    });
  }

  void _restart() {
    _playFeedback((cue) => cue.playRestart());
    setState(() {
      _roundIndex = 0;
      _remainingIds = _idsForRound(0);
      _selectedId = null;
      _streak = 0;
      _mistakes = 0;
      _roundSolved = false;
      _completionReported = false;
      _feedback = 'Drag a shape, or tap it and then tap its home.';
      _feedbackTone = LogicFeedbackTone.neutral;
    });
  }

  Widget _buildShapePiece(_ShapePiece shape, {bool isDragFeedback = false}) {
    final selected = _selectedId == shape.id;

    return Semantics(
      button: !isDragFeedback,
      selected: selected,
      label: shape.name,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: selected && !isDragFeedback ? 1.08 : 1,
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? shape.color : Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: shape.color.withValues(alpha: 0.24),
                offset: const Offset(0, 6),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(shape.icon, color: shape.color, size: 52),
        ),
      ),
    );
  }

  Widget _buildShapeHome(_ShapePiece shape) {
    final placed = !_remainingIds.contains(shape.id);

    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => !placed && !_roundSolved,
      onAcceptWithDetails: (details) => _tryPlace(details.data, shape.id),
      builder: (context, candidateData, rejectedData) {
        final hovering = candidateData.isNotEmpty && !placed;
        return Semantics(
          button: true,
          label: placed
              ? '${shape.name} home filled'
              : '${shape.name} home empty',
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: hovering ? 1.06 : 1,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: placed ? null : () => _tapHome(shape.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  width: 126,
                  height: 132,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: placed
                        ? shape.color.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: placed || hovering
                          ? shape.color
                          : shape.color.withValues(alpha: 0.42),
                      width: hovering ? 5 : 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: shape.color.withValues(alpha: 0.14),
                        offset: const Offset(0, 5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        shape.icon,
                        color: placed
                            ? shape.color
                            : shape.color.withValues(alpha: 0.34),
                        size: 58,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        shape.name,
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: placed ? shape.color : const Color(0xFF635A76),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF2CB9A0);

    return LogicGameScaffold(
      title: 'Shape Match',
      prompt: 'Put each shape in the matching home.',
      accentColor: accent,
      round: _roundIndex + 1,
      totalRounds: _rounds.length,
      statusLabel: 'Streak $_streak',
      statusIcon: Icons.local_fire_department_rounded,
      onRestart: _restart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: _pieces.map(_buildShapeHome).toList(),
          ),
          const SizedBox(height: 20),
          Container(
            constraints: const BoxConstraints(minHeight: 128),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFC7F0E7), width: 2),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _remainingIds.isEmpty
                  ? const Center(
                      key: ValueKey('all-shapes-placed'),
                      child: Icon(
                        Icons.celebration_rounded,
                        color: Color(0xFF2CB9A0),
                        size: 64,
                      ),
                    )
                  : Wrap(
                      key: ValueKey('shape-pieces-${_remainingIds.length}'),
                      alignment: WrapAlignment.center,
                      spacing: 14,
                      runSpacing: 14,
                      children: _pieces
                          .where((shape) => _remainingIds.contains(shape.id))
                          .map(
                            (shape) => Draggable<int>(
                              data: shape.id,
                              maxSimultaneousDrags: _roundSolved ? 0 : 1,
                              onDragStarted: () => _selectShape(shape.id),
                              feedback: Material(
                                color: Colors.transparent,
                                child: _buildShapePiece(
                                  shape,
                                  isDragFeedback: true,
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.24,
                                child: _buildShapePiece(shape),
                              ),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _selectShape(shape.id),
                                child: _buildShapePiece(shape),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          LogicFeedbackBanner(message: _feedback, tone: _feedbackTone),
          if (_roundSolved && _isLastRound) ...[
            const SizedBox(height: 12),
            LogicRunSummary(
              stars: _starsForMistakes(_mistakes),
              title: 'Shape path complete',
              subtitle: _mistakes == 0
                  ? 'Every shape landed first try.'
                  : 'Replay to earn a cleaner shape run.',
              color: accent,
            ),
          ],
          if (_roundSolved) ...[
            const SizedBox(height: 16),
            LogicCompletionActions(
              isLastRound: _isLastRound,
              nextRoundLabel: 'Next board',
              replayLabel: 'Match again',
              color: accent,
              onContinue: _continue,
              onPlayNextGame: widget.onPlayNextGame,
              nextGameTitle: widget.nextGameTitle,
            ),
          ],
        ],
      ),
    );
  }

  int _starsForMistakes(int mistakes) {
    if (mistakes == 0) return 3;
    if (mistakes <= 3) return 2;
    return 1;
  }
}
