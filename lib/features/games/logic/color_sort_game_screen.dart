import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/letter_audio_cue.dart';
import 'logic_game_ui.dart';

class ColorSortGameScreen extends StatefulWidget {
  const ColorSortGameScreen({
    required this.audioCue,
    super.key,
    this.onCompleted,
  });

  final LetterAudioCue audioCue;
  final VoidCallback? onCompleted;

  static int get contentCount => _ColorSortGameScreenState.contentCount;

  @override
  State<ColorSortGameScreen> createState() => _ColorSortGameScreenState();
}

class _SortBucket {
  const _SortBucket({
    required this.id,
    required this.name,
    required this.color,
  });

  final int id;
  final String name;
  final Color color;
}

class _SortPiece {
  const _SortPiece({
    required this.id,
    required this.bucketId,
    required this.icon,
    required this.label,
  });

  final int id;
  final int bucketId;
  final IconData icon;
  final String label;
}

class _ColorSortGameScreenState extends State<ColorSortGameScreen> {
  static const _buckets = <_SortBucket>[
    _SortBucket(id: 0, name: 'Red', color: Color(0xFFF05B61)),
    _SortBucket(id: 1, name: 'Blue', color: Color(0xFF4A8FE7)),
    _SortBucket(id: 2, name: 'Yellow', color: Color(0xFFFFC83D)),
  ];

