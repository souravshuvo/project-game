import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'data/dew_levels.dart';
import 'data/dew_progression.dart';
import 'domain/attach_solver.dart';
import 'domain/bubble_color.dart';
import 'domain/bubble_grid.dart';
import 'domain/bubble_level.dart';
import 'domain/grid_position.dart';
import '../../tracing/data/progress_repository.dart';
import '../../../shared/ads/game_ad_service.dart';
import '../../../shared/analytics/game_analytics.dart';

class DewBubbleGameScreen extends StatefulWidget {
  const DewBubbleGameScreen({
    required this.progressRepository,
    this.analytics = const NoopGameAnalytics(),
    this.adService = const NoopGameAdService(),
    this.onCompleted,
    this.initialLevelIndex = 0,
    this.showLevelSelectOnStart = true,
    this.launchSource = 'initial',
    super.key,
  });

  final ProgressRepository progressRepository;
  final GameAnalytics analytics;
  final GameAdService adService;
  final VoidCallback? onCompleted;
  final int initialLevelIndex;
  final bool showLevelSelectOnStart;
  final String launchSource;

  @override
  State<DewBubbleGameScreen> createState() => _DewBubbleGameScreenState();
}

enum _DewPlayResult { won, lost }

enum _BubbleEffectKind { pop, drop }

enum _DewPauseAction { restart, levels, home }

const _minimumUpwardAim = 0.28;
const _maxTickSeconds = 0.033;
const _projectileSpeed = 620.0;
const _neighborAttachDistance = 2.45;
const _topAttachDistance = 1.05;
const _popEffectDuration = 0.46;
const _dropEffectDuration = 0.72;
const _scoreEffectDuration = 0.82;
const _defaultDewHint =
    'Drag above the launcher. Match 3, chain streaks, save shots.';
