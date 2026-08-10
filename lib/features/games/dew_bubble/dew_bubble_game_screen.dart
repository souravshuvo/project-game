import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'data/dew_levels.dart';
import 'domain/attach_solver.dart';
import 'domain/bubble_color.dart';
import 'domain/bubble_grid.dart';
import 'domain/bubble_level.dart';
import 'domain/grid_position.dart';
import '../../tracing/data/progress_repository.dart';

class DewBubbleGameScreen extends StatefulWidget {
  const DewBubbleGameScreen({
    required this.progressRepository,
    this.onCompleted,
    super.key,
  });

  final ProgressRepository progressRepository;
  final VoidCallback? onCompleted;

  @override
  State<DewBubbleGameScreen> createState() => _DewBubbleGameScreenState();
}

enum _DewPlayResult { won, lost }

enum _BubbleEffectKind { pop, drop }

const _minimumUpwardAim = 0.28;
const _maxTickSeconds = 0.033;
const _projectileSpeed = 620.0;
const _neighborAttachDistance = 2.45;
const _topAttachDistance = 1.05;
const _popEffectDuration = 0.46;
const _dropEffectDuration = 0.72;
const _scoreEffectDuration = 0.82;

class _Projectile {
  const _Projectile({
    required this.color,
    required this.position,
    required this.direction,
    this.bounces = 0,
  });

  final DewBubbleColor color;
  final Offset position;
  final Offset direction;
  final int bounces;
}

class _BubbleEffect {
  _BubbleEffect({
    required this.id,
    required this.kind,
    required this.color,
    required this.origin,
  });

  final int id;
  final _BubbleEffectKind kind;
  final DewBubbleColor color;
  final Offset origin;
  double age = 0;

  double get duration => switch (kind) {
    _BubbleEffectKind.pop => _popEffectDuration,
    _BubbleEffectKind.drop => _dropEffectDuration,
  };
}

class _ScoreFloatEffect {
  _ScoreFloatEffect({
    required this.id,
    required this.label,
    required this.origin,
    required this.color,
  });

  final int id;
  final String label;
  final Offset origin;
  final Color color;
  double age = 0;
}

class _BoardResolveFeedback {
  const _BoardResolveFeedback({
    this.popped = false,
    this.dropped = false,
    this.won = false,
    this.lost = false,
  });

  final bool popped;
  final bool dropped;
  final bool won;
  final bool lost;
}

