import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../data/pulse_parade_levels.dart';
import '../domain/level_definition.dart';
import '../domain/level_result.dart';
import '../flame/pulse_parade_game.dart';

class PulseParadeGameScreen extends StatefulWidget {
  const PulseParadeGameScreen({this.onCompleted, super.key});

  final VoidCallback? onCompleted;

  @override
  State<PulseParadeGameScreen> createState() => _PulseParadeGameScreenState();
}

class _PulseParadeGameScreenState extends State<PulseParadeGameScreen> {
  late PulseParadeGame _game;
  var _currentLevelIndex = 0;
  var _highestUnlockedLevelIndex = 0;
  var _completionReported = false;
  var _winHandledForAttempt = false;
  var _showLevelSelect = true;

  @override
  void initState() {
    super.initState();
    _game = _createGame(_currentLevelIndex);
  }

  @override
  void dispose() {
    _game.snapshot.removeListener(_handleSnapshot);
    super.dispose();
  }

  void _handleSnapshot() {
    final snapshot = _game.snapshot.value;
    if (snapshot.status != PulseLevelStatus.won || _winHandledForAttempt) {
      return;
    }

    _winHandledForAttempt = true;
    if (_currentLevelIndex == _highestUnlockedLevelIndex &&
        _highestUnlockedLevelIndex < pulseParadeLevels.length - 1) {
      setState(() {
        _highestUnlockedLevelIndex++;
      });
    }

    if (!_completionReported &&
        _currentLevelIndex == pulseParadeLevels.length - 1) {
      _completionReported = true;
      widget.onCompleted?.call();
    }
  }

  void _steer(Offset localPosition) {
    _game.steerToScreenX(localPosition.dx);
  }

  void _restart() {
    _winHandledForAttempt = false;
    _game.restart();
  }

  void _openLevel(int levelIndex) {
    if (levelIndex > _highestUnlockedLevelIndex) {
      return;
    }

    _replaceGame(levelIndex);
    setState(() {
      _showLevelSelect = false;
    });
  }

  void _openLevelSelect() {
    setState(() {
      _showLevelSelect = true;
    });
  }

  void _openNextLevel() {
    if (_currentLevelIndex >= pulseParadeLevels.length - 1) {
      return;
    }

    _replaceGame(_currentLevelIndex + 1);
    setState(() {
      _showLevelSelect = false;
    });
  }

  PulseParadeGame _createGame(int levelIndex) {
    final game = PulseParadeGame(level: pulseParadeLevels[levelIndex]);
    game.snapshot.addListener(_handleSnapshot);
    return game;
  }