const _neutralFeedbackColor = Color(0xFF31425E);
const _successFeedbackColor = Color(0xFF2CB9A0);
const _warningFeedbackColor = Color(0xFFFFA928);
const _errorFeedbackColor = Color(0xFFEC6F66);

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
    this.targetHit = false,
    this.won = false,
    this.lost = false,
    this.poppedCount = 0,
    this.droppedCount = 0,
  });

  final bool popped;
  final bool dropped;
  final bool targetHit;
  final bool won;
  final bool lost;
  final int poppedCount;
  final int droppedCount;
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
  int _matchStreak = 0;
  int _bestMatchStreak = 0;
  bool _isAiming = false;
  late bool _showLevelSelect;
  bool _completionReported = false;
  bool _isPaused = false;
  bool _isNewBestScore = false;
  bool _targetHitCelebrated = false;
  String _feedbackMessage = _defaultDewHint;
  Color _feedbackColor = _neutralFeedbackColor;
  int _feedbackPulse = 0;
  Offset? _aimTarget;
  Duration? _lastTick;
  DateTime? _levelStartedAt;
  _Projectile? _projectile;
  _DewBoardGeometry? _lastGeometry;
  _DewPlayResult? _result;
  int _nextEffectId = 0;
  int _shotsFired = 0;
  int _invalidAims = 0;
  int _attachments = 0;
  int _poppedTotal = 0;
  int _droppedTotal = 0;
  bool _levelEndLogged = false;

  BubbleLevel get _level => dewBubbleLevels[_levelIndex];

  bool get _hasNextLevel => _levelIndex < dewBubbleLevels.length - 1;

  bool _isLevelUnlocked(int index) => index <= _highestUnlockedLevelIndex;

  int _bestScoreForLevel(String levelId) => _bestScores[levelId] ?? 0;

  int _bestStarsForLevel(String levelId) => _bestStars[levelId] ?? 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _showLevelSelect = widget.showLevelSelectOnStart;
    _syncSavedProgress();
    _loadLevel(widget.initialLevelIndex, notify: false);
    if (_showLevelSelect) {
      _logLevelSelectViewed(widget.launchSource);
    } else {
      _logLevelStart(widget.launchSource);
    }
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
        .clamp(0, dewBubbleLevels.length - 1)
        .toInt();
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
      _matchStreak = 0;
      _bestMatchStreak = 0;
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
      _isPaused = false;
      _feedbackMessage = _defaultDewHint;
      _feedbackColor = _neutralFeedbackColor;
      _feedbackPulse = 0;
      _levelStartedAt = DateTime.now();
      _shotsFired = 0;
      _invalidAims = 0;
      _attachments = 0;
      _poppedTotal = 0;
      _droppedTotal = 0;
      _levelEndLogged = false;
      _isNewBestScore = false;
      _targetHitCelebrated = false;
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
    if (_showLevelSelect) {
      _playDewCue(SystemSoundType.click);
      _playDewHaptic(HapticFeedback.selectionClick);
    }
    _showLevelSelect = false;
    _loadLevel(levelIndex);
    _logLevelStart('level_select');
  }

  void _openLevelSelect() {
    if (_ticker.isActive) {
      _ticker.stop();
    }
    setState(() {
      _showLevelSelect = true;
      _isAiming = false;
      _isPaused = false;
      _aimTarget = null;
      _projectile = null;
      _bubbleEffects.clear();
      _scoreEffects.clear();
      _lastTick = null;
    });
    _logLevelSelectViewed('game_menu');
  }

  void _goToNextLevel() {
    if (!_hasNextLevel) {
      _openLevelSelect();
      return;
    }
    _startLevel(_levelIndex + 1);
  }

  void _logLevelSelectViewed(String source) {
    unawaited(
      widget.analytics.logEvent(GameAnalyticsEvents.levelSelectViewed, {
        'game_id': dewBubbleGameId,
        'source': source,
        'highest_unlocked': _highestUnlockedLevelIndex + 1,
        'total_levels': dewBubbleLevels.length,
      }),
    );
  }

  void _logLevelStart(String source) {
    final level = _level;
    unawaited(
      widget.analytics.logEvent(GameAnalyticsEvents.levelStart, {
        ..._levelAnalyticsParams(),
        'source': source,
        'shots_allowed': level.shots,
        'bubble_count_start': _grid.bubbleCount,
      }),
    );
  }

  void _logShotFired(Offset direction) {
    unawaited(
      widget.analytics.logEvent(GameAnalyticsEvents.shotFired, {
        ..._levelAnalyticsParams(),
        'shot_number': _shotsFired,
        'shots_remaining': _shotsRemaining,
        'aim_dx': (direction.dx * 1000).round(),
        'aim_dy': (direction.dy * 1000).round(),
      }),
    );
  }

  void _logInvalidAim() {
    unawaited(
      widget.analytics.logEvent(GameAnalyticsEvents.invalidAim, {
        ..._levelAnalyticsParams(),
        'invalid_aims': _invalidAims,
        'shots_remaining': _shotsRemaining,
      }),
    );
  }

  void _logShotMissed() {
    unawaited(
      widget.analytics.logEvent(GameAnalyticsEvents.shotMissed, {
        ..._levelAnalyticsParams(),
        'shots_remaining': _shotsRemaining,
      }),
    );
  }

  void _logResolveAnalytics(_BoardResolveFeedback feedback) {
    unawaited(
      widget.analytics.logEvent(GameAnalyticsEvents.bubbleAttached, {
        ..._levelAnalyticsParams(),
        'attachments': _attachments,
        'matched': feedback.poppedCount > 0,
        'popped_count': feedback.poppedCount,
        'dropped_count': feedback.droppedCount,
        'target_hit': feedback.targetHit,
        'match_streak': _matchStreak,
        'best_match_streak': _bestMatchStreak,
        'shots_remaining': _shotsRemaining,
        'bubble_count_after': _grid.bubbleCount,
      }),
    );

    if (feedback.poppedCount > 0) {
      unawaited(
        widget.analytics.logEvent(GameAnalyticsEvents.matchPopped, {
          ..._levelAnalyticsParams(),
          'popped_count': feedback.poppedCount,
          'popped_total': _poppedTotal,
          'match_streak': _matchStreak,
          'best_match_streak': _bestMatchStreak,
          'target_hit': feedback.targetHit,
          'score': _score,
        }),
      );
    }

    if (feedback.droppedCount > 0) {
      unawaited(
        widget.analytics.logEvent(GameAnalyticsEvents.floatingDropped, {
          ..._levelAnalyticsParams(),
          'dropped_count': feedback.droppedCount,
          'dropped_total': _droppedTotal,
          'match_streak': _matchStreak,
          'target_hit': feedback.targetHit,
          'score': _score,
        }),
      );
    }
  }

  void _logLevelEnd(_DewPlayResult result) {
    if (_levelEndLogged) {
      return;
    }
    _levelEndLogged = true;
    widget.adService.recordLevelEnd(won: result == _DewPlayResult.won);
    final startedAt = _levelStartedAt;
    final durationSeconds = startedAt == null
        ? 0
        : DateTime.now().difference(startedAt).inSeconds;

    unawaited(
      widget.analytics.logEvent(GameAnalyticsEvents.levelEnd, {
        ..._levelAnalyticsParams(),
        'result': result == _DewPlayResult.won ? 'won' : 'lost',
        'duration_seconds': durationSeconds,
        'shots_allowed': _level.shots,
        'shots_fired': _shotsFired,
        'shots_remaining': _shotsRemaining,
        'invalid_aims': _invalidAims,
        'attachments': _attachments,
        'popped_total': _poppedTotal,
        'dropped_total': _droppedTotal,
        'score': _score,
        'stars': _earnedStars,
        'best_match_streak': _bestMatchStreak,
        'target_hit': _score >= dewBubbleTargetScore(_level),
        'new_best_score': _isNewBestScore,
      }),
    );
  }

  void _handleResultAction(String action, VoidCallback callback) {
    _playDewCue(SystemSoundType.click);
    _playDewHaptic(HapticFeedback.selectionClick);
    unawaited(_runResultActionAfterAd(action, callback));
  }

  Future<void> _runResultActionAfterAd(
    String action,
    VoidCallback callback,
  ) async {
    unawaited(
      widget.analytics.logEvent(GameAnalyticsEvents.resultAction, {
        ..._levelAnalyticsParams(),
        'action': action,
        'result': _result == _DewPlayResult.won ? 'won' : 'lost',
        'ad_candidate': true,
        'ad_placement': 'level_result_$action',
      }),
    );
    try {
      await widget.adService.showInterstitialIfAvailable(
        placement: 'level_result_$action',
      );
    } on Object {
      // Ads must never block retry, next level, or level select.
    }
    if (!mounted) {
      return;
    }
    callback();
  }

  void _restartLevel() {
    _resetLevel();
    if (!_showLevelSelect) {
      _logLevelStart('restart');
    }
  }

  Map<String, Object> _levelAnalyticsParams() {
    final level = _level;
    final chapter = dewCampaignChapterForLevelIndex(_levelIndex);
    return {
      'game_id': dewBubbleGameId,
      'level_id': level.id,
      'level_number': _levelIndex + 1,
      'total_levels': dewBubbleLevels.length,
      'chapter_id': chapter.id,
      'chapter_number': dewCampaignChapters.indexOf(chapter) + 1,
      'target_score': dewBubbleTargetScore(level),
      'level_bubble_count': dewBubbleBubbleCount(level),
      'active_rows': dewBubbleActiveRows(level),
      'color_count': dewBubbleColorsIn(level).length,
    };
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

  void _setFeedback(String message, Color color) {
    _feedbackMessage = message;
    _feedbackColor = color;
    _feedbackPulse++;
  }

  void _setFeedbackIfChanged(String message, Color color) {
    if (_feedbackMessage == message && _feedbackColor == color) {
      return;
    }
    _setFeedback(message, color);
  }

  void _playDewHaptic(Future<void> Function() feedback) {
    if (!widget.progressRepository.hapticsEnabled) {
      return;
    }
    unawaited(feedback());
  }

  Future<void> _setSoundEnabled(bool enabled) async {
    await widget.progressRepository.setSoundEnabled(enabled);
    unawaited(
      widget.analytics.logEvent(GameAnalyticsEvents.settingsChanged, {
        'game_id': dewBubbleGameId,
        'setting': 'sound',
        'enabled': enabled,
        'surface': 'pause_menu',
      }),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _setHapticsEnabled(bool enabled) async {
    await widget.progressRepository.setHapticsEnabled(enabled);
    unawaited(
      widget.analytics.logEvent(GameAnalyticsEvents.settingsChanged, {
        'game_id': dewBubbleGameId,
        'setting': 'haptics',
        'enabled': enabled,
        'surface': 'pause_menu',
      }),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openHelpSheet() async {
    _playDewCue(SystemSoundType.click);
    _playDewHaptic(HapticFeedback.selectionClick);
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _DewHelpSheet(),
    );
  }

  Future<void> _openPauseMenu() async {
    if (_showLevelSelect) {
      return;
    }

    final shouldResumeTicker =
        _ticker.isActive &&
        (_projectile != null ||
            _bubbleEffects.isNotEmpty ||
            _scoreEffects.isNotEmpty);
    if (_ticker.isActive) {
      _ticker.stop();
    }

    setState(() {
      _isPaused = true;
      _isAiming = false;
      _aimTarget = null;
      _lastTick = null;
      _setFeedback('Paused. Resume when you are ready.', _neutralFeedbackColor);
    });
    _playDewCue(SystemSoundType.click);
    _playDewHaptic(HapticFeedback.selectionClick);

    final action = await showModalBottomSheet<_DewPauseAction>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DewPauseSheet(
        soundEnabled: widget.progressRepository.soundEnabled,
        hapticsEnabled: widget.progressRepository.hapticsEnabled,
        onSoundChanged: _setSoundEnabled,
        onHapticsChanged: _setHapticsEnabled,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isPaused = false;
      _lastTick = null;
      if (action == null) {
        _setFeedback(_defaultDewHint, _neutralFeedbackColor);
      }
    });

    switch (action) {
      case _DewPauseAction.restart:
        _restartLevel();
      case _DewPauseAction.levels:
        _openLevelSelect();
      case _DewPauseAction.home:
        unawaited(Navigator.maybePop(context));
      case null:
        if (shouldResumeTicker) {
          _ensureTickerRunning();
        }
    }
  }

  void _setAimTarget(Offset localPosition, _DewBoardGeometry geometry) {
    if (_isPaused ||
        _result != null ||
        _projectile != null ||
        _shotsRemaining <= 0) {
      return;
    }

    final wasAiming = _isAiming;
    final direction = _aimDirectionFromTarget(
      geometry.shooterCenter,
      localPosition,
    );
    setState(() {
      _isAiming = true;
      _aimTarget = localPosition;
      if (direction == null) {
        _setFeedbackIfChanged(
          'Aim above the launcher, then release to shoot.',
          _warningFeedbackColor,
        );
      } else {
        _setFeedbackIfChanged(
          'Release to shoot. Bounce off walls for a clear path.',
          _neutralFeedbackColor,
        );
      }
    });
    if (!wasAiming) {
      _playDewHaptic(HapticFeedback.selectionClick);
    }
  }

  void _cancelAim() {
    if (!_isAiming) {
      return;
    }
    setState(() {
      _isAiming = false;
      _aimTarget = null;
      _setFeedback('Aim cancelled.', _neutralFeedbackColor);
    });
  }

  void _fire(_DewBoardGeometry geometry) {
    if (_isPaused ||
        _result != null ||
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
      _invalidAims++;
      setState(() {
        _isAiming = false;
        _aimTarget = null;
        _setFeedback(
          'Aim upward into the playfield, then release.',
          _errorFeedbackColor,
        );
      });
      _playDewCue(SystemSoundType.alert);
      _playDewHaptic(HapticFeedback.lightImpact);
      _logInvalidAim();
      return;
    }

    setState(() {
      _shotsFired++;
      _shotsRemaining--;
      _isAiming = false;
      _aimTarget = null;
      _projectile = _Projectile(
        color: _currentColor,
        position: geometry.shooterCenter,
        direction: direction,
      );
      _setFeedback(
        'Shot launched. Watch where it attaches.',
        _neutralFeedbackColor,
      );
    });
    _playDewCue(SystemSoundType.click);
    _playDewHaptic(HapticFeedback.lightImpact);
    _logShotFired(direction);

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
      late final bool lost;
      setState(() {
        _projectile = null;
        if (_shotsRemaining <= 0) {
          _result = _DewPlayResult.lost;
          lost = true;
          _setFeedback(
            'No shots left. Restart and try a higher path.',
            _errorFeedbackColor,
          );
        } else {
          lost = false;
          _advanceQueueIfPlaying();
          _setFeedback(
            'That shot could not attach. Aim closer to the cluster.',
            _warningFeedbackColor,
          );
        }
      });
      _playDewCue(SystemSoundType.alert);
      _playDewHaptic(
        lost ? HapticFeedback.vibrate : HapticFeedback.mediumImpact,
      );
      _logShotMissed();
      if (lost) {
        _logLevelEnd(_DewPlayResult.lost);
      }
      _ticker.stop();
      _lastTick = null;
      return;
    }

    late final _BoardResolveFeedback feedback;
    setState(() {
      _projectile = null;
      _grid.setColor(attachPosition, projectile.color);
      _attachments++;
      feedback = _resolveBoardAfterAttach(attachPosition, geometry);
      _advanceQueueIfPlaying();
    });
    _playResolveFeedback(feedback);
    _logResolveAnalytics(feedback);
    if (feedback.won) {
      _logLevelEnd(_DewPlayResult.won);
    } else if (feedback.lost) {
      _logLevelEnd(_DewPlayResult.lost);
    }

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
    var poppedCount = 0;
    var droppedCount = 0;
    var targetHit = false;
    final matched = _grid.connectedSameColor(attachPosition);
    if (matched.length >= 3) {
      _matchStreak++;
      _bestMatchStreak = math.max(_bestMatchStreak, _matchStreak);
      _addBubbleEffects(
        positions: matched,
        kind: _BubbleEffectKind.pop,
        geometry: geometry,
      );
      _grid.removeAll(matched);
      final matchScore = matched.length * 10;
      final streakBonus = _matchStreak <= 1 ? 0 : (_matchStreak - 1) * 15;
      final earnedScore = matchScore + streakBonus;
      _score += earnedScore;
      _addScoreEffect(
        '+$earnedScore',
        geometry.centerFor(attachPosition).translate(0, -geometry.radius),
        const Color(0xFF2CB9A0),
      );
      _setFeedback(
        _matchStreak > 1
            ? 'Streak x$_matchStreak. ${matched.length} bubbles popped.'
            : 'Nice match. ${matched.length} bubbles popped.',
        _successFeedbackColor,
      );
      popped = true;
      poppedCount = matched.length;
      _poppedTotal += matched.length;

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
        _setFeedback(
          'Great drop. ${floating.length} floating bubbles cleared.',
          _warningFeedbackColor,
        );
        dropped = true;
        droppedCount = floating.length;
        _droppedTotal += floating.length;
      }
    } else {
      _matchStreak = 0;
      _setFeedback(
        'Attached. Build a group of 3 matching colors.',
        _neutralFeedbackColor,
      );
    }

    final targetScore = dewBubbleTargetScore(_level);
    if (!_targetHitCelebrated && _score >= targetScore) {
      _targetHitCelebrated = true;
      targetHit = true;
      _setFeedback(
        'Target score hit. Clear the board for stars.',
        _successFeedbackColor,
      );
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
      final unlockMessage = _hasNextLevel
          ? 'Stage cleared. Next stage unlocked.'
          : 'Stage cleared. Final stage saved.';
      _setFeedback(unlockMessage, _successFeedbackColor);
      won = true;
      if (_levelIndex == dewBubbleLevels.length - 1 && !_completionReported) {
        _completionReported = true;
        widget.onCompleted?.call();
      }
    } else if (_shotsRemaining <= 0) {
      _result = _DewPlayResult.lost;
      _setFeedback('No shots left. Restart to try again.', _errorFeedbackColor);
      lost = true;
    }

    return _BoardResolveFeedback(
      popped: popped,
      dropped: dropped,
      targetHit: targetHit,
      won: won,
      lost: lost,
      poppedCount: poppedCount,
      droppedCount: droppedCount,
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
    final previousBestScore = _bestScoreForLevel(level.id);
    final nextUnlockIndex = math.min(
      _levelIndex + 1,
      dewBubbleLevels.length - 1,
    );
    _highestUnlockedLevelIndex = math.max(
      _highestUnlockedLevelIndex,
      nextUnlockIndex,
    );
    _isNewBestScore = score > previousBestScore;
    _bestScores[level.id] = math.max(previousBestScore, score);
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
    if (feedback.won) {
      _playDewCue(SystemSoundType.alert);
      _playDewHaptic(HapticFeedback.heavyImpact);
      return;
    }
    if (feedback.lost) {
      _playDewCue(SystemSoundType.alert);
      _playDewHaptic(HapticFeedback.vibrate);
      return;
    }
    if (feedback.targetHit) {
      _playDewCue(SystemSoundType.click);
      _playDewHaptic(HapticFeedback.mediumImpact);
      return;
    }
    if (feedback.dropped) {
      _playDewCue(SystemSoundType.click);
      _playDewHaptic(HapticFeedback.mediumImpact);
      return;
    }
    if (feedback.popped) {
      _playDewCue(SystemSoundType.click);
      _playDewHaptic(
        _matchStreak > 1
            ? HapticFeedback.mediumImpact
            : HapticFeedback.selectionClick,
      );
      return;
    }
    _playDewCue(SystemSoundType.click);
    _playDewHaptic(HapticFeedback.selectionClick);
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
        onHelp: _openHelpSheet,
        onSelectLevel: _startLevel,
      );
    }

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F8FA), Color(0xFFEAF8F2), Color(0xFFFFF8E8)],
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
                onPause: _openPauseMenu,
              ),
              _DewBubbleHud(
                shotsRemaining: _shotsRemaining,
                score: _score,
                nextColor: _nextColor,
                mission: dewBubbleStageMission(_levelIndex),
                targetScore: dewBubbleTargetScore(_level),
                bestScore: _bestScoreForLevel(_level.id),
                streak: _matchStreak,
                starPace: _starsForWin(_level.shots, _shotsRemaining),
              ),
              _DewFeedbackBanner(
                message: _feedbackMessage,
                color: _feedbackColor,
                pulseKey: _feedbackPulse,
                streak: _matchStreak,
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
              onTapDown: (details) =>
                  _setAimTarget(details.localPosition, geometry),
              onTapUp: (_) => _fire(geometry),
              onTapCancel: _cancelAim,
              onPanStart: (details) =>
                  _setAimTarget(details.localPosition, geometry),
              onPanUpdate: (details) =>
                  _setAimTarget(details.localPosition, geometry),
              onPanEnd: (_) => _fire(geometry),
              onPanCancel: _cancelAim,
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
                  isPaused: _isPaused,
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
                  targetScore: dewBubbleTargetScore(_level),
                  stars: _earnedStars,
                  bestStreak: _bestMatchStreak,
                  isNewBestScore: _isNewBestScore,
                  nextLevelTitle: _hasNextLevel
                      ? dewBubbleLevels[_levelIndex + 1].title
                      : null,
                  onRestart: () =>
                      _handleResultAction('restart', _restartLevel),
                  onLevelSelect: () =>
                      _handleResultAction('levels', _openLevelSelect),
                  onHome: () => Navigator.maybePop(context),
                  hasNextLevel: _hasNextLevel,
                  onNextLevel: () =>
                      _handleResultAction('next_level', _goToNextLevel),
                ),
              ),
            if (_shotsFired == 0 &&
                !_isAiming &&
                _projectile == null &&
                _result == null)
              Positioned(
                left: 18,
                right: 18,
                bottom: math.max(74, geometry.radius * 3.4),
                child: const IgnorePointer(child: _DewFirstShotCoachMark()),
              ),
          ],
        );
      },
    );
  }
}

