import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/letter_audio_cue.dart';
import '../shared/kid_celebration.dart';

class BalloonPopGameScreen extends StatefulWidget {
  const BalloonPopGameScreen({
    required this.audioCue,
    this.onCompleted,
    super.key,
  });

  final LetterAudioCue audioCue;
  final VoidCallback? onCompleted;

  static int get contentCount => _BalloonPopGameScreenState.contentCount;

  @override
  State<BalloonPopGameScreen> createState() => _BalloonPopGameScreenState();
}

class _BalloonSpec {
  const _BalloonSpec({
    required this.id,
    required this.color,
    required this.icon,
  });

  final int id;
  final Color color;
  final IconData icon;
}

class _BalloonPopGameScreenState extends State<BalloonPopGameScreen> {
  static const _waves = <List<_BalloonSpec>>[
    [
      _BalloonSpec(
        id: 0,
        color: Color(0xFFEF5DA8),
        icon: Icons.favorite_rounded,
      ),
      _BalloonSpec(id: 1, color: Color(0xFF35A7FF), icon: Icons.star_rounded),
      _BalloonSpec(id: 2, color: Color(0xFFFFA928), icon: Icons.circle),
      _BalloonSpec(
        id: 3,
        color: Color(0xFF2DBE88),
        icon: Icons.hexagon_rounded,
      ),
      _BalloonSpec(id: 4, color: Color(0xFF7257E8), icon: Icons.auto_awesome),
      _BalloonSpec(
        id: 5,
        color: Color(0xFFFF7B54),
        icon: Icons.favorite_rounded,
      ),
      _BalloonSpec(id: 6, color: Color(0xFF43C8D9), icon: Icons.star_rounded),
      _BalloonSpec(id: 7, color: Color(0xFFFFC14F), icon: Icons.circle),
      _BalloonSpec(
        id: 8,
        color: Color(0xFF8D57D9),
        icon: Icons.hexagon_rounded,
      ),
      _BalloonSpec(id: 9, color: Color(0xFF30B86F), icon: Icons.auto_awesome),
    ],
    [
      _BalloonSpec(id: 0, color: Color(0xFF35A7FF), icon: Icons.circle),
      _BalloonSpec(id: 1, color: Color(0xFFFFC14F), icon: Icons.star_rounded),
      _BalloonSpec(
        id: 2,
        color: Color(0xFF2DBE88),
        icon: Icons.favorite_rounded,
      ),
      _BalloonSpec(
        id: 3,
        color: Color(0xFFFF7B54),
        icon: Icons.hexagon_rounded,
      ),
      _BalloonSpec(id: 4, color: Color(0xFF8D57D9), icon: Icons.auto_awesome),
      _BalloonSpec(id: 5, color: Color(0xFF43C8D9), icon: Icons.circle),
      _BalloonSpec(id: 6, color: Color(0xFFEF5DA8), icon: Icons.star_rounded),
      _BalloonSpec(
        id: 7,
        color: Color(0xFFFFA928),
        icon: Icons.favorite_rounded,
      ),
      _BalloonSpec(
        id: 8,
        color: Color(0xFF30B86F),
        icon: Icons.hexagon_rounded,
      ),
      _BalloonSpec(id: 9, color: Color(0xFF7257E8), icon: Icons.auto_awesome),
    ],
    [
      _BalloonSpec(id: 0, color: Color(0xFFFFA928), icon: Icons.star_rounded),
      _BalloonSpec(
        id: 1,
        color: Color(0xFF7257E8),
        icon: Icons.favorite_rounded,
      ),
      _BalloonSpec(
        id: 2,
        color: Color(0xFF43C8D9),
        icon: Icons.hexagon_rounded,
      ),
      _BalloonSpec(id: 3, color: Color(0xFFEF5DA8), icon: Icons.circle),
      _BalloonSpec(id: 4, color: Color(0xFF30B86F), icon: Icons.auto_awesome),
      _BalloonSpec(id: 5, color: Color(0xFFFF7B54), icon: Icons.star_rounded),
      _BalloonSpec(
        id: 6,
        color: Color(0xFF35A7FF),
        icon: Icons.favorite_rounded,
      ),
      _BalloonSpec(id: 7, color: Color(0xFF2DBE88), icon: Icons.circle),
      _BalloonSpec(
        id: 8,
        color: Color(0xFFFFC14F),
        icon: Icons.hexagon_rounded,
      ),
      _BalloonSpec(id: 9, color: Color(0xFF8D57D9), icon: Icons.auto_awesome),
    ],
    [
      _BalloonSpec(
        id: 0,
        color: Color(0xFF2DBE88),
        icon: Icons.hexagon_rounded,
      ),
      _BalloonSpec(id: 1, color: Color(0xFFEF5DA8), icon: Icons.star_rounded),
      _BalloonSpec(id: 2, color: Color(0xFF7257E8), icon: Icons.circle),
      _BalloonSpec(
        id: 3,
        color: Color(0xFFFFC14F),
        icon: Icons.favorite_rounded,
      ),
      _BalloonSpec(id: 4, color: Color(0xFF35A7FF), icon: Icons.auto_awesome),
      _BalloonSpec(id: 5, color: Color(0xFF30B86F), icon: Icons.star_rounded),
      _BalloonSpec(
        id: 6,
        color: Color(0xFFFF7B54),
        icon: Icons.hexagon_rounded,
      ),
      _BalloonSpec(
        id: 7,
        color: Color(0xFF43C8D9),
        icon: Icons.favorite_rounded,
      ),
      _BalloonSpec(id: 8, color: Color(0xFFFFA928), icon: Icons.circle),
      _BalloonSpec(id: 9, color: Color(0xFF8D57D9), icon: Icons.auto_awesome),
    ],
    [
      _BalloonSpec(id: 0, color: Color(0xFF8D57D9), icon: Icons.auto_awesome),
      _BalloonSpec(
        id: 1,
        color: Color(0xFF30B86F),
        icon: Icons.favorite_rounded,
      ),
      _BalloonSpec(id: 2, color: Color(0xFFFF7B54), icon: Icons.star_rounded),
      _BalloonSpec(id: 3, color: Color(0xFF43C8D9), icon: Icons.circle),
      _BalloonSpec(
        id: 4,
        color: Color(0xFFFFC14F),
        icon: Icons.hexagon_rounded,
      ),
      _BalloonSpec(id: 5, color: Color(0xFFEF5DA8), icon: Icons.auto_awesome),
      _BalloonSpec(
        id: 6,
        color: Color(0xFF35A7FF),
        icon: Icons.favorite_rounded,
      ),
      _BalloonSpec(id: 7, color: Color(0xFF7257E8), icon: Icons.star_rounded),
      _BalloonSpec(id: 8, color: Color(0xFF2DBE88), icon: Icons.circle),
      _BalloonSpec(
        id: 9,
        color: Color(0xFFFFA928),
        icon: Icons.hexagon_rounded,
      ),
    ],
  ];

