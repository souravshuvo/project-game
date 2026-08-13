import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'challenges/challenge.dart';
import 'components/aim_preview_component.dart';
import 'components/ball_component.dart';
import 'components/field_component.dart';
import 'game_feedback.dart';
import 'game_phase.dart';
import 'game_result.dart';
import 'physics/collision_rules.dart';
import 'physics/shot_physics.dart';

class RooftopCurveGame extends FlameGame with PanDetector {
  RooftopCurveGame({
    this.initialChallengeIndex = 0,
    required this.onChallengeChanged,
    required this.onAimingChanged,
    required this.onAimUpdated,
    required this.onFeedback,
    required this.onAttemptsChanged,
    required this.onResult,
  }) : super(
         camera: CameraComponent.withFixedResolution(
           width: fieldWidth,
           height: fieldHeight,
         ),
       );

  static const double fieldWidth = 360;
  static const double fieldHeight = 640;
  static const double ballTouchRadius = 78;
  static const double _pullZoneWidth = 190;
  static const double _pullZoneHeight = 156;
  static const double _pullZoneYOffset = 58;
  static const double _lowerAimStartPadding = 36;
  static const double _fieldSidePadding = 8;

  final int initialChallengeIndex;
  final void Function(
    Challenge challenge,
    int challengeIndex,
    int totalChallenges,
  )
  onChallengeChanged;
  final void Function(bool isAiming) onAimingChanged;
  final void Function(double power, double curve) onAimUpdated;
  final void Function(GameFeedback feedback) onFeedback;
  final void Function(int attempts) onAttemptsChanged;
  final void Function(GameResult result) onResult;

  final List<Challenge> _challenges = productionV1Challenges();
  final AimPreviewComponent _aimPreview = AimPreviewComponent();
  final List<Component> _sceneComponents = [];

  late BallComponent _ball;
  late Challenge _challenge;
  GamePhase _phase = GamePhase.ready;
  int _challengeIndex = 0;
  int _attempts = 1;
  bool _isLoaded = false;

  int get currentChallengeNumber => _challengeIndex + 1;
  int get totalChallenges => _challenges.length;
  bool get hasNextChallenge => _challengeIndex < _challenges.length - 1;

  Rect get _fieldBounds => const Rect.fromLTWH(0, 0, fieldWidth, fieldHeight);

  @override
  FutureOr<void> onLoad() {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();

    world.add(FieldComponent());
    final startIndex = initialChallengeIndex
        .clamp(0, _challenges.length - 1)
        .toInt();
    _loadChallenge(startIndex, announce: false);
  }

  void nextChallenge() {
    if (!_isLoaded) {
      return;
    }

    if (!hasNextChallenge) {
      retry(countAttempt: false);
      return;
    }

    _loadChallenge(_challengeIndex + 1);
  }

  void retry({bool countAttempt = true}) {
    if (!_isLoaded) {
      return;
    }

    if (countAttempt) {
      _attempts += 1;
      onAttemptsChanged(_attempts);
    }
    _phase = GamePhase.ready;
    onAimingChanged(false);
    onAimUpdated(0, 0);
    _aimPreview.clear();
    _ball.reset(_challenge.ballStart);
    onFeedback(GameFeedback.retry);
  }

  void restartChallenge() {
    if (!_isLoaded) {
      return;
    }

    _attempts = 1;
    onAttemptsChanged(_attempts);
    _phase = GamePhase.ready;
    onAimingChanged(false);
    onAimUpdated(0, 0);
    _aimPreview.clear();
    _ball.reset(_challenge.ballStart);
    onFeedback(GameFeedback.retry);
  }

  void startAimFromWidget(Vector2 widgetPosition) {
    if (!_isLoaded) {
      return;
    }

    if (_phase != GamePhase.ready) {
      return;
    }

    final worldPosition = _toWorld(widgetPosition);
    if (!_canStartAimAt(worldPosition)) {
      onFeedback(GameFeedback.invalid);
      return;
    }

    _phase = GamePhase.aiming;
    onAimingChanged(true);
    onFeedback(GameFeedback.aimStart);
    _updateAim(worldPosition);
  }