class _DewFirstShotCoachMark extends StatelessWidget {
  const _DewFirstShotCoachMark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF243C4A).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x20243C4A),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swipe_up_rounded, color: Color(0xFF67B8F7), size: 20),
              SizedBox(width: 7),
              Flexible(
                child: Text(
                  'Drag up from the launcher, release to shoot',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
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

class _DewLevelSelectScreen extends StatelessWidget {
  const _DewLevelSelectScreen({
    required this.levels,
    required this.highestUnlockedLevelIndex,
    required this.bestScoreFor,
    required this.bestStarsFor,
    required this.onBack,
    required this.onHelp,
    required this.onSelectLevel,
  });

  final List<BubbleLevel> levels;
  final int highestUnlockedLevelIndex;
  final int Function(String levelId) bestScoreFor;
  final int Function(String levelId) bestStarsFor;
  final VoidCallback onBack;
  final VoidCallback onHelp;
  final ValueChanged<int> onSelectLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F8FA), Color(0xFFEAF8F2), Color(0xFFFFF8E8)],
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
                              'Garden Route',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: const Color(0xFF31425E),
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const Text(
                              'Continue the route, chase targets, bank stars.',
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
                      SizedBox.square(
                        dimension: 56,
                        child: IconButton.filledTonal(
                          tooltip: 'How to play',
                          onPressed: onHelp,
                          icon: const Icon(Icons.help_rounded, size: 28),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                sliver: SliverToBoxAdapter(
                  child: _DewMapContinuePanel(
                    level: levels[highestUnlockedLevelIndex],
                    levelNumber: highestUnlockedLevelIndex + 1,
                    bestScore: bestScoreFor(
                      levels[highestUnlockedLevelIndex].id,
                    ),
                    bestStars: bestStarsFor(
                      levels[highestUnlockedLevelIndex].id,
                    ),
                    onContinue: () => onSelectLevel(highestUnlockedLevelIndex),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Route stages',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF31425E),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final level = levels[index];
                    final unlocked = index <= highestUnlockedLevelIndex;
                    final chapter = dewCampaignChapterForLevelIndex(index);
                    final showChapterHeader = chapter.startLevelIndex == index;
                    final chapterUnlocked = math.max(
                      0,
                      math.min(
                            highestUnlockedLevelIndex,
                            chapter.endLevelIndex,
                          ) -
                          chapter.startLevelIndex +
                          1,
                    );
                    final chapterTotal =
                        chapter.endLevelIndex - chapter.startLevelIndex + 1;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showChapterHeader)
                          _DewChapterHeader(
                            chapter: chapter,
                            unlockedCount: chapterUnlocked,
                            totalCount: chapterTotal,
                          ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _DewLevelTile(
                            level: level,
                            levelNumber: index + 1,
                            unlocked: unlocked,
                            bestScore: bestScoreFor(level.id),
                            bestStars: bestStarsFor(level.id),
                            onTap: unlocked ? () => onSelectLevel(index) : null,
                          ),
                        ),
                      ],
                    );
                  }, childCount: levels.length),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DewChapterHeader extends StatelessWidget {
  const _DewChapterHeader({
    required this.chapter,
    required this.unlockedCount,
    required this.totalCount,
  });

  final DewCampaignChapter chapter;
  final int unlockedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF243C4A),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  chapter.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF68758B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StageRouteBadge(
            icon: Icons.route_rounded,
            label: '$unlockedCount/$totalCount',
            color: const Color(0xFF3F8FEF),
          ),
        ],
      ),
    );
  }
}