class _DewBubbleGameScreenState extends State<DewBubbleGameScreen>
    with SingleTickerProviderStateMixin {
  final _attachSolver = const BubbleAttachSolver();
  final List<_BubbleEffect> _bubbleEffects = <_BubbleEffect>[];
  final List<_ScoreFloatEffect> _scoreEffects = <_ScoreFloatEffect>[];
  final Map<String, int> _bestScores = <String, int>{};
  final Map<String, int> _bestStars = <String, int>{};
  late final Ticker _ticker;
  late BubbleGrid _grid;
  late DewBubbleColor _currentColor;
  late DewBubbleColor _nextColor;

  int _shotsRemaining = 0;
  int _score = 0;
  int _levelIndex = 0;
  int _highestUnlockedLevelIndex = 0;
  int _queueIndex = 0;
  int _earnedStars = 0;
  bool _isAiming = false;
  bool _showLevelSelect = true;
  bool _completionReported = false;
  Offset? _aimTarget;
  Duration? _lastTick;
  _Projectile? _projectile;
  _DewBoardGeometry? _lastGeometry;
  _DewPlayResult? _result;
  int _nextEffectId = 0;

  BubbleLevel get _level => dewBubbleLevels[_levelIndex];

  bool get _hasNextLevel => _levelIndex < dewBubbleLevels.length - 1;

  bool _isLevelUnlocked(int index) => index <= _highestUnlockedLevelIndex;

  int _bestScoreForLevel(String levelId) => _bestScores[levelId] ?? 0;

  int _bestStarsForLevel(String levelId) => _bestStars[levelId] ?? 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _syncSavedProgress();
    _resetLevel(notify: false);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _resetLevel({bool notify = true}) {
    _loadLevel(_levelIndex, notify: notify);
  }

  void _syncSavedProgress() {
    _highestUnlockedLevelIndex = widget
        .progressRepository
        .dewBubbleHighestUnlockedLevelIndex
        .clamp(0, dewBubbleLevels.length - 1);
    _bestScores
      ..clear()
      ..addEntries(
        dewBubbleLevels.map(
          (level) => MapEntry(
            level.id,
            widget.progressRepository.dewBubbleBestScore(level.id),
          ),
        ),
      );
    _bestStars
      ..clear()
      ..addEntries(
        dewBubbleLevels.map(
          (level) => MapEntry(
            level.id,
            widget.progressRepository.dewBubbleBestStars(level.id),
          ),
        ),
      );
  }

  void _loadLevel(int levelIndex, {bool notify = true}) {
    final safeLevelIndex = math.max(
      0,
      math.min(
        levelIndex,
        math.min(_highestUnlockedLevelIndex, dewBubbleLevels.length - 1),
      ),
    );

    void reset() {
      _levelIndex = safeLevelIndex;
      final level = _level;
      _grid = level.createGrid();
      _shotsRemaining = level.shots;
      _score = 0;
      _queueIndex = 0;
      _earnedStars = 0;
      _currentColor = level.bubbleQueue.first;
      _nextColor = level.bubbleQueue[1 % level.bubbleQueue.length];
      _isAiming = false;
      _completionReported = false;
      _aimTarget = null;
      _lastTick = null;
      _projectile = null;
      _bubbleEffects.clear();
      _scoreEffects.clear();
      _result = null;
      _nextEffectId = 0;
    }

    if (_ticker.isActive) {
      _ticker.stop();
    }

    if (notify) {
      setState(reset);
    } else {
      reset();
    }
  }

  void _startLevel(int levelIndex) {
    if (!_isLevelUnlocked(levelIndex)) {
      return;
    }
    _showLevelSelect = false;
    _loadLevel(levelIndex);
  }

  void _openLevelSelect() {
    if (_ticker.isActive) {
      _ticker.stop();
    }
    setState(() {
      _showLevelSelect = true;
      _isAiming = false;
      _aimTarget = null;
      _projectile = null;
      _bubbleEffects.clear();
      _scoreEffects.clear();
      _lastTick = null;
    });
  }

  void _goToNextLevel() {
    if (!_hasNextLevel) {
      _openLevelSelect();
      return;
    }
    _startLevel(_levelIndex + 1);
  }

  void _onTick(Duration elapsed) {
    final lastTick = _lastTick;
    _lastTick = elapsed;
    if (lastTick == null) {
      return;
    }

    final dt = math.min(
      _maxTickSeconds,
      (elapsed - lastTick).inMicroseconds / Duration.microsecondsPerSecond,
    );

    final effectsChanged = _advanceEffects(dt);
    final projectile = _projectile;
    final geometry = _lastGeometry;
    if (projectile == null || geometry == null || _result != null) {
      if (effectsChanged) {
        setState(() {});
      }
      _stopTickerIfIdle();
      return;
    }

    var remainingDistance = _projectileSpeed * dt;
    var movedProjectile = projectile;

    while (remainingDistance > 0) {
      final distance = math.min(remainingDistance, _trajectoryStep(geometry));
      final next = _advanceTrajectoryStep(
        grid: _grid,
        geometry: geometry,
        position: movedProjectile.position,
        direction: movedProjectile.direction,
        distance: distance,
        bounces: movedProjectile.bounces,
      );

      movedProjectile = _Projectile(
        color: projectile.color,
        position: next.position,
        direction: next.direction,
        bounces: next.bounces,
      );

      if (next.reachedTop) {
        _attachProjectile(
          projectile: movedProjectile,
          geometry: geometry,
          fromTop: true,
        );
        return;
      }

      final hit = next.hitPosition;
      if (hit != null) {
        _attachProjectile(
          projectile: movedProjectile,
          geometry: geometry,
          hitPosition: hit,
        );
        return;
      }

      remainingDistance -= distance;
    }

    setState(() {
      _projectile = movedProjectile;
    });
  }

  bool _advanceEffects(double dt) {
    if (_bubbleEffects.isEmpty && _scoreEffects.isEmpty) {
      return false;
    }

    for (final effect in _bubbleEffects) {
      effect.age += dt;
    }
    for (final effect in _scoreEffects) {
      effect.age += dt;
    }

    _bubbleEffects.removeWhere((effect) => effect.age >= effect.duration);
    _scoreEffects.removeWhere((effect) => effect.age >= _scoreEffectDuration);
    return true;
  }

  void _ensureTickerRunning() {
    if (!_ticker.isActive) {
      _lastTick = null;
      _ticker.start();
    }
  }

  void _stopTickerIfIdle() {
    if (_projectile == null &&
        _bubbleEffects.isEmpty &&
        _scoreEffects.isEmpty &&
        _ticker.isActive) {
      _ticker.stop();
      _lastTick = null;
    }
  }

  void _setAimTarget(Offset localPosition) {
    if (_result != null || _projectile != null || _shotsRemaining <= 0) {
      return;
    }

    setState(() {
      _isAiming = true;
      _aimTarget = localPosition;
    });
  }

  void _fire(_DewBoardGeometry geometry) {
    if (_result != null ||
        _projectile != null ||
        _shotsRemaining <= 0 ||
        _aimTarget == null) {
      return;
    }

    final direction = _aimDirectionFromTarget(
      geometry.shooterCenter,
      _aimTarget!,
    );
    if (direction == null) {
      setState(() {
        _isAiming = false;
        _aimTarget = null;
      });
      return;
    }

    setState(() {
      _shotsRemaining--;
      _isAiming = false;
      _aimTarget = null;
      _projectile = _Projectile(
        color: _currentColor,
        position: geometry.shooterCenter,
        direction: direction,
      );
    });
    _playDewCue(SystemSoundType.click);

    _ensureTickerRunning();
  }

  void _attachProjectile({
    required _Projectile projectile,
    required _DewBoardGeometry geometry,
    GridPosition? hitPosition,
    bool fromTop = false,
  }) {
    final attachPosition = fromTop
        ? _nearestTopAttachPosition(projectile.position, geometry)
        : _nearestNeighborAttachPosition(
            hitPosition!,
            projectile.position,
            geometry,
          );

    if (attachPosition == null) {
      setState(() {
        _projectile = null;
        if (_shotsRemaining <= 0) {
          _result = _DewPlayResult.lost;
        } else {
          _advanceQueueIfPlaying();
        }
      });
      _ticker.stop();
      _lastTick = null;
      return;
    }

    late final _BoardResolveFeedback feedback;
    setState(() {
      _projectile = null;
      _grid.setColor(attachPosition, projectile.color);
      feedback = _resolveBoardAfterAttach(attachPosition, geometry);
      _advanceQueueIfPlaying();
    });
    _playResolveFeedback(feedback);

    _stopTickerIfIdle();
  }

  GridPosition? _nearestNeighborAttachPosition(
    GridPosition hitPosition,
    Offset impact,
    _DewBoardGeometry geometry,
  ) {
    return _attachSolver.nearestEmptyNeighbor(
      grid: _grid,
      hitPosition: hitPosition,
      distanceToImpact: (position) =>
          _distanceToCell(position, impact, geometry),
      maxDistance: geometry.radius * _neighborAttachDistance,
    );
  }

  GridPosition? _nearestTopAttachPosition(
    Offset impact,
    _DewBoardGeometry geometry,
  ) {
    return _attachSolver.nearestTopCell(
      grid: _grid,
      distanceToImpact: (position) =>
          _distanceToCell(position, impact, geometry),
      maxDistance: geometry.radius * _topAttachDistance,
    );
  }

  double _distanceToCell(
    GridPosition position,
    Offset point,
    _DewBoardGeometry geometry,
  ) {
    return (geometry.centerFor(position) - point).distance;
  }

  _BoardResolveFeedback _resolveBoardAfterAttach(
    GridPosition attachPosition,
    _DewBoardGeometry geometry,
  ) {
    var popped = false;
    var dropped = false;
    var won = false;
    var lost = false;
    final matched = _grid.connectedSameColor(attachPosition);
    if (matched.length >= 3) {
      _addBubbleEffects(
        positions: matched,
        kind: _BubbleEffectKind.pop,
        geometry: geometry,
      );
      _grid.removeAll(matched);
      _score += matched.length * 10;
      _addScoreEffect(
        '+${matched.length * 10}',
        geometry.centerFor(attachPosition).translate(0, -geometry.radius),
        const Color(0xFF2CB9A0),
      );
      popped = true;

      final floating = _grid.floatingPositions();
      if (floating.isNotEmpty) {
        _addBubbleEffects(
          positions: floating,
          kind: _BubbleEffectKind.drop,
          geometry: geometry,
        );
        _grid.removeAll(floating);
        _score += floating.length * 20;
        _addScoreEffect(
          '+${floating.length * 20}',
          _centerOf(floating, geometry).translate(0, geometry.radius),
          const Color(0xFFFFA928),
        );
        dropped = true;
      }
    }

    if (_grid.isCleared) {
      _score += 100 + (_shotsRemaining * 50);
      _earnedStars = _starsForWin(_level.shots, _shotsRemaining);
      _addScoreEffect(
        '+${100 + (_shotsRemaining * 50)}',
        geometry.shooterCenter.translate(0, -geometry.radius * 2.2),
        const Color(0xFF7257E8),
      );
      _result = _DewPlayResult.won;
      _recordLevelWin(_score, _earnedStars);
      won = true;
      if (_levelIndex == dewBubbleLevels.length - 1 && !_completionReported) {
        _completionReported = true;
        widget.onCompleted?.call();
      }
    } else if (_shotsRemaining <= 0) {
      _result = _DewPlayResult.lost;
      lost = true;
    }

    return _BoardResolveFeedback(
      popped: popped,
      dropped: dropped,
      won: won,
      lost: lost,
    );
  }

  int _starsForWin(int totalShots, int shotsRemaining) {
    final remainingRatio = totalShots == 0 ? 0 : shotsRemaining / totalShots;
    if (remainingRatio >= 0.4) {
      return 3;
    }
    if (remainingRatio >= 0.2) {
      return 2;
    }
    return 1;
  }

  void _recordLevelWin(int score, int stars) {
    final level = _level;
    final nextUnlockIndex = math.min(
      _levelIndex + 1,
      dewBubbleLevels.length - 1,
    );
    _highestUnlockedLevelIndex = math.max(
      _highestUnlockedLevelIndex,
      nextUnlockIndex,
    );
    _bestScores[level.id] = math.max(_bestScoreForLevel(level.id), score);
    _bestStars[level.id] = math.max(_bestStarsForLevel(level.id), stars);
    unawaited(
      widget.progressRepository.recordDewBubbleLevelWin(
        levelIndex: _levelIndex,
        levelId: level.id,
        score: score,
        stars: stars,
      ),
    );
  }

  void _addBubbleEffects({
    required Iterable<GridPosition> positions,
    required _BubbleEffectKind kind,
    required _DewBoardGeometry geometry,
  }) {
    for (final position in positions) {
      final color = _grid.colorAt(position);
      if (color == null) {
        continue;
      }
      _bubbleEffects.add(
        _BubbleEffect(
          id: _nextEffectId++,
          kind: kind,
          color: color,
          origin: geometry.centerFor(position),
        ),
      );
    }
  }

  void _addScoreEffect(String label, Offset origin, Color color) {
    _scoreEffects.add(
      _ScoreFloatEffect(
        id: _nextEffectId++,
        label: label,
        origin: origin,
        color: color,
      ),
    );
  }

  Offset _centerOf(
    Iterable<GridPosition> positions,
    _DewBoardGeometry geometry,
  ) {
    var count = 0;
    var total = Offset.zero;
    for (final position in positions) {
      total += geometry.centerFor(position);
      count++;
    }
    return count == 0 ? geometry.shooterCenter : total / count.toDouble();
  }

  void _playResolveFeedback(_BoardResolveFeedback feedback) {
    if (feedback.won || feedback.lost) {
      _playDewCue(SystemSoundType.alert);
      return;
    }
    if (feedback.popped || feedback.dropped) {
      _playDewCue(SystemSoundType.click);
    }
  }

  void _playDewCue(SystemSoundType type) {
    if (!widget.progressRepository.soundEnabled) {
      return;
    }
    unawaited(SystemSound.play(type));
  }

  void _advanceQueueIfPlaying() {
    if (_result != null) {
      return;
    }

    _queueIndex++;
    final queue = _level.bubbleQueue;
    _currentColor = queue[_queueIndex % queue.length];
    _nextColor = queue[(_queueIndex + 1) % queue.length];
  }

  @override
  Widget build(BuildContext context) {
    if (_showLevelSelect) {
      return _DewLevelSelectScreen(
        levels: dewBubbleLevels,
        highestUnlockedLevelIndex: _highestUnlockedLevelIndex,
        bestScoreFor: _bestScoreForLevel,
        bestStarsFor: _bestStarsForLevel,
        onBack: () => Navigator.maybePop(context),
        onSelectLevel: _startLevel,
      );
    }

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE7FAFF), Color(0xFFF7F0FF), Color(0xFFFFFCF3)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _DewBubbleHeader(
                title: _level.title,
                levelNumber: _levelIndex + 1,
                levelCount: dewBubbleLevels.length,
                onSelectLevel: _openLevelSelect,
                onRestart: _resetLevel,
              ),
              _DewBubbleHud(
                shotsRemaining: _shotsRemaining,
                score: _score,
                nextColor: _nextColor,
              ),
              Expanded(child: _buildPlayArea()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final geometry = _DewBoardGeometry.fromSize(size, _grid);
        _lastGeometry = geometry;

        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) => _setAimTarget(details.localPosition),
              onPanUpdate: (details) => _setAimTarget(details.localPosition),
              onPanEnd: (_) => _fire(geometry),
              child: CustomPaint(
                key: const ValueKey('dew-bubble-playfield'),
                size: Size.infinite,
                painter: _DewBubblePainter(
                  grid: _grid,
                  geometry: geometry,
                  currentColor: _currentColor,
                  projectile: _projectile,
                  bubbleEffects: List<_BubbleEffect>.unmodifiable(
                    _bubbleEffects,
                  ),
                  scoreEffects: List<_ScoreFloatEffect>.unmodifiable(
                    _scoreEffects,
                  ),
                  isAiming: _isAiming,
                  aimTarget: _aimTarget,
                ),
              ),
            ),
            if (_result != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _DewResultPanel(
                  result: _result!,
                  score: _score,
                  stars: _earnedStars,
                  onRestart: _resetLevel,
                  onLevelSelect: _openLevelSelect,
                  hasNextLevel: _hasNextLevel,
                  onNextLevel: _goToNextLevel,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DewLevelSelectScreen extends StatelessWidget {
  const _DewLevelSelectScreen({
    required this.levels,
    required this.highestUnlockedLevelIndex,
    required this.bestScoreFor,
    required this.bestStarsFor,
    required this.onBack,
    required this.onSelectLevel,
  });

  final List<BubbleLevel> levels;
  final int highestUnlockedLevelIndex;
  final int Function(String levelId) bestScoreFor;
  final int Function(String levelId) bestStarsFor;
  final VoidCallback onBack;
  final ValueChanged<int> onSelectLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE7FAFF), Color(0xFFF7F0FF), Color(0xFFFFFCF3)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      SizedBox.square(
                        dimension: 60,
                        child: IconButton.filledTonal(
                          tooltip: 'Back',
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back_rounded, size: 30),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dew Bubble Garden',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: const Color(0xFF31425E),
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const Text(
                              'Choose an unlocked garden',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF68758B),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final level = levels[index];
                    final unlocked = index <= highestUnlockedLevelIndex;
                    return _DewLevelTile(
                      level: level,
                      levelNumber: index + 1,
                      unlocked: unlocked,
                      bestScore: bestScoreFor(level.id),
                      bestStars: bestStarsFor(level.id),
                      onTap: unlocked ? () => onSelectLevel(index) : null,
                    );
                  }, childCount: levels.length),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 260,
                    mainAxisExtent: 178,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
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

class _DewLevelTile extends StatelessWidget {
  const _DewLevelTile({
    required this.level,
    required this.levelNumber,
    required this.unlocked,
    required this.bestScore,
    required this.bestStars,
    required this.onTap,
  });

  final BubbleLevel level;
  final int levelNumber;
  final bool unlocked;
  final int bestScore;
  final int bestStars;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = unlocked
        ? const [Color(0xFF2CB9A0), Color(0xFF67B8F7)]
        : const [Color(0xFFB8C2CE), Color(0xFFDDE4EA)];
    final foreground = unlocked ? Colors.white : const Color(0xFF6C7886);

    return Semantics(
      button: unlocked,
      enabled: unlocked,
      label: unlocked
          ? 'Level $levelNumber, ${level.title}'
          : 'Level $levelNumber locked',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: unlocked ? 0.24 : 0.08),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            unlocked ? Icons.spa_rounded : Icons.lock_rounded,
                            color: foreground,
                            size: 28,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$levelNumber',
                        style: TextStyle(
                          color: foreground.withValues(alpha: 0.9),
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    level.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (unlocked)
                    Row(
                      children: [
                        ...List.generate(3, (index) {
                          return Icon(
                            index < bestStars
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.white,
                            size: 20,
                          );
                        }),
                        const Spacer(),
                        Text(
                          bestScore == 0 ? 'New' : '$bestScore',
                          style: TextStyle(
                            color: foreground.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Win earlier levels',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w800,
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

class _DewBubbleHeader extends StatelessWidget {
  const _DewBubbleHeader({
    required this.title,
    required this.levelNumber,
    required this.levelCount,
    required this.onSelectLevel,
    required this.onRestart,
  });

  final String title;
  final int levelNumber;
  final int levelCount;
  final VoidCallback onSelectLevel;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 60,
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
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF31425E),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Prototype visuals',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF68758B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Level $levelNumber of $levelCount',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8290A3),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          SizedBox.square(
            dimension: 56,
            child: IconButton.filledTonal(
              tooltip: 'Choose level',
              onPressed: onSelectLevel,
              icon: const Icon(Icons.grid_view_rounded, size: 28),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox.square(
            dimension: 56,
            child: IconButton.filled(
              tooltip: 'Restart level',
              onPressed: onRestart,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF2CB9A0),
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

class _DewBubbleHud extends StatelessWidget {
  const _DewBubbleHud({
    required this.shotsRemaining,
    required this.score,
    required this.nextColor,
  });

  final int shotsRemaining;
  final int score;
  final DewBubbleColor nextColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _HudChip(
              icon: Icons.adjust_rounded,
              label: 'Shots',
              value: '$shotsRemaining',
              color: const Color(0xFF3F8FEF),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _HudChip(
              icon: Icons.star_rounded,
              label: 'Score',
              value: '$score',
              color: const Color(0xFFFFA928),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: _NextBubbleChip(nextColor: nextColor)),
        ],
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF697187),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF34415F),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextBubbleChip extends StatelessWidget {
  const _NextBubbleChip({required this.nextColor});

  final DewBubbleColor nextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _BubbleDot(color: nextColor),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Next',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF697187),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Dew',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF34415F),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleDot extends StatelessWidget {
  const _BubbleDot({required this.color});

  final DewBubbleColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _bubbleColor(color),
        shape: BoxShape.circle,
      ),
      child: Text(
        dewBubbleColorToken(color),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DewResultPanel extends StatelessWidget {
  const _DewResultPanel({
    required this.result,
    required this.score,
    required this.stars,
    required this.onRestart,
    required this.onLevelSelect,
    required this.hasNextLevel,
    required this.onNextLevel,
  });

  final _DewPlayResult result;
  final int score;
  final int stars;
  final VoidCallback onRestart;
  final VoidCallback onLevelSelect;
  final bool hasNextLevel;
  final VoidCallback onNextLevel;

  @override
  Widget build(BuildContext context) {
    final won = result == _DewPlayResult.won;
    final color = won ? const Color(0xFF2CB9A0) : const Color(0xFFEC6F66);

    return Material(
      color: Colors.white,
      elevation: 8,
      shadowColor: color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  won ? Icons.celebration_rounded : Icons.replay_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    won ? 'Garden cleared!' : 'Try again',
                    style: const TextStyle(
                      color: Color(0xFF34415F),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Score $score',
                    style: const TextStyle(
                      color: Color(0xFF68758B),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (won)
                    Row(
                      children: List.generate(3, (index) {
                        return Icon(
                          index < stars
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFFFA928),
                          size: 22,
                        );
                      }),
                    ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (won && hasNextLevel) ...[
                  FilledButton(
                    onPressed: onNextLevel,
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(84, 46),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton(
                  onPressed: won ? onLevelSelect : onRestart,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    minimumSize: const Size(84, 46),
                    side: BorderSide(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    won ? 'Levels' : 'Restart',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DewBubblePainter extends CustomPainter {
  const _DewBubblePainter({
    required this.grid,
    required this.geometry,
    required this.currentColor,
    required this.projectile,
    required this.bubbleEffects,
    required this.scoreEffects,
    required this.isAiming,
    required this.aimTarget,
  });

  final BubbleGrid grid;
  final _DewBoardGeometry geometry;
  final DewBubbleColor currentColor;
  final _Projectile? projectile;
  final List<_BubbleEffect> bubbleEffects;
  final List<_ScoreFloatEffect> scoreEffects;
  final bool isAiming;
  final Offset? aimTarget;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBoardGlow(canvas);
    _drawAimGuide(canvas);
    _drawGrid(canvas);
    _drawEffects(canvas);
    _drawShooter(canvas);

    final activeProjectile = projectile;
    if (activeProjectile != null) {
      _drawBubble(
        canvas,
        activeProjectile.position,
        geometry.radius,
        activeProjectile.color,
      );
    }
  }

  void _drawBoardGlow(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(
      geometry.left - 8,
      geometry.top - 8,
      geometry.boardWidth + 16,
      geometry.boardHeight + 18,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(28)),
      paint,
    );
  }

  void _drawAimGuide(Canvas canvas) {
    final target = aimTarget;
    if (!isAiming || target == null || projectile != null) {
      return;
    }

    final direction = _aimDirectionFromTarget(geometry.shooterCenter, target);
    if (direction == null) {
      return;
    }

    final paint = Paint()
      ..color = const Color(0xFF31425E).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final samples = _traceAimSamples(grid, geometry, direction);
    for (var index = 0; index < samples.length; index += 5) {
      canvas.drawCircle(samples[index], 3.2, paint);
    }

    if (samples.isNotEmpty) {
      canvas.drawCircle(
        samples.last,
        geometry.radius * 0.38,
        Paint()
          ..color = const Color(0xFF31425E).withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );
    }
  }

  void _drawGrid(Canvas canvas) {
    final emptyPaint = Paint()
      ..color = const Color(0xFF31425E).withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var row = 0; row < grid.rows; row++) {
      for (var column = 0; column < grid.columns; column++) {
        final position = GridPosition(row, column);
        final center = geometry.centerFor(position);
        final color = grid.colorAt(position);
        if (color == null) {
          canvas.drawCircle(center, geometry.radius * 0.82, emptyPaint);
        } else {
          _drawBubble(canvas, center, geometry.radius, color);
        }
      }
    }
  }

  void _drawShooter(Canvas canvas) {
    final basePaint = Paint()..color = const Color(0xFF31425E);
    final cupPaint = Paint()..color = const Color(0xFFFFFFFF);
    final center = geometry.shooterCenter;

    canvas.drawCircle(
      center.translate(0, 10),
      geometry.radius * 1.32,
      basePaint,
    );
    canvas.drawCircle(center.translate(0, 4), geometry.radius * 1.12, cupPaint);
    _drawBubble(canvas, center, geometry.radius, currentColor);
  }

  void _drawEffects(Canvas canvas) {
    for (final effect in bubbleEffects) {
      final progress = (effect.age / effect.duration).clamp(0.0, 1.0);
      switch (effect.kind) {
        case _BubbleEffectKind.pop:
          _drawPopEffect(canvas, effect, progress);
        case _BubbleEffectKind.drop:
          _drawDropEffect(canvas, effect, progress);
      }
    }

    for (final effect in scoreEffects) {
      _drawScoreEffect(canvas, effect);
    }
  }

  void _drawPopEffect(Canvas canvas, _BubbleEffect effect, double progress) {
    final eased = Curves.easeOutCubic.transform(progress);
    final opacity = (1 - progress).clamp(0.0, 1.0);
    final center = effect.origin;
    final color = _bubbleColor(effect.color);

    _drawBubble(
      canvas,
      center,
      geometry.radius * (1 + (eased * 0.34)),
      effect.color,
      opacity: opacity,
    );

    final ringPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(
      center,
      geometry.radius * (0.82 + (eased * 1.18)),
      ringPaint,
    );

    final sparkPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    for (var index = 0; index < 8; index++) {
      final angle = (index / 8) * math.pi * 2;
      final direction = Offset(math.cos(angle), math.sin(angle));
      final sparkCenter =
          center + (direction * geometry.radius * (0.72 + eased));
      canvas.drawCircle(
        sparkCenter,
        2.4 + (index.isEven ? 1.0 : 0),
        sparkPaint,
      );
    }
  }

  void _drawDropEffect(Canvas canvas, _BubbleEffect effect, double progress) {
    final eased = Curves.easeInCubic.transform(progress);
    final drift = math.sin(effect.id * 1.7) * geometry.radius * 0.42;
    final fall = geometry.radius * (3.8 + (effect.id % 3));
    final center = effect.origin + Offset(drift * progress, fall * eased);
    final opacity = (1 - (progress * 0.88)).clamp(0.0, 1.0);
    final scale = 1 - (progress * 0.25);

    _drawBubble(
      canvas,
      center,
      geometry.radius * scale,
      effect.color,
      opacity: opacity,
    );
  }

  void _drawScoreEffect(Canvas canvas, _ScoreFloatEffect effect) {
    final progress = (effect.age / _scoreEffectDuration).clamp(0.0, 1.0);
    final eased = Curves.easeOutCubic.transform(progress);
    final opacity = (1 - progress).clamp(0.0, 1.0);
    final position = effect.origin.translate(0, -geometry.radius * 1.2 * eased);

    final textPainter = TextPainter(
      text: TextSpan(
        text: effect.label,
        style: TextStyle(
          color: effect.color.withValues(alpha: opacity),
          fontSize: (geometry.radius * 0.78).clamp(13.0, 21.0),
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              color: Colors.white.withValues(alpha: opacity),
              blurRadius: 8,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      position - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawBubble(
    Canvas canvas,
    Offset center,
    double radius,
    DewBubbleColor color, {
    double opacity = 1,
  }) {
    final alpha = opacity.clamp(0.0, 1.0);
    final fill = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.42, -0.48),
        radius: 0.92,
        colors: [
          Colors.white.withValues(alpha: 0.72 * alpha),
          _bubbleColor(color).withValues(alpha: alpha),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, fill);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      center.translate(-radius * 0.28, -radius * 0.28),
      radius * 0.2,
      Paint()..color = Colors.white.withValues(alpha: 0.74 * alpha),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: dewBubbleColorToken(color),
        style: TextStyle(
          color: Colors.white.withValues(alpha: alpha),
          fontSize: radius * 0.82,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _DewBubblePainter oldDelegate) => true;
}

class _DewBoardGeometry {
  const _DewBoardGeometry({
    required this.size,
    required this.rows,
    required this.columns,
    required this.radius,
    required this.left,
    required this.top,
    required this.shooterCenter,
  });

  factory _DewBoardGeometry.fromSize(Size size, BubbleGrid grid) {
    final radiusByWidth = (size.width - 32) / ((grid.columns * 2) + 1);
    final radiusByHeight =
        math.max(180.0, size.height - 112) / (2 + ((grid.rows - 1) * 1.72));
    final radius = math.min(radiusByWidth, radiusByHeight).clamp(12.0, 30.0);
    final boardWidth = ((grid.columns * 2) + 1) * radius;

    return _DewBoardGeometry(
      size: size,
      rows: grid.rows,
      columns: grid.columns,
      radius: radius,
      left: (size.width - boardWidth) / 2,
      top: 12,
      shooterCenter: Offset(
        size.width / 2,
        size.height - math.max(44, radius * 2),
      ),
    );
  }

  final Size size;
  final int rows;
  final int columns;
  final double radius;
  final double left;
  final double top;
  final Offset shooterCenter;

  double get rowSpacing => radius * 1.72;

  double get boardWidth => ((columns * 2) + 1) * radius;

  double get boardHeight => (2 + ((rows - 1) * 1.72)) * radius;

  double get leftWall => left + radius;

  double get rightWall => left + boardWidth - radius;

  double get topWall => top + radius;

  Offset centerFor(GridPosition position) {
    return Offset(
      left +
          radius +
          (position.column * radius * 2) +
          (position.row.isOdd ? radius : 0),
      top + radius + (position.row * rowSpacing),
    );
  }

  GridPosition? hitTestBubble(BubbleGrid grid, Offset projectileCenter) {
    GridPosition? nearest;
    var nearestDistance = double.infinity;
    final threshold = radius * 1.82;

    for (final position in grid.occupiedPositions()) {
      final distance = (centerFor(position) - projectileCenter).distance;
      if (distance <= threshold && distance < nearestDistance) {
        nearest = position;
        nearestDistance = distance;
      }
    }

    return nearest;
  }
}

Offset? _aimDirectionFromTarget(Offset shooterCenter, Offset target) {
  final raw = target - shooterCenter;
  if (raw.distance < 8 || raw.dy >= -8) {
    return null;
  }

  var direction = raw / raw.distance;
  if (direction.dy > -_minimumUpwardAim) {
    final xSign = direction.dx >= 0 ? 1.0 : -1.0;
    direction = Offset(
      xSign * math.sqrt(1 - (_minimumUpwardAim * _minimumUpwardAim)),
      -_minimumUpwardAim,
    );
  }
  return direction;
}

class _TrajectoryStepResult {
  const _TrajectoryStepResult({
    required this.position,
    required this.direction,
    required this.bounces,
    this.hitPosition,
    this.reachedTop = false,
  });

  final Offset position;
  final Offset direction;
  final int bounces;
  final GridPosition? hitPosition;
  final bool reachedTop;
}

double _trajectoryStep(_DewBoardGeometry geometry) => geometry.radius * 0.36;

_TrajectoryStepResult _advanceTrajectoryStep({
  required BubbleGrid grid,
  required _DewBoardGeometry geometry,
  required Offset position,
  required Offset direction,
  required double distance,
  required int bounces,
}) {
  var nextPosition = position + direction * distance;
  var nextDirection = direction;
  var nextBounces = bounces;

  if (nextPosition.dx <= geometry.leftWall) {
    nextPosition = Offset(geometry.leftWall, nextPosition.dy);
    nextDirection = Offset(-nextDirection.dx, nextDirection.dy);
    nextBounces++;
  } else if (nextPosition.dx >= geometry.rightWall) {
    nextPosition = Offset(geometry.rightWall, nextPosition.dy);
    nextDirection = Offset(-nextDirection.dx, nextDirection.dy);
    nextBounces++;
  }

  if (nextPosition.dy <= geometry.topWall) {
    return _TrajectoryStepResult(
      position: nextPosition,
      direction: nextDirection,
      bounces: nextBounces,
      reachedTop: true,
    );
  }

  return _TrajectoryStepResult(
    position: nextPosition,
    direction: nextDirection,
    bounces: nextBounces,
    hitPosition: geometry.hitTestBubble(grid, nextPosition),
  );
}

List<Offset> _traceAimSamples(
  BubbleGrid grid,
  _DewBoardGeometry geometry,
  Offset direction,
) {
  final samples = <Offset>[];
  var position = geometry.shooterCenter;
  var velocity = direction;
  var bounces = 0;
  final step = _trajectoryStep(geometry);

  for (var index = 0; index < 720; index++) {
    final next = _advanceTrajectoryStep(
      grid: grid,
      geometry: geometry,
      position: position,
      direction: velocity,
      distance: step,
      bounces: bounces,
    );

    samples.add(next.position);
    if (next.reachedTop || next.hitPosition != null) {
      break;
    }

    position = next.position;
    velocity = next.direction;
    bounces = next.bounces;
  }

  return samples;
}

Color _bubbleColor(DewBubbleColor color) {
  return switch (color) {
    DewBubbleColor.blue => const Color(0xFF35A7FF),
    DewBubbleColor.pink => const Color(0xFFEF5DA8),
    DewBubbleColor.yellow => const Color(0xFFFFB72B),
    DewBubbleColor.green => const Color(0xFF2DBE88),
  };
}