  void _replaceGame(int levelIndex) {
    _game.snapshot.removeListener(_handleSnapshot);
    _currentLevelIndex = levelIndex;
    _winHandledForAttempt = false;
    _game = _createGame(levelIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (_showLevelSelect) {
      return _PulseParadeLevelSelectScreen(
        highestUnlockedLevelIndex: _highestUnlockedLevelIndex,
        onBack: () => Navigator.maybePop(context),
        onLevelSelected: _openLevel,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF101018),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanDown: (details) => _steer(details.localPosition),
                onPanUpdate: (details) => _steer(details.localPosition),
                child: GameWidget(
                  key: const ValueKey('pulse-parade-game'),
                  game: _game,
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: ValueListenableBuilder<PulseGameSnapshot>(
                valueListenable: _game.snapshot,
                builder: (context, snapshot, child) {
                  return _PulseParadeHud(
                    levelNumber: _currentLevelIndex + 1,
                    levelCount: pulseParadeLevels.length,
                    levelTitle: pulseParadeLevels[_currentLevelIndex].title,
                    snapshot: snapshot,
                    onBack: () => Navigator.maybePop(context),
                    onRestart: _restart,
                  );
                },
              ),
            ),
            ValueListenableBuilder<PulseGameSnapshot>(
              valueListenable: _game.snapshot,
              builder: (context, snapshot, child) {
                if (!snapshot.isFinished) {
                  return const SizedBox.shrink();
                }
                return _PulseParadeResultOverlay(
                  levelNumber: _currentLevelIndex + 1,
                  hasNextLevel:
                      _currentLevelIndex < pulseParadeLevels.length - 1,
                  snapshot: snapshot,
                  onRetry: _restart,
                  onLevelSelect: _openLevelSelect,
                  onNext: _openNextLevel,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseParadeHud extends StatelessWidget {
  const _PulseParadeHud({
    required this.levelNumber,
    required this.levelCount,
    required this.levelTitle,
    required this.snapshot,
    required this.onBack,
    required this.onRestart,
  });

  final int levelNumber;
  final int levelCount;
  final String levelTitle;
  final PulseGameSnapshot snapshot;
  final VoidCallback onBack;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD91B2030),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _HudIconButton(
                  tooltip: 'Back',
                  icon: Icons.arrow_back_rounded,
                  onPressed: onBack,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SparkCountPill(
                    levelNumber: levelNumber,
                    levelCount: levelCount,
                    levelTitle: levelTitle,
                    snapshot: snapshot,
                  ),
                ),
                const SizedBox(width: 10),
                _HudIconButton(
                  tooltip: 'Restart',
                  icon: Icons.refresh_rounded,
                  onPressed: onRestart,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: snapshot.progress,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                color: const Color(0xFF43F0D8),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                snapshot.message,
                key: const ValueKey('pulse-message'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFE7FFF8),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparkCountPill extends StatelessWidget {
  const _SparkCountPill({
    required this.levelNumber,
    required this.levelCount,
    required this.levelTitle,
    required this.snapshot,
  });

  final int levelNumber;
  final int levelCount;
  final String levelTitle;
  final PulseGameSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final polarityColor = switch (snapshot.polarity) {
      PulsePolarity.cyan => const Color(0xFF43F0D8),
      PulsePolarity.amber => const Color(0xFFFFC44D),
    };

    return Container(
      key: const ValueKey('pulse-count'),
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, color: polarityColor, size: 28),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${snapshot.sparkCount} sparks',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Level $levelNumber/$levelCount - $levelTitle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.66),
                    fontSize: 11,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Need ${snapshot.requiredCharge}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HudIconButton extends StatelessWidget {
  const _HudIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 52,
      child: IconButton.filledTonal(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.white.withValues(alpha: 0.14),
        ),
        icon: Icon(icon, size: 26),
      ),
    );
  }
}

class _PulseParadeResultOverlay extends StatelessWidget {
  const _PulseParadeResultOverlay({
    required this.levelNumber,
    required this.hasNextLevel,
    required this.snapshot,
    required this.onRetry,
    required this.onLevelSelect,
    required this.onNext,
  });

  final int levelNumber;
  final bool hasNextLevel;
  final PulseGameSnapshot snapshot;
  final VoidCallback onRetry;
  final VoidCallback onLevelSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final won = snapshot.status == PulseLevelStatus.won;
    final title = won ? 'Level $levelNumber charged!' : 'Circuit faded';
    final detail = won
        ? 'Delivered ${snapshot.deliveredCharge} charge.'
        : snapshot.message;

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.42),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            key: const ValueKey('pulse-result-overlay'),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FFFC),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      won
                          ? Icons.offline_bolt_rounded
                          : Icons.battery_alert_rounded,
                      color: won
                          ? const Color(0xFF1C9E76)
                          : const Color(0xFFD84C5F),
                      size: 34,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF172032),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  style: const TextStyle(
                    color: Color(0xFF536070),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const ValueKey('pulse-level-select'),
                        onPressed: onLevelSelect,
                        icon: const Icon(Icons.grid_view_rounded),
                        label: const Text('Levels'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        key: const ValueKey('pulse-retry'),
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ),
                    if (won && hasNextLevel) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          key: const ValueKey('pulse-next-level'),
                          onPressed: onNext,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Next'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseParadeLevelSelectScreen extends StatelessWidget {
  const _PulseParadeLevelSelectScreen({
    required this.highestUnlockedLevelIndex,
    required this.onBack,
    required this.onLevelSelected,
  });

  final int highestUnlockedLevelIndex;
  final VoidCallback onBack;
  final ValueChanged<int> onLevelSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101018),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF101018), Color(0xFF182236), Color(0xFF10241F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox.square(
                      dimension: 56,
                      child: IconButton.filledTonal(
                        tooltip: 'Back',
                        onPressed: onBack,
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.14),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded, size: 28),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Pulse Parade',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Choose a circuit level',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: pulseParadeLevels.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final level = pulseParadeLevels[index];
                      final unlocked = index <= highestUnlockedLevelIndex;
                      final completed = index < highestUnlockedLevelIndex;
                      return _PulseLevelTile(
                        level: level,
                        levelNumber: index + 1,
                        unlocked: unlocked,
                        completed: completed,
                        onTap: () => onLevelSelected(index),
                      );
                    },
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

class _PulseLevelTile extends StatelessWidget {
  const _PulseLevelTile({
    required this.level,
    required this.levelNumber,
    required this.unlocked,
    required this.completed,
    required this.onTap,
  });

  final PulseParadeLevel level;
  final int levelNumber;
  final bool unlocked;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = unlocked ? const Color(0xFF43F0D8) : const Color(0xFF7A8192);

    return Material(
      color: Colors.white.withValues(alpha: unlocked ? 0.1 : 0.05),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: ValueKey('pulse-level-$levelNumber'),
        borderRadius: BorderRadius.circular(20),
        onTap: unlocked ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: unlocked ? 0.22 : 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withValues(alpha: 0.7)),
                ),
                child: SizedBox.square(
                  dimension: 52,
                  child: Center(
                    child: completed
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 30,
                          )
                        : Text(
                            '$levelNumber',
                            style: TextStyle(
                              color: unlocked ? Colors.white : accent,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unlocked
                            ? Colors.white
                            : const Color(0xFF9CA4B5),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${level.startingSparkCount} sparks - node ${level.powerNode.chargeRequired}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: unlocked ? 0.68 : 0.38,
                        ),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                unlocked ? Icons.play_arrow_rounded : Icons.lock_rounded,
                color: accent,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