class _DewMapContinuePanel extends StatelessWidget {
  const _DewMapContinuePanel({
    required this.level,
    required this.levelNumber,
    required this.bestScore,
    required this.bestStars,
    required this.onContinue,
  });

  final BubbleLevel level;
  final int levelNumber;
  final int bestScore;
  final int bestStars;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final levelIndex = levelNumber - 1;
    final mission = dewBubbleStageMission(levelIndex);
    final targetScore = dewBubbleTargetScore(level);
    final chapter = dewCampaignChapterForLevelIndex(levelIndex);
    final status = bestScore == 0
        ? 'Target $targetScore pts.'
        : 'Best $bestScore / $bestStars stars. Replay for a cleaner clear.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF172C37),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20243C4A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF2CB9A0).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: Color(0xFF67E0C9),
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${chapter.title} - Stage $levelNumber',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  level.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF67E0C9),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFBFD0D7),
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                Text(
                  mission,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFDDEBE7),
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: onContinue,
            style: FilledButton.styleFrom(
              minimumSize: const Size(82, 48),
              backgroundColor: const Color(0xFF2CB9A0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
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
    final mission = dewBubbleStageMission(levelNumber - 1);
    final targetScore = dewBubbleTargetScore(level);
    final accent = unlocked
        ? (bestStars == 3 ? const Color(0xFFFFA928) : const Color(0xFF2CB9A0))
        : const Color(0xFFB8C2CE);
    final foreground = unlocked
        ? const Color(0xFF243C4A)
        : const Color(0xFF7A8795);
    final status = !unlocked
        ? 'Locked'
        : bestScore == 0
        ? 'New stage'
        : 'Best $bestScore';

    return Semantics(
      button: unlocked,
      enabled: unlocked,
      label: unlocked
          ? 'Stage $levelNumber, ${level.title}'
          : 'Stage $levelNumber locked',
      child: Material(
        color: Colors.white.withValues(alpha: unlocked ? 0.92 : 0.68),
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: accent.withValues(
                            alpha: unlocked ? 0.14 : 0.2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            !unlocked
                                ? Icons.lock_rounded
                                : bestStars > 0
                                ? Icons.check_rounded
                                : Icons.play_arrow_rounded,
                            color: accent,
                            size: 24,
                          ),
                        ),
                      ),
                      Container(
                        width: 3,
                        height: 28,
                        margin: const EdgeInsets.only(top: 5),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.34),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Stage ${levelNumber.toString().padLeft(2, '0')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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
                      Text(
                        mission,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF68758B),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _StageRouteBadge(
                            icon: Icons.adjust_rounded,
                            label: '${level.shots} shots',
                            color: const Color(0xFF3F8FEF),
                          ),
                          _StageRouteBadge(
                            icon: Icons.outlined_flag_rounded,
                            label: '$targetScore pts',
                            color: const Color(0xFF7257E8),
                          ),
                          _StageRouteBadge(
                            icon: Icons.emoji_events_rounded,
                            label: status,
                            color: accent,
                          ),
                          if (unlocked)
                            _StageStars(bestStars: bestStars)
                          else
                            const _StageRouteBadge(
                              icon: Icons.lock_rounded,
                              label: 'Clear previous',
                              color: Color(0xFF8A96A6),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  unlocked ? Icons.chevron_right_rounded : Icons.lock_rounded,
                  color: accent,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StageRouteBadge extends StatelessWidget {
  const _StageRouteBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageStars extends StatelessWidget {
  const _StageStars({required this.bestStars});

  final int bestStars;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFA928).withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(3, (index) {
              return Icon(
                index < bestStars
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: const Color(0xFFFFA928),
                size: 16,
              );
            }),
          ],
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
    required this.onPause,
  });

  final String title;
  final int levelNumber;
  final int levelCount;
  final VoidCallback onSelectLevel;
  final VoidCallback onPause;

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
                  'Match 3, chain streaks, save shots',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF68758B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Stage $levelNumber of $levelCount',
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
              tooltip: 'Open route',
              onPressed: onSelectLevel,
              icon: const Icon(Icons.map_rounded, size: 28),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox.square(
            dimension: 56,
            child: IconButton.filled(
              key: const ValueKey('dew-pause-button'),
              tooltip: 'Pause, settings, and help',
              onPressed: onPause,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF2CB9A0),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.pause_rounded, size: 30),
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
    required this.mission,
    required this.targetScore,
    required this.bestScore,
    required this.streak,
    required this.starPace,
  });