  static const _rounds = <List<_SortPiece>>[
    [
      _SortPiece(
        id: 0,
        bucketId: 0,
        icon: Icons.favorite_rounded,
        label: 'heart',
      ),
      _SortPiece(id: 1, bucketId: 1, icon: Icons.circle, label: 'circle'),
      _SortPiece(id: 2, bucketId: 2, icon: Icons.star_rounded, label: 'star'),
      _SortPiece(
        id: 3,
        bucketId: 0,
        icon: Icons.square_rounded,
        label: 'square',
      ),
      _SortPiece(id: 4, bucketId: 2, icon: Icons.circle, label: 'circle'),
      _SortPiece(
        id: 5,
        bucketId: 1,
        icon: Icons.hexagon_rounded,
        label: 'hexagon',
      ),
    ],
    [
      _SortPiece(
        id: 0,
        bucketId: 2,
        icon: Icons.favorite_rounded,
        label: 'heart',
      ),
      _SortPiece(id: 1, bucketId: 0, icon: Icons.star_rounded, label: 'star'),
      _SortPiece(
        id: 2,
        bucketId: 1,
        icon: Icons.square_rounded,
        label: 'square',
      ),
      _SortPiece(
        id: 3,
        bucketId: 2,
        icon: Icons.hexagon_rounded,
        label: 'hexagon',
      ),
      _SortPiece(
        id: 4,
        bucketId: 1,
        icon: Icons.favorite_rounded,
        label: 'heart',
      ),
      _SortPiece(id: 5, bucketId: 0, icon: Icons.circle, label: 'circle'),
    ],
    [
      _SortPiece(id: 0, bucketId: 1, icon: Icons.star_rounded, label: 'star'),
      _SortPiece(
        id: 1,
        bucketId: 2,
        icon: Icons.square_rounded,
        label: 'square',
      ),
      _SortPiece(
        id: 2,
        bucketId: 0,
        icon: Icons.hexagon_rounded,
        label: 'hexagon',
      ),
      _SortPiece(id: 3, bucketId: 1, icon: Icons.circle, label: 'circle'),
      _SortPiece(
        id: 4,
        bucketId: 0,
        icon: Icons.favorite_rounded,
        label: 'heart',
      ),
      _SortPiece(id: 5, bucketId: 2, icon: Icons.star_rounded, label: 'star'),
    ],
    [
      _SortPiece(id: 0, bucketId: 0, icon: Icons.star_rounded, label: 'star'),
      _SortPiece(id: 1, bucketId: 2, icon: Icons.circle, label: 'circle'),
      _SortPiece(
        id: 2,
        bucketId: 1,
        icon: Icons.favorite_rounded,
        label: 'heart',
      ),
      _SortPiece(
        id: 3,
        bucketId: 0,
        icon: Icons.hexagon_rounded,
        label: 'hexagon',
      ),
      _SortPiece(
        id: 4,
        bucketId: 1,
        icon: Icons.square_rounded,
        label: 'square',
      ),
      _SortPiece(
        id: 5,
        bucketId: 2,
        icon: Icons.favorite_rounded,
        label: 'heart',
      ),
    ],
    [
      _SortPiece(
        id: 0,
        bucketId: 1,
        icon: Icons.favorite_rounded,
        label: 'heart',
      ),
      _SortPiece(id: 1, bucketId: 0, icon: Icons.circle, label: 'circle'),
      _SortPiece(
        id: 2,
        bucketId: 2,
        icon: Icons.square_rounded,
        label: 'square',
      ),
      _SortPiece(
        id: 3,
        bucketId: 2,
        icon: Icons.hexagon_rounded,
        label: 'hexagon',
      ),
      _SortPiece(id: 4, bucketId: 1, icon: Icons.star_rounded, label: 'star'),
      _SortPiece(
        id: 5,
        bucketId: 0,
        icon: Icons.favorite_rounded,
        label: 'heart',
      ),
    ],
    [
      _SortPiece(id: 0, bucketId: 2, icon: Icons.star_rounded, label: 'star'),
      _SortPiece(
        id: 1,
        bucketId: 0,
        icon: Icons.hexagon_rounded,
        label: 'hexagon',
      ),
      _SortPiece(id: 2, bucketId: 1, icon: Icons.circle, label: 'circle'),
      _SortPiece(
        id: 3,
        bucketId: 0,
        icon: Icons.square_rounded,
        label: 'square',
      ),
      _SortPiece(
        id: 4,
        bucketId: 2,
        icon: Icons.favorite_rounded,
        label: 'heart',
      ),
      _SortPiece(id: 5, bucketId: 1, icon: Icons.star_rounded, label: 'star'),
    ],
    [
      _SortPiece(
        id: 0,
        bucketId: 0,
        icon: Icons.favorite_rounded,
        label: 'heart',
      ),
      _SortPiece(
        id: 1,
        bucketId: 1,
        icon: Icons.hexagon_rounded,
        label: 'hexagon',
      ),
      _SortPiece(
        id: 2,
        bucketId: 1,
        icon: Icons.square_rounded,
        label: 'square',
      ),
      _SortPiece(id: 3, bucketId: 2, icon: Icons.circle, label: 'circle'),
      _SortPiece(id: 4, bucketId: 0, icon: Icons.star_rounded, label: 'star'),
      _SortPiece(
        id: 5,
        bucketId: 2,
        icon: Icons.square_rounded,
        label: 'square',
      ),
    ],
    [
      _SortPiece(
        id: 0,
        bucketId: 2,
        icon: Icons.hexagon_rounded,
        label: 'hexagon',
      ),
      _SortPiece(
        id: 1,
        bucketId: 1,
        icon: Icons.favorite_rounded,
        label: 'heart',
      ),
      _SortPiece(id: 2, bucketId: 0, icon: Icons.circle, label: 'circle'),
      _SortPiece(id: 3, bucketId: 2, icon: Icons.star_rounded, label: 'star'),
      _SortPiece(
        id: 4,
        bucketId: 0,
        icon: Icons.square_rounded,
        label: 'square',
      ),
      _SortPiece(id: 5, bucketId: 1, icon: Icons.circle, label: 'circle'),
    ],
    [
      _SortPiece(id: 0, bucketId: 1, icon: Icons.star_rounded, label: 'star'),
      _SortPiece(
        id: 1,
        bucketId: 2,
        icon: Icons.favorite_rounded,
        label: 'heart',
      ),
      _SortPiece(
        id: 2,
        bucketId: 0,
        icon: Icons.hexagon_rounded,
        label: 'hexagon',
      ),
      _SortPiece(
        id: 3,
        bucketId: 1,
        icon: Icons.square_rounded,
        label: 'square',
      ),
      _SortPiece(id: 4, bucketId: 0, icon: Icons.circle, label: 'circle'),
      _SortPiece(id: 5, bucketId: 2, icon: Icons.star_rounded, label: 'star'),
    ],
    [
      _SortPiece(
        id: 0,
        bucketId: 0,
        icon: Icons.square_rounded,
        label: 'square',
      ),
      _SortPiece(
        id: 1,
        bucketId: 2,
        icon: Icons.hexagon_rounded,
        label: 'hexagon',
      ),
      _SortPiece(id: 2, bucketId: 1, icon: Icons.circle, label: 'circle'),
      _SortPiece(
        id: 3,
        bucketId: 1,
        icon: Icons.favorite_rounded,
        label: 'heart',
      ),
      _SortPiece(id: 4, bucketId: 2, icon: Icons.circle, label: 'circle'),
      _SortPiece(id: 5, bucketId: 0, icon: Icons.star_rounded, label: 'star'),
    ],
  ];

