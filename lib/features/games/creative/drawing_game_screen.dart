import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/letter_audio_cue.dart';
import '../shared/kid_celebration.dart';

/// A cheerful, offline finger-painting activity.
class DrawingGameScreen extends StatefulWidget {
  const DrawingGameScreen({
    required this.audioCue,
    this.onCompleted,
    super.key,
  });

  final LetterAudioCue audioCue;
  final VoidCallback? onCompleted;

  static int get contentCount => _DrawingGameScreenState.contentCount;

  @override
  State<DrawingGameScreen> createState() => _DrawingGameScreenState();
}

class _DrawingGameScreenState extends State<DrawingGameScreen> {
  static const _palette = <Color>[
    Color(0xFF7357E8),
    Color(0xFFFF5D7D),
    Color(0xFFFFA928),
    Color(0xFF2DBE88),
    Color(0xFF35A7FF),
    Color(0xFF7B4B32),
  ];

  static const _missions = <String>[
    'Draw a sunny day',
    'Draw three balloons',
    'Draw a happy face',
    'Draw a tall tree',
    'Draw a little house',
    'Draw a rainbow',
    'Draw a big fish',
    'Draw your favorite fruit',
    'Draw a toy car',
    'Draw a flower garden',
    'Draw a sleepy moon',
    'Draw a friendly animal',
    'Draw a birthday cake',
    'Draw a boat on water',
    'Draw a starry sky',
    'Draw anything you imagine',
  ];

  static int get contentCount => _missions.length;

  final List<_DrawingStroke> _strokes = <_DrawingStroke>[];
  int _missionIndex = 0;
  Color _selectedColor = _palette.first;
  double _brushWidth = 10;
  bool _isComplete = false;
  bool _completionReported = false;

  bool get _hasDrawing => _strokes.any((stroke) => stroke.points.isNotEmpty);
  String get _mission => _missions[_missionIndex];
  bool get _isLastMission => _missionIndex == _missions.length - 1;

  void _playFeedback(Future<void> Function(LetterAudioCue cue) action) {
    unawaited(action(widget.audioCue).catchError((Object _) {}));
  }

  void _startStroke(DragStartDetails details) {
    if (_isComplete) return;
    setState(() {
      _strokes.add(
        _DrawingStroke(
          color: _selectedColor,
          width: _brushWidth,
          points: <Offset>[details.localPosition],
        ),
      );
    });
    _playFeedback((cue) => cue.playTap());
  }

  void _continueStroke(DragUpdateDetails details) {
    if (_isComplete || _strokes.isEmpty) return;
    setState(() => _strokes.last.points.add(details.localPosition));
  }

  void _undo() {
    if (_strokes.isEmpty || _isComplete) return;
    _playFeedback((cue) => cue.playValidAction());
    setState(_strokes.removeLast);
  }

  void _clear() {
    if (_strokes.isNotEmpty || _isComplete) {
      _playFeedback((cue) => cue.playRestart());
    }
    setState(() {
      _strokes.clear();
      _isComplete = false;
      _completionReported = false;
    });
  }

  void _complete() {
    if (!_hasDrawing || _isComplete) return;
    setState(() => _isComplete = true);
    if (_isLastMission && !_completionReported) {
      _playFeedback((cue) => cue.playWin());
      _completionReported = true;
      widget.onCompleted?.call();
    } else {
      _playFeedback((cue) => cue.playReward());
    }
  }

  void _newPicture() {
    _playFeedback((cue) => cue.playTap());
    setState(() {
      _strokes.clear();
      _isComplete = false;
      if (_isLastMission) {
        _missionIndex = 0;
        _completionReported = false;
      } else {
        _missionIndex += 1;
      }
    });
  }

  void _selectColor(Color color) {
    if (_isComplete) return;
    _playFeedback((cue) => cue.playTap());
    setState(() => _selectedColor = color);
  }

