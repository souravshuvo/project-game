import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/letter_audio_cue.dart';
import '../shared/kid_celebration.dart';

class BalloonPopGameScreen extends StatefulWidget {
  const BalloonPopGameScreen({
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
  int _score = 0;
  int _streak = 0;
  int _bonusPops = 0;
  int _lastScoreGain = 0;
  bool _completionReported = false;

  List<_BalloonSpec> get _balloons => _waves[_waveIndex];
  bool get _isComplete => _poppedIds.length == _balloons.length;
  bool get _isLastWave => _waveIndex == _waves.length - 1;
  int get _bonusBalloonId => ((_waveIndex + 1) * 3) % _balloons.length;

  void _playFeedback(Future<void> Function(LetterAudioCue cue) action) {
    unawaited(action(widget.audioCue).catchError((Object _) {}));
  }

  void _pop(int id) {
    if (_poppedIds.contains(id)) {
      return;
    }

    var completedNow = false;
    final isBonus = id == _bonusBalloonId;
    setState(() {
      _poppedIds.add(id);
      _streak += 1;
      _lastScoreGain = 10 + (_streak * 2) + (isBonus ? 20 : 0);
      _score += _lastScoreGain;
      if (isBonus) {
        _bonusPops += 1;
      }
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
    _score = 0;
    _streak = 0;
    _bonusPops = 0;
    _lastScoreGain = 0;
    _resetWaveState();
  }

  void _continueAfterComplete() {
    _playFeedback((cue) => cue.playTap());
    setState(() {
      if (_isLastWave) {
        _waveIndex = 0;
        _completionReported = false;
        _score = 0;
        _streak = 0;
        _bonusPops = 0;
        _lastScoreGain = 0;
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final title = Row(
                          children: [
                            const Icon(
                              Icons.bubble_chart_rounded,
                              color: Color(0xFFFF8A3D),
                              size: 30,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$popped of $total popped',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF5B4967),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        );
                        final stats = [
                          _BalloonStat(
                            icon: Icons.stars_rounded,
                            value: '$_score',
                            label: 'score',
                          ),
                          _BalloonStat(
                            icon: Icons.local_fire_department_rounded,
                            value: 'x$_streak',
                            label: 'streak',
                          ),
                          _BalloonStat(
                            icon: Icons.workspace_premium_rounded,
                            value: '$_bonusPops',
                            label: 'bonus',
                          ),
                        ];

                        if (constraints.maxWidth < 390) {
                          return Column(
                            children: [
                              title,
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  for (
                                    var index = 0;
                                    index < stats.length;
                                    index += 1
                                  ) ...[
                                    Expanded(child: stats[index]),
                                    if (index < stats.length - 1)
                                      const SizedBox(width: 8),
                                  ],
                                ],
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: title),
                            const SizedBox(width: 8),
                            ...stats.expand(
                              (stat) => [stat, const SizedBox(width: 8)],
                            ),
                          ]..removeLast(),
                        );
                      },
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
                    const SizedBox(height: 8),
                    _ScorePulse(
                      gain: _lastScoreGain,
                      streak: _streak,
                      bonusActive: !_poppedIds.contains(_bonusBalloonId),
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
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 92),
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
                          bonus: balloon.id == _bonusBalloonId,
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
                        score: _score,
                        bonusPops: _bonusPops,
                        onContinue: _continueAfterComplete,
                        onPlayNextGame: widget.onPlayNextGame,
                        nextGameTitle: widget.nextGameTitle,
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

class _BalloonStat extends StatelessWidget {
  const _BalloonStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 42, minWidth: 58),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFF8A3D), size: 20),
          const SizedBox(width: 5),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                textScaler: TextScaler.noScaling,
                style: const TextStyle(
                  color: Color(0xFF5B4967),
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                textScaler: TextScaler.noScaling,
                style: const TextStyle(
                  color: Color(0xFF7A7188),
                  fontSize: 10,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScorePulse extends StatelessWidget {
  const _ScorePulse({
    required this.gain,
    required this.streak,
    required this.bonusActive,
  });

  final int gain;
  final int streak;
  final bool bonusActive;

  @override
  Widget build(BuildContext context) {
    final message = gain == 0
        ? 'Find the glowing bonus balloon'
        : bonusActive
        ? '+$gain points • combo x$streak'
        : '+$gain points • bonus collected';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Container(
        key: ValueKey('$gain-$streak-$bonusActive'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              bonusActive
                  ? Icons.workspace_premium_rounded
                  : Icons.auto_awesome_rounded,
              color: const Color(0xFFFF8A3D),
              size: 20,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF5B4967),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalloonTile extends StatelessWidget {
  const _BalloonTile({
    required this.balloon,
    required this.popped,
    required this.bonus,
    required this.onPop,
  });

  final _BalloonSpec balloon;
  final bool popped;
  final bool bonus;
  final VoidCallback onPop;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !popped,
      label: popped
          ? 'Balloon popped'
          : bonus
          ? 'Pop bonus balloon'
          : 'Pop balloon',
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
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (bonus)
                          const Positioned(
                            top: 10,
                            right: 12,
                            child: _BonusBadge(),
                          ),
                        KidFloaty(
                          phase: balloon.id * 0.13,
                          amplitude: 4 + (balloon.id % 3),
                          sway: 2 + (balloon.id % 2),
                          child: _BalloonShape(balloon: balloon, bonus: bonus),
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

class _BonusBadge extends StatelessWidget {
  const _BonusBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFD86B),
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [BoxShadow(color: Color(0x33D98700), blurRadius: 8)],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFF875B12),
              size: 16,
            ),
            SizedBox(width: 3),
            Text(
              '+20',
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                color: Color(0xFF875B12),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalloonShape extends StatelessWidget {
  const _BalloonShape({required this.balloon, required this.bonus});

  final _BalloonSpec balloon;
  final bool bonus;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (bonus)
              Container(
                width: 98,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(48),
                  border: Border.all(color: const Color(0xFFFFD86B), width: 5),
                ),
              ),
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
    required this.score,
    required this.bonusPops,
    required this.onContinue,
    this.onPlayNextGame,
    this.nextGameTitle,
  });

  final bool isLastWave;
  final int score;
  final int bonusPops;
  final VoidCallback onContinue;
  final VoidCallback? onPlayNextGame;
  final String? nextGameTitle;

  @override
  Widget build(BuildContext context) {
    final title = isLastWave ? 'Run complete' : 'Wave cleared';
    final subtitle = isLastWave
        ? 'Final score: $score points with $bonusPops bonus pops'
        : 'Score chase: $score points so far';
    final buttonLabel = isLastWave ? 'Replay run' : 'Next wave';
    final canPlayNextGame =
        isLastWave && onPlayNextGame != null && nextGameTitle != null;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.celebration_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$score pts',
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (canPlayNextGame) ...[
                SizedBox(
                  height: 58,
                  child: FilledButton.icon(
                    key: const ValueKey('balloon-next-game-button'),
                    onPressed: onPlayNextGame,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFD66A14),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 27),
                    label: Text(
                      'Play next: $nextGameTitle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: onContinue,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                    ),
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text(
                      'Replay run',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ] else
                SizedBox(
                  height: 58,
                  child: FilledButton.icon(
                    onPressed: onContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFD66A14),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    icon: Icon(
                      isLastWave
                          ? Icons.replay_rounded
                          : Icons.arrow_forward_rounded,
                      size: 27,
                    ),
                    label: Text(
                      buttonLabel,
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