  static int get contentCount => _waves.length;

  int _waveIndex = 0;
  final Set<int> _poppedIds = <int>{};
  bool _completionReported = false;

  List<_BalloonSpec> get _balloons => _waves[_waveIndex];
  bool get _isComplete => _poppedIds.length == _balloons.length;
  bool get _isLastWave => _waveIndex == _waves.length - 1;

  void _playFeedback(Future<void> Function(LetterAudioCue cue) action) {
    unawaited(action(widget.audioCue).catchError((Object _) {}));
  }

  void _pop(int id) {
    if (_poppedIds.contains(id)) {
      return;
    }

    var completedNow = false;
    setState(() {
      _poppedIds.add(id);
      completedNow = _isComplete;
    });

    if (completedNow && _isLastWave && !_completionReported) {
      _playFeedback((cue) => cue.playWin());
      _completionReported = true;
      widget.onCompleted?.call();
    } else {
      _playFeedback((cue) => cue.playReward());
    }
  }

  void _reset() {
    _playFeedback((cue) => cue.playRestart());
    _resetWaveState();
  }

  void _continueAfterComplete() {
    _playFeedback((cue) => cue.playTap());
    setState(() {
      if (_isLastWave) {
        _waveIndex = 0;
        _completionReported = false;
      } else {
        _waveIndex += 1;
      }
      _poppedIds.clear();
    });
  }

  void _resetWaveState() {
    setState(_poppedIds.clear);
  }