  static int get contentCount => _rounds.length;

  int _roundIndex = 0;
  late Set<int> _remainingPieceIds;
  int? _selectedPieceId;
  bool _roundSolved = false;
  bool _completionSent = false;
  String _feedback = 'Drag a shape, or tap it and then tap a basket.';
  LogicFeedbackTone _feedbackTone = LogicFeedbackTone.neutral;

  List<_SortPiece> get _pieces => _rounds[_roundIndex];
  bool get _isLastRound => _roundIndex == _rounds.length - 1;

  void _playFeedback(Future<void> Function(LetterAudioCue cue) action) {
    unawaited(action(widget.audioCue).catchError((Object _) {}));
  }

  @override
  void initState() {
    super.initState();
    _remainingPieceIds = _idsForRound(0);
  }

  Set<int> _idsForRound(int index) =>
      _rounds[index].map((piece) => piece.id).toSet();

  _SortPiece _pieceWithId(int id) =>
      _pieces.firstWhere((piece) => piece.id == id);

  _SortBucket _bucketWithId(int id) =>
      _buckets.firstWhere((bucket) => bucket.id == id);

  void _selectPiece(int id) {
    if (!_remainingPieceIds.contains(id) || _roundSolved) return;
    setState(() {
      _selectedPieceId = id;
      final piece = _pieceWithId(id);
      final bucket = _bucketWithId(piece.bucketId);
      _feedback =
          'Now put the ${bucket.name.toLowerCase()} ${piece.label} in a basket.';
      _feedbackTone = LogicFeedbackTone.neutral;
    });
    _playFeedback((cue) => cue.playTap());
  }

  void _tapBasket(int bucketId) {
    final selectedId = _selectedPieceId;
    if (selectedId == null) {
      setState(() {
        _feedback = 'Choose a colorful shape first.';
        _feedbackTone = LogicFeedbackTone.encouragement;
      });
      _playFeedback((cue) => cue.playInvalidAction());
      return;
    }
    _tryPlace(selectedId, bucketId);
  }