  void _selectBrush(double width) {
    if (_isComplete) return;
    _playFeedback((cue) => cue.playTap());
    setState(() => _brushWidth = width);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFFFFF1D7), Color(0xFFECE6FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _DrawingHeader(
                mission: _mission,
                missionNumber: _missionIndex + 1,
                totalMissions: _missions.length,
                hasDrawing: _hasDrawing,
                isComplete: _isComplete,
                onComplete: _complete,
                onNewPicture: _newPicture,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFEFB),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white, width: 5),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x247257E8),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(27),
                            child: GestureDetector(
                              key: const ValueKey<String>('drawing-canvas'),
                              behavior: HitTestBehavior.opaque,
                              onPanStart: _startStroke,
                              onPanUpdate: _continueStroke,
                              child: CustomPaint(
                                painter: _DrawingPainter(_strokes),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!_hasDrawing)
                        IgnorePointer(
                          child: Center(child: _CanvasHint(mission: _mission)),
                        ),
                      if (_isComplete)
                        const Positioned.fill(
                          child: IgnorePointer(
                            child: KidConfettiOverlay(
                              active: true,
                              density: 42,
                              child: SizedBox.expand(),
                            ),
                          ),
                        ),
                      if (_isComplete)
                        Positioned(
                          left: 18,
                          right: 18,
                          top: 18,
                          child: _DrawingCompleteBanner(
                            isLastMission: _isLastMission,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _DrawingToolbar(
                palette: _palette,
                selectedColor: _selectedColor,
                brushWidth: _brushWidth,
                canUndo: _strokes.isNotEmpty && !_isComplete,
                canClear: _strokes.isNotEmpty,
                onColorSelected: _selectColor,
                onBrushSelected: _selectBrush,
                onUndo: _undo,
                onClear: _clear,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawingHeader extends StatelessWidget {
  const _DrawingHeader({
    required this.mission,
    required this.missionNumber,
    required this.totalMissions,
    required this.hasDrawing,
    required this.isComplete,
    required this.onComplete,
    required this.onNewPicture,
  });

  final String mission;
  final int missionNumber;
  final int totalMissions;
  final bool hasDrawing;
  final bool isComplete;
  final VoidCallback onComplete;
  final VoidCallback onNewPicture;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Row(
        children: <Widget>[
          SizedBox.square(
            dimension: 64,
            child: IconButton.filledTonal(
              tooltip: 'Go back',
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 30),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Magic Drawing',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF392C68),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$missionNumber/$totalMissions • $mission',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF746A87),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 64,
            child: FilledButton.icon(
              key: const ValueKey<String>('drawing-done-button'),
              onPressed: isComplete
                  ? onNewPicture
                  : hasDrawing
                  ? onComplete
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7257E8),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              icon: Icon(
                isComplete ? Icons.add_rounded : Icons.check_rounded,
                size: 27,
              ),
              label: Text(
                isComplete ? 'Next' : 'Done',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawingToolbar extends StatelessWidget {
  const _DrawingToolbar({
    required this.palette,
    required this.selectedColor,
    required this.brushWidth,
    required this.canUndo,
    required this.canClear,
    required this.onColorSelected,
    required this.onBrushSelected,
    required this.onUndo,
    required this.onClear,
  });

  final List<Color> palette;
  final Color selectedColor;
  final double brushWidth;
  final bool canUndo;
  final bool canClear;
  final ValueChanged<Color> onColorSelected;
  final ValueChanged<double> onBrushSelected;
  final VoidCallback onUndo;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x167257E8), blurRadius: 16),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.all(12),
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          for (final color in palette) ...<Widget>[
            _PaletteButton(
              color: color,
              selected: color == selectedColor,
              onPressed: () => onColorSelected(color),
            ),
            const SizedBox(width: 8),
          ],
          const VerticalDivider(indent: 6, endIndent: 6),
          const SizedBox(width: 8),
          for (final width in const <double>[5, 10, 18]) ...<Widget>[
            _BrushButton(
              width: width,
              color: selectedColor,
              selected: width == brushWidth,
              onPressed: () => onBrushSelected(width),
            ),
            const SizedBox(width: 8),
          ],
          const VerticalDivider(indent: 6, endIndent: 6),
          const SizedBox(width: 8),
          _RoundToolButton(
            tooltip: 'Undo last line',
            icon: Icons.undo_rounded,
            onPressed: canUndo ? onUndo : null,
          ),
          const SizedBox(width: 8),
          _RoundToolButton(
            tooltip: 'Clear picture',
            icon: Icons.delete_sweep_rounded,
            onPressed: canClear ? onClear : null,
          ),
        ],
      ),
    );
  }
}

class _PaletteButton extends StatelessWidget {
  const _PaletteButton({
    required this.color,
    required this.selected,
    required this.onPressed,
  });

  final Color color;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Choose drawing color',
      child: InkResponse(
        radius: 34,
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 64,
          height: 64,
          padding: EdgeInsets.all(selected ? 5 : 10),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.18)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: selected ? Border.all(color: color, width: 3) : null,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 7),
              ],
            ),
            child: selected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 26)
                : null,
          ),
        ),
      ),
    );
  }
}

class _BrushButton extends StatelessWidget {
  const _BrushButton({
    required this.width,
    required this.color,
    required this.selected,
    required this.onPressed,
  });

  final double width;
  final Color color;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${width.toInt()} point brush',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEDE8FF) : const Color(0xFFF6F3FA),
            borderRadius: BorderRadius.circular(20),
            border: selected
                ? Border.all(color: const Color(0xFF7257E8), width: 2)
                : null,
          ),
          child: Center(
            child: Container(
              width: width + 8,
              height: width + 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundToolButton extends StatelessWidget {
  const _RoundToolButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 64,
      child: IconButton.filledTonal(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
      ),
    );
  }
}

class _CanvasHint extends StatelessWidget {
  const _CanvasHint({required this.mission});

  final String mission;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0FF).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.gesture_rounded, size: 46, color: Color(0xFF7257E8)),
          const SizedBox(height: 4),
          Text(
            mission,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF51466A),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Slide your finger to draw',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF746A87),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawingCompleteBanner extends StatelessWidget {
  const _DrawingCompleteBanner({required this.isLastMission});

  final bool isLastMission;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'Picture complete. Wonderful drawing!',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: KidConfettiOverlay(
          active: true,
          density: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF2DBE88), Color(0xFF43C8D9)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Color(0x332DBE88), blurRadius: 12),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    isLastMission
                        ? 'Wonderful drawing!'
                        : 'Great! Try the next idea.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawingStroke {
  _DrawingStroke({
    required this.color,
    required this.width,
    required this.points,
  });

  final Color color;
  final double width;
  final List<Offset> points;
}

class _DrawingPainter extends CustomPainter {
  const _DrawingPainter(this.strokes);

  final List<_DrawingStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = const Color(0xFFEDE8F5);
    for (double x = 24; x < size.width; x += 32) {
      for (double y = 24; y < size.height; y += 32) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }

    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(
          stroke.points.first,
          stroke.width / 2,
          Paint()..color = stroke.color,
        );
        continue;
      }

      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (var index = 1; index < stroke.points.length; index++) {
        final previous = stroke.points[index - 1];
        final current = stroke.points[index];
        final midpoint = Offset(
          (previous.dx + current.dx) / 2,
          (previous.dy + current.dy) / 2,
        );
        path.quadraticBezierTo(
          previous.dx,
          previous.dy,
          midpoint.dx,
          midpoint.dy,
        );
      }
      path.lineTo(stroke.points.last.dx, stroke.points.last.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