  @override
  Widget build(BuildContext context) {
    final popped = _poppedIds.length;
    final total = _balloons.length;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9F8FF), Color(0xFFFFF2D9), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _BalloonHeader(
                wave: _waveIndex + 1,
                totalWaves: _waves.length,
                onReset: _reset,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.bubble_chart_rounded,
                          color: Color(0xFFFF8A3D),
                          size: 30,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$popped of $total popped',
                          style: const TextStyle(
                            color: Color(0xFF5B4967),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: popped / total,
                        minHeight: 12,
                        backgroundColor: Colors.white.withValues(alpha: 0.86),
                        color: const Color(0xFFFF8A3D),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 760
                        ? 5
                        : constraints.maxWidth >= 520
                        ? 4
                        : 2;

                    return GridView.builder(
                      key: const ValueKey('balloon-grid'),
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: _balloons.length,
                      itemBuilder: (context, index) {
                        final balloon = _balloons[index];
                        return _BalloonTile(
                          balloon: balloon,
                          popped: _poppedIds.contains(balloon.id),
                          onPop: () => _pop(balloon.id),
                        );
                      },
                    );
                  },
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: _isComplete
                    ? _BalloonCompletePanel(
                        isLastWave: _isLastWave,
                        onContinue: _continueAfterComplete,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalloonHeader extends StatelessWidget {
  const _BalloonHeader({
    required this.wave,
    required this.totalWaves,
    required this.onReset,
  });

  final int wave;
  final int totalWaves;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
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
                  'Balloon Pop',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF3F315C),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Tap every balloon • Wave $wave/$totalWaves',
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
          SizedBox.square(
            dimension: 64,
            child: IconButton.filled(
              tooltip: 'Restart balloons',
              onPressed: onReset,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A3D),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalloonTile extends StatelessWidget {
  const _BalloonTile({
    required this.balloon,
    required this.popped,
    required this.onPop,
  });

  final _BalloonSpec balloon;
  final bool popped;
  final VoidCallback onPop;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !popped,
      label: popped ? 'Balloon popped' : 'Pop balloon',
      child: Material(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          key: ValueKey('balloon-${balloon.id}'),
          borderRadius: BorderRadius.circular(30),
          onTap: popped ? null : onPop,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              );
              return ScaleTransition(
                scale: curved,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: popped
                ? Center(
                    key: ValueKey('burst'),
                    child: KidPopBurst(
                      color: balloon.color,
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFFFB72B),
                        size: 72,
                      ),
                    ),
                  )
                : Center(
                    key: ValueKey('balloon'),
                    child: KidFloaty(
                      phase: balloon.id * 0.13,
                      amplitude: 4 + (balloon.id % 3),
                      sway: 2 + (balloon.id % 2),
                      child: _BalloonShape(balloon: balloon),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _BalloonShape extends StatelessWidget {
  const _BalloonShape({required this.balloon});

  final _BalloonSpec balloon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 82,
              height: 104,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white.withValues(alpha: 0.38), balloon.color],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(44),
                  topRight: Radius.circular(44),
                  bottomLeft: Radius.circular(38),
                  bottomRight: Radius.circular(38),
                ),
                boxShadow: [
                  BoxShadow(
                    color: balloon.color.withValues(alpha: 0.28),
                    offset: const Offset(0, 8),
                    blurRadius: 14,
                  ),
                ],
              ),
            ),
            Icon(balloon.icon, color: Colors.white, size: 36),
          ],
        ),
        Transform.translate(
          offset: const Offset(0, -2),
          child: Icon(
            Icons.change_history_rounded,
            color: balloon.color,
            size: 20,
          ),
        ),
        Container(width: 2, height: 24, color: const Color(0xFFB8AFC7)),
      ],
    );
  }
}

class _BalloonCompletePanel extends StatelessWidget {
  const _BalloonCompletePanel({
    required this.isLastWave,
    required this.onContinue,
  });

  final bool isLastWave;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: const ValueKey('balloon-complete-panel'),
      borderRadius: BorderRadius.circular(28),
      child: KidConfettiOverlay(
        active: true,
        density: 30,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8A3D), Color(0xFFFFC14F)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(color: Color(0x33FF8A3D), blurRadius: 15),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(
                Icons.celebration_rounded,
                color: Colors.white,
                size: 38,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Pop! You cleared the sky!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(
                height: 62,
                child: FilledButton.icon(
                  onPressed: onContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFD66A14),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  icon: Icon(
                    isLastWave
                        ? Icons.replay_rounded
                        : Icons.arrow_forward_rounded,
                    size: 27,
                  ),
                  label: Text(
                    isLastWave ? 'Again' : 'Next',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