  void updateAimFromWidget(Vector2 widgetPosition) {
    if (!_isLoaded) {
      return;
    }

    if (_phase != GamePhase.aiming) {
      return;
    }

    _updateAim(_toWorld(widgetPosition));
  }

  void releaseAim() {
    if (!_isLoaded) {
      return;
    }

    if (_phase != GamePhase.aiming) {
      return;
    }

    final shot = _aimPreview.shot;
    _aimPreview.clear();
    onAimingChanged(false);
    onAimUpdated(0, 0);

    if (shot == null || shot.power <= 0) {
      _phase = GamePhase.ready;
      onFeedback(GameFeedback.invalid);
      return;
    }

    _ball.shoot(shot);
    _phase = GamePhase.shotInFlight;
    onFeedback(GameFeedback.shot);
  }

  void cancelAim() {
    if (!_isLoaded) {
      return;
    }

    if (_phase != GamePhase.aiming) {
      return;
    }

    _phase = GamePhase.ready;
    _aimPreview.clear();
    onAimingChanged(false);
    onAimUpdated(0, 0);
  }

  void _loadChallenge(int index, {bool announce = true}) {
    _isLoaded = false;
    for (final component in _sceneComponents) {
      component.removeFromParent();
    }
    _sceneComponents.clear();

    _challengeIndex = index;
    _challenge = _challenges[index];
    _phase = GamePhase.ready;
    _attempts = 1;
    onAimingChanged(false);
    onAimUpdated(0, 0);
    _aimPreview.clear();

    final goal = _GoalComponent(_challenge.goalMouth);
    world.add(goal);
    _sceneComponents.add(goal);

    final keeper = _challenge.keeper;
    if (keeper != null) {
      final keeperComponent = _KeeperComponent(keeper);
      world.add(keeperComponent);
      _sceneComponents.add(keeperComponent);
    }

    for (final obstacle in _challenge.obstacles) {
      final obstacleComponent = _ObstacleComponent(obstacle);
      world.add(obstacleComponent);
      _sceneComponents.add(obstacleComponent);
    }
    _ball = BallComponent(start: _challenge.ballStart);
    world.add(_ball);
    _sceneComponents.add(_ball);
    world.add(_aimPreview);
    _sceneComponents.add(_aimPreview);

    _isLoaded = true;
    onAttemptsChanged(_attempts);
    onChallengeChanged(_challenge, _challengeIndex, _challenges.length);
    if (announce && index > 0) {
      onFeedback(GameFeedback.next);
    }
  }

  @override
  void onPanStart(DragStartInfo info) {
    startAimFromWidget(info.eventPosition.widget);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    updateAimFromWidget(info.eventPosition.widget);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    releaseAim();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_phase != GamePhase.shotInFlight) {
      return;
    }

    final resultType = CollisionRules.resolve(
      ballPosition: _ball.position,
      ballRadius: BallComponent.ballRadius,
      velocity: _ball.velocity,
      fieldBounds: _fieldBounds,
      goalMouth: _challenge.goalMouth,
      keeper: _challenge.keeper,
      obstacles: _challenge.obstacles,
    );