  final int shotsRemaining;
  final int score;
  final DewBubbleColor nextColor;
  final String mission;
  final int targetScore;
  final int bestScore;
  final int streak;
  final int starPace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          Row(
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
          const SizedBox(height: 8),
          _RunObjectiveBar(
            score: score,
            mission: mission,
            targetScore: targetScore,
            bestScore: bestScore,
            streak: streak,
            starPace: starPace,
          ),
        ],
      ),
    );
  }
}

class _RunObjectiveBar extends StatelessWidget {
  const _RunObjectiveBar({
    required this.score,
    required this.mission,
    required this.targetScore,
    required this.bestScore,
    required this.streak,
    required this.starPace,
  });

  final int score;
  final String mission;
  final int targetScore;
  final int bestScore;
  final int streak;
  final int starPace;

  @override
  Widget build(BuildContext context) {
    final targetProgress = targetScore <= 0
        ? 0.0
        : (score / targetScore).clamp(0.0, 1.0);
    final scoreGoal = bestScore >= targetScore
        ? 'Beat best $bestScore'
        : 'Target $targetScore';
    final goal = score >= targetScore ? '$scoreGoal hit' : scoreGoal;

    return Container(
      constraints: const BoxConstraints(minHeight: 42),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF243C4A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag_rounded, color: Color(0xFF67B8F7), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  goal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  mission,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFBFD0D7),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: targetProgress,
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.16),
                    color: score >= targetScore
                        ? const Color(0xFF2CB9A0)
                        : const Color(0xFFFFD15C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _RunBadge(
            icon: Icons.local_fire_department_rounded,
            label: 'x${math.max(1, streak)}',
            color: const Color(0xFF2CB9A0),
          ),
          const SizedBox(width: 6),
          _RunBadge(
            icon: Icons.star_rounded,
            label: '$starPace',
            color: const Color(0xFFFFD15C),
          ),
        ],
      ),
    );
  }
}