  void _tryPlace(int pieceId, int bucketId) {
    if (!_remainingPieceIds.contains(pieceId) || _roundSolved) return;

    final piece = _pieceWithId(pieceId);
    final correctBucket = _bucketWithId(piece.bucketId);
    final isCorrect = piece.bucketId == bucketId;
    var completedNow = false;

    setState(() {
      if (isCorrect) {
        _remainingPieceIds.remove(pieceId);
        _selectedPieceId = null;
        _feedback = 'Great sorting! The ${piece.label} found its basket.';
        _feedbackTone = LogicFeedbackTone.success;
        if (_remainingPieceIds.isEmpty) {
          _roundSolved = true;
          completedNow = _isLastRound;
          _feedback = _isLastRound
              ? 'Wonderful! Every color is sorted!'
              : 'Beautiful! This group is all sorted.';
        }
      } else {
        _selectedPieceId = pieceId;
        _feedback =
            'Good try! This ${piece.label} is ${correctBucket.name.toLowerCase()}.';
        _feedbackTone = LogicFeedbackTone.encouragement;
      }
    });

    if (completedNow && !_completionSent) {
      _playFeedback((cue) => cue.playWin());
      _completionSent = true;
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
        _remainingPieceIds = _idsForRound(0);
        _selectedPieceId = null;
        _roundSolved = false;
        _completionSent = false;
        _feedback = 'Drag a shape, or tap it and then tap a basket.';
        _feedbackTone = LogicFeedbackTone.neutral;
      });
      return;
    }

    setState(() {
      _roundIndex += 1;
      _remainingPieceIds = _idsForRound(_roundIndex);
      _selectedPieceId = null;
      _roundSolved = false;
      _feedback = 'A fresh color mix! Where does each shape belong?';
      _feedbackTone = LogicFeedbackTone.neutral;
    });
  }

  void _restart() {
    _playFeedback((cue) => cue.playRestart());
    setState(() {
      _roundIndex = 0;
      _remainingPieceIds = _idsForRound(0);
      _selectedPieceId = null;
      _roundSolved = false;
      _completionSent = false;
      _feedback = 'Drag a shape, or tap it and then tap a basket.';
      _feedbackTone = LogicFeedbackTone.neutral;
    });
  }

  Widget _buildPiece(_SortPiece piece, {bool isDragFeedback = false}) {
    final bucket = _bucketWithId(piece.bucketId);
    final selected = _selectedPieceId == piece.id;

    return Semantics(
      label: '${bucket.name} ${piece.label}',
      button: !isDragFeedback,
      selected: selected,
      child: AnimatedScale(
        scale: selected && !isDragFeedback ? 1.08 : 1,
        duration: const Duration(milliseconds: 160),
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: selected ? bucket.color : Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: bucket.color.withValues(alpha: 0.24),
                offset: const Offset(0, 5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(piece.icon, color: bucket.color, size: 48),
        ),
      ),
    );
  }

  Widget _buildBasket(_SortBucket bucket) {
    final placedCount = _pieces
        .where(
          (piece) =>
              piece.bucketId == bucket.id &&
              !_remainingPieceIds.contains(piece.id),
        )
        .length;

    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => !_roundSolved,
      onAcceptWithDetails: (details) => _tryPlace(details.data, bucket.id),
      builder: (context, candidateData, rejectedData) {
        final hovering = candidateData.isNotEmpty;
        return Semantics(
          button: true,
          label: '${bucket.name} basket. $placedCount shapes sorted.',
          child: AnimatedScale(
            scale: hovering ? 1.06 : 1,
            duration: const Duration(milliseconds: 140),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => _tapBasket(bucket.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 108,
                  height: 128,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bucket.color.withValues(
                      alpha: hovering ? 0.25 : 0.14,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: bucket.color,
                      width: hovering ? 5 : 3,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_basket_rounded,
                        color: bucket.color,
                        size: 53,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bucket.name,
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          color: Color(0xFF433C55),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '$placedCount/2',
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: bucket.color,
                          fontSize: 14,
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
    const accent = Color(0xFFE76D52);

    return LogicGameScaffold(
      title: 'Color Sort',
      prompt: 'Match every shape to its color basket!',
      accentColor: accent,
      round: _roundIndex + 1,
      totalRounds: _rounds.length,
      onRestart: _restart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 126),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFFFD9CD), width: 2),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              child: _remainingPieceIds.isEmpty
                  ? const Center(
                      key: ValueKey('sorted'),
                      child: Text(
                        '🌈  ✨  🌈',
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(fontSize: 50),
                      ),
                    )
                  : Wrap(
                      key: ValueKey('pieces-${_remainingPieceIds.length}'),
                      alignment: WrapAlignment.center,
                      spacing: 13,
                      runSpacing: 13,
                      children: _pieces
                          .where(
                            (piece) => _remainingPieceIds.contains(piece.id),
                          )
                          .map(
                            (piece) => Draggable<int>(
                              data: piece.id,
                              maxSimultaneousDrags: _roundSolved ? 0 : 1,
                              onDragStarted: () => _selectPiece(piece.id),
                              feedback: Material(
                                color: Colors.transparent,
                                child: _buildPiece(piece, isDragFeedback: true),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.24,
                                child: _buildPiece(piece),
                              ),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _selectPiece(piece.id),
                                child: _buildPiece(piece),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 10,
            runSpacing: 12,
            children: _buckets.map(_buildBasket).toList(),
          ),
          const SizedBox(height: 20),
          LogicFeedbackBanner(message: _feedback, tone: _feedbackTone),
          if (_roundSolved) ...[
            const SizedBox(height: 16),
            LogicRoundButton(
              label: _isLastRound ? 'Sort again' : 'Next color mix',
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