    if (resultType != null) {
      _resolve(resultType);
    }
  }

  Vector2 _toWorld(Vector2 widgetPosition) {
    return camera.globalToLocal(widgetPosition);
  }

  bool _canStartAimAt(Vector2 worldPosition) {
    if (worldPosition.distanceTo(_ball.position) <= ballTouchRadius) {
      return true;
    }

    final pullZone = Rect.fromCenter(
      center: Offset(_ball.position.x, _ball.position.y + _pullZoneYOffset),
      width: _pullZoneWidth,
      height: _pullZoneHeight,
    );
    if (pullZone.contains(Offset(worldPosition.x, worldPosition.y))) {
      return true;
    }

    return worldPosition.x >= _fieldSidePadding &&
        worldPosition.x <= fieldWidth - _fieldSidePadding &&
        worldPosition.y >= _ball.position.y - _lowerAimStartPadding &&
        worldPosition.y <= fieldHeight - _fieldSidePadding;
  }

  void _updateAim(Vector2 dragPosition) {
    final effectiveDragPosition = _clampAimDrag(dragPosition);
    final shot = ShotPhysics.fromDrag(
      ballPosition: _ball.position,
      dragPosition: effectiveDragPosition,
    );
    _aimPreview.updateAim(
      startPosition: _ball.position,
      dragPosition: effectiveDragPosition,
      shotConfig: shot,
    );
    onAimUpdated(shot.power, shot.curve);
  }

  Vector2 _clampAimDrag(Vector2 dragPosition) {
    const maxY = fieldHeight - _fieldSidePadding;
    final minY = (_ball.position.y + ShotPhysics.minDrag)
        .clamp(0, maxY)
        .toDouble();
    return Vector2(
      dragPosition.x
          .clamp(_fieldSidePadding, fieldWidth - _fieldSidePadding)
          .toDouble(),
      dragPosition.y.clamp(minY, maxY).toDouble(),
    );
  }

  void _resolve(GameResultType type) {
    _phase = GamePhase.resolved;
    _ball.inFlight = false;
    _ball.velocity = Vector2.zero();
    onAimingChanged(false);
    onAimUpdated(0, 0);
    world.add(
      _ImpactRingComponent(
        position: _ball.position.clone(),
        color: _resultColor(type),
      ),
    );
    onFeedback(_feedbackForResult(type));
    onResult(
      GameResult(type: type, attempt: _attempts, challengeId: _challenge.id),
    );
  }

  Color _resultColor(GameResultType type) {
    return switch (type) {
      GameResultType.goal => const Color(0xFF70E000),
      GameResultType.saved => const Color(0xFFFFD166),
      GameResultType.blocked => const Color(0xFFEF476F),
      GameResultType.missed ||
      GameResultType.tooWeak => const Color(0xFFFF6B6B),
    };
  }

  GameFeedback _feedbackForResult(GameResultType type) {
    return switch (type) {
      GameResultType.goal => GameFeedback.goal,
      GameResultType.saved => GameFeedback.saved,
      GameResultType.blocked => GameFeedback.blocked,
      GameResultType.missed || GameResultType.tooWeak => GameFeedback.missed,
    };
  }
}

class _GoalComponent extends PositionComponent {
  _GoalComponent(Rect rect)
    : _rect = rect,
      super(
        position: Vector2(rect.left, rect.top),
        size: Vector2(rect.width, rect.height),
      );

  final Rect _rect;

  @override
  void render(Canvas canvas) {
    final netPaint = Paint()..color = const Color(0xFFE9F7EF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, _rect.width, _rect.height),
        const Radius.circular(4),
      ),
      netPaint,
    );

    final linePaint = Paint()
      ..color = const Color(0xFF2B4F4A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(Rect.fromLTWH(0, 0, _rect.width, _rect.height), linePaint);
  }
}

class _KeeperComponent extends PositionComponent {
  _KeeperComponent(Rect rect)
    : super(
        position: Vector2(rect.left, rect.top),
        size: Vector2(rect.width, rect.height),
      );

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF263238);
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(6)),
      paint,
    );

    final glovePaint = Paint()..color = const Color(0xFFFFD166);
    canvas.drawCircle(const Offset(4, 11), 5, glovePaint);
    canvas.drawCircle(Offset(size.x - 4, 11), 5, glovePaint);
  }
}

class _ObstacleComponent extends PositionComponent {
  _ObstacleComponent(Rect rect)
    : super(
        position: Vector2(rect.left, rect.top),
        size: Vector2(rect.width, rect.height),
      );

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFEF476F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(4)),
      paint,
    );

    final stripePaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.55)
      ..strokeWidth = 3;
    canvas.drawLine(const Offset(6, 12), Offset(size.x - 6, 26), stripePaint);
    canvas.drawLine(const Offset(6, 42), Offset(size.x - 6, 56), stripePaint);
  }
}

class _ImpactRingComponent extends PositionComponent {
  _ImpactRingComponent({required Vector2 position, required this.color})
    : super(position: position, anchor: Anchor.center);

  final Color color;
  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= 0.34) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (_age / 0.34).clamp(0.0, 1.0).toDouble();
    final paint = Paint()
      ..color = color.withValues(alpha: 1 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset.zero, 12 + progress * 28, paint);
  }
}