class _RunBadge extends StatelessWidget {
  const _RunBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DewFeedbackBanner extends StatelessWidget {
  const _DewFeedbackBanner({
    required this.message,
    required this.color,
    required this.pulseKey,
    required this.streak,
  });

  final String message;
  final Color color;
  final int pulseKey;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final icon = _feedbackIconFor(color);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(
                Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero),
              ),
              child: child,
            ),
          );
        },
        child: TweenAnimationBuilder<double>(
          key: ValueKey<int>(pulseKey),
          tween: Tween<double>(begin: 0.98, end: 1),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              alignment: Alignment.centerLeft,
              child: child,
            );
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.26)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ),
                if (streak > 1) ...[
                  const SizedBox(width: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.88, end: 1),
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        child: Text(
                          'x$streak',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _feedbackIconFor(Color color) {
  if (color == _successFeedbackColor) {
    return Icons.check_circle_rounded;
  }
  if (color == _warningFeedbackColor) {
    return Icons.warning_amber_rounded;
  }
  if (color == _errorFeedbackColor) {
    return Icons.error_rounded;
  }
  return Icons.tips_and_updates_rounded;
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
        borderRadius: BorderRadius.circular(8),
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Text(
                    value,
                    key: ValueKey<String>(value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF34415F),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
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
        borderRadius: BorderRadius.circular(8),
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
    return SizedBox.square(
      dimension: 30,
      child: CustomPaint(painter: _BubbleDotPainter(color)),
    );
  }
}

class _BubbleDotPainter extends CustomPainter {
  const _BubbleDotPainter(this.color);

  final DewBubbleColor color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    final radius = size.shortestSide / 2;
    final center = size.center(Offset.zero);
    final fill = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.42, -0.48),
        radius: 0.92,
        colors: [Colors.white.withValues(alpha: 0.72), _bubbleColor(color)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, fill);
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.74)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    _drawBubbleGlyph(canvas, center, radius, color, 1);
  }

  @override
  bool shouldRepaint(covariant _BubbleDotPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _DewResultPanel extends StatelessWidget {
  const _DewResultPanel({
    required this.result,
    required this.score,
    required this.targetScore,
    required this.stars,
    required this.bestStreak,
    required this.isNewBestScore,
    required this.nextLevelTitle,
    required this.onRestart,
    required this.onLevelSelect,
    required this.onHome,
    required this.hasNextLevel,
    required this.onNextLevel,
  });

  final _DewPlayResult result;
  final int score;
  final int targetScore;
  final int stars;
  final int bestStreak;
  final bool isNewBestScore;
  final String? nextLevelTitle;
  final VoidCallback onRestart;
  final VoidCallback onLevelSelect;
  final VoidCallback onHome;
  final bool hasNextLevel;
  final VoidCallback onNextLevel;

  @override
  Widget build(BuildContext context) {
    final won = result == _DewPlayResult.won;
    final color = won ? const Color(0xFF2CB9A0) : const Color(0xFFEC6F66);
    final title = won ? 'Stage cleared' : 'Run failed';
    final targetHit = score >= targetScore;
    final subtitle = won
        ? (isNewBestScore ? 'New best score $score' : 'Score $score')
        : 'Score $score - aim higher and chase a streak.';
    final nextHint = won
        ? _resultNextHint(
            targetHit: targetHit,
            targetScore: targetScore,
            nextLevelTitle: nextLevelTitle,
          )
        : 'Match 3, use wall bounces, and save shots.';

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.94, end: 1),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: Material(
        color: Colors.white,
        elevation: 8,
        shadowColor: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        won ? Icons.celebration_rounded : Icons.replay_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
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
                            color: Color(0xFF34415F),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF68758B),
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _ResultBadge(
                    icon: Icons.emoji_events_rounded,
                    label: '$score pts',
                    color: const Color(0xFF3F8FEF),
                  ),
                  _ResultBadge(
                    icon: targetHit
                        ? Icons.flag_rounded
                        : Icons.outlined_flag_rounded,
                    label: targetHit ? 'Target hit' : 'Target $targetScore',
                    color: targetHit
                        ? const Color(0xFF2CB9A0)
                        : const Color(0xFF68758B),
                  ),
                  if (won)
                    _ResultBadge(
                      icon: Icons.star_rounded,
                      label: '$stars/3 stars',
                      color: const Color(0xFFFFA928),
                    ),
                  if (isNewBestScore)
                    const _ResultBadge(
                      icon: Icons.emoji_events_rounded,
                      label: 'New best',
                      color: Color(0xFF7257E8),
                    ),
                  if (bestStreak > 1)
                    _ResultBadge(
                      icon: Icons.bolt_rounded,
                      label: 'Streak x$bestStreak',
                      color: const Color(0xFF2CB9A0),
                    ),
                ],
              ),
              if (won) ...[
                const SizedBox(height: 10),
                _ResultStarMeter(stars: stars),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  nextHint,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF68758B),
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  if (won && hasNextLevel)
                    FilledButton.icon(
                      onPressed: onNextLevel,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Next Stage'),
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(104, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  else if (!won)
                    FilledButton.icon(
                      onPressed: onRestart,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry Stage'),
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(104, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  else
                    FilledButton.icon(
                      onPressed: onLevelSelect,
                      icon: const Icon(Icons.route_rounded),
                      label: const Text('Route'),
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(118, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  if (won)
                    OutlinedButton.icon(
                      onPressed: onRestart,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Replay Stage'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        minimumSize: const Size(104, 46),
                        side: BorderSide(color: color.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  if (!won || hasNextLevel)
                    OutlinedButton.icon(
                      onPressed: onLevelSelect,
                      icon: const Icon(Icons.route_rounded),
                      label: const Text('Route'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        minimumSize: const Size(92, 46),
                        side: BorderSide(color: color.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  TextButton.icon(
                    onPressed: onHome,
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Home'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _resultNextHint({
  required bool targetHit,
  required int targetScore,
  required String? nextLevelTitle,
}) {
  if (nextLevelTitle == null) {
    return targetHit
        ? 'Route cleared. Replay for cleaner runs.'
        : 'Route cleared. Replay to hit target $targetScore.';
  }
  if (targetHit) {
    return 'Next stage: $nextLevelTitle';
  }
  return 'Stage clear. Replay for target $targetScore or continue.';
}

class _ResultStarMeter extends StatelessWidget {
  const _ResultStarMeter({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$stars of 3 stars earned',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < 3; index++)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.86, end: 1),
              duration: Duration(milliseconds: 150 + (index * 45)),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Icon(
                  index < stars
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: index < stars
                      ? const Color(0xFFFFA928)
                      : const Color(0xFFCDD5E2),
                  size: 32,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _DewPauseSheet extends StatefulWidget {
  const _DewPauseSheet({
    required this.soundEnabled,
    required this.hapticsEnabled,
    required this.onSoundChanged,
    required this.onHapticsChanged,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final Future<void> Function(bool enabled) onSoundChanged;
  final Future<void> Function(bool enabled) onHapticsChanged;

  @override
  State<_DewPauseSheet> createState() => _DewPauseSheetState();
}

class _DewPauseSheetState extends State<_DewPauseSheet> {
  late bool _soundEnabled = widget.soundEnabled;
  late bool _hapticsEnabled = widget.hapticsEnabled;

  void _setSound(bool enabled) {
    setState(() => _soundEnabled = enabled);
    unawaited(widget.onSoundChanged(enabled));
  }

  void _setHaptics(bool enabled) {
    setState(() => _hapticsEnabled = enabled);
    unawaited(widget.onHapticsChanged(enabled));
  }

  @override
  Widget build(BuildContext context) {
    return _DewSheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DewSheetHandle(),
          Row(
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xFFE7FAFF),
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.pause_rounded, color: Color(0xFF31425E)),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Paused',
                  style: TextStyle(
                    color: Color(0xFF31425E),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Resume',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _DewHelpSummary(),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _soundEnabled,
            onChanged: _setSound,
            secondary: const Icon(Icons.volume_up_rounded),
            title: const Text('Sound feedback'),
            subtitle: const Text('System tap, score, win, and loss cues.'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _hapticsEnabled,
            onChanged: _setHaptics,
            secondary: const Icon(Icons.vibration_rounded),
            title: const Text('Haptic feedback'),
            subtitle: const Text('Gentle device feedback for actions.'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Resume'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: const Color(0xFF2CB9A0),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pop(_DewPauseAction.restart),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Restart'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pop(_DewPauseAction.levels),
                  icon: const Icon(Icons.map_rounded),
                  label: const Text('Route'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(_DewPauseAction.home),
            icon: const Icon(Icons.home_rounded),
            label: const Text('Home'),
          ),
        ],
      ),
    );
  }
}

class _DewHelpSheet extends StatelessWidget {
  const _DewHelpSheet();

  @override
  Widget build(BuildContext context) {
    return _DewSheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DewSheetHandle(),
          Row(
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xFFE7FAFF),
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.help_rounded, color: Color(0xFF31425E)),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'How to play',
                  style: TextStyle(
                    color: Color(0xFF31425E),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _DewHelpSummary(),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: const Color(0xFF2CB9A0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _DewHelpSummary extends StatelessWidget {
  const _DewHelpSummary();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _DewHelpRow(
          icon: Icons.touch_app_rounded,
          title: 'Aim',
          text: 'Drag or tap above the launcher to preview the path.',
        ),
        SizedBox(height: 8),
        _DewHelpRow(
          icon: Icons.auto_awesome_rounded,
          title: 'Match',
          text: 'Attach 3 or more same-color bubbles to pop them.',
        ),
        SizedBox(height: 8),
        _DewHelpRow(
          icon: Icons.keyboard_double_arrow_down_rounded,
          title: 'Clear',
          text: 'Unsupported drops fall. Clear the stage before shots run out.',
        ),
      ],
    );
  }
}

class _DewHelpRow extends StatelessWidget {
  const _DewHelpRow({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF2CB9A0), size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF31425E),
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF68758B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DewSheetFrame extends StatelessWidget {
  const _DewSheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 12,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DewSheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 48,
        height: 5,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFDDE4EA),
          borderRadius: BorderRadius.circular(99),
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
    required this.isPaused,
  });

  final BubbleGrid grid;
  final _DewBoardGeometry geometry;
  final DewBubbleColor currentColor;
  final _Projectile? projectile;
  final List<_BubbleEffect> bubbleEffects;
  final List<_ScoreFloatEffect> scoreEffects;
  final bool isAiming;
  final Offset? aimTarget;
  final bool isPaused;

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
    if (isPaused) {
      _drawPauseVeil(canvas);
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

    final railPaint = Paint()
      ..color = const Color(0xFF243C4A).withValues(alpha: 0.18)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(geometry.leftWall, geometry.topWall),
      Offset(geometry.leftWall, geometry.shooterCenter.dy - geometry.radius),
      railPaint,
    );
    canvas.drawLine(
      Offset(geometry.rightWall, geometry.topWall),
      Offset(geometry.rightWall, geometry.shooterCenter.dy - geometry.radius),
      railPaint,
    );
  }

  void _drawAimGuide(Canvas canvas) {
    final target = aimTarget;
    if (!isAiming || target == null || projectile != null) {
      if (!isPaused && !isAiming && projectile == null) {
        _drawIdleAimCue(canvas);
      }
      return;
    }

    final direction = _aimDirectionFromTarget(geometry.shooterCenter, target);
    if (direction == null) {
      _drawInvalidAimGuide(canvas);
      return;
    }

    final guideColor = _bubbleColor(currentColor);
    final paint = Paint()
      ..color = guideColor.withValues(alpha: 0.58)
      ..style = PaintingStyle.fill;

    final samples = _traceAimSamples(grid, geometry, direction);
    for (var index = 0; index < samples.length; index += 4) {
      final progress = samples.length <= 1 ? 1 : index / (samples.length - 1);
      canvas.drawCircle(samples[index], 2.7 + (progress * 1.5), paint);
    }

    if (samples.isNotEmpty) {
      _drawBubble(
        canvas,
        samples.last,
        geometry.radius * 0.58,
        currentColor,
        opacity: 0.46,
      );
      canvas.drawCircle(
        samples.last,
        geometry.radius * 0.62,
        Paint()
          ..color = guideColor.withValues(alpha: 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );
    }
  }

  void _drawIdleAimCue(Canvas canvas) {
    final cueColor = _bubbleColor(currentColor);
    final start = geometry.shooterCenter.translate(0, -geometry.radius * 1.35);
    final end = start.translate(0, -geometry.radius * 4.35);
    final dotPaint = Paint()
      ..color = cueColor.withValues(alpha: 0.32)
      ..style = PaintingStyle.fill;

    for (var index = 0; index < 5; index++) {
      final progress = (index + 1) / 6;
      final base = Offset.lerp(start, end, progress)!;
      final sway = math.sin(progress * math.pi) * geometry.radius * 0.32;
      canvas.drawCircle(
        base.translate(sway, 0),
        3.4 + (index * 0.35),
        dotPaint,
      );
    }

    final arrowPaint = Paint()
      ..color = cueColor.withValues(alpha: 0.56)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4;
    canvas.drawLine(end, end.translate(-5.5, 8), arrowPaint);
    canvas.drawLine(end, end.translate(5.5, 8), arrowPaint);
  }

  void _drawInvalidAimGuide(Canvas canvas) {
    final center = geometry.shooterCenter;
    final paint = Paint()
      ..color = _errorFeedbackColor.withValues(alpha: 0.74)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    final guideEnd = center.translate(0, -geometry.radius * 3.2);
    canvas.drawLine(
      center.translate(0, -geometry.radius * 0.8),
      guideEnd,
      paint,
    );
    canvas.drawCircle(
      guideEnd,
      geometry.radius * 0.42,
      Paint()
        ..color = _errorFeedbackColor.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
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

  void _drawPauseVeil(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.36)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & geometry.size, paint);
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

    _drawBubbleGlyph(canvas, center, radius, color, alpha);
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

void _drawBubbleGlyph(
  Canvas canvas,
  Offset center,
  double radius,
  DewBubbleColor color,
  double alpha,
) {
  final markPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.78 * alpha)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = (radius * 0.13).clamp(1.5, 3.2);

  switch (color) {
    case DewBubbleColor.blue:
      final path = Path()
        ..moveTo(center.dx - radius * 0.42, center.dy + radius * 0.04)
        ..cubicTo(
          center.dx - radius * 0.2,
          center.dy - radius * 0.26,
          center.dx + radius * 0.08,
          center.dy + radius * 0.28,
          center.dx + radius * 0.42,
          center.dy - radius * 0.04,
        );
      canvas.drawPath(path, markPaint);
    case DewBubbleColor.pink:
      canvas.drawCircle(center, radius * 0.28, markPaint);
      canvas.drawCircle(center, radius * 0.08, markPaint);
    case DewBubbleColor.yellow:
      canvas.drawLine(
        center.translate(0, -radius * 0.42),
        center.translate(0, radius * 0.42),
        markPaint,
      );
      canvas.drawLine(
        center.translate(-radius * 0.42, 0),
        center.translate(radius * 0.42, 0),
        markPaint,
      );
      canvas.drawCircle(center, radius * 0.1, markPaint);
    case DewBubbleColor.green:
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-0.55);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: radius * 0.82,
          height: radius * 0.42,
        ),
        markPaint,
      );
      canvas.drawLine(
        Offset(-radius * 0.35, 0),
        Offset(radius * 0.35, 0),
        markPaint,
      );
      canvas.restore();
  }
}
