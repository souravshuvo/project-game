import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'challenges/challenge.dart';
import 'components/aim_preview_component.dart';
import 'components/ball_component.dart';
import 'components/field_component.dart';
import 'game_phase.dart';
import 'game_result.dart';
import 'physics/collision_rules.dart';
import 'physics/shot_physics.dart';

class RooftopCurveGame extends FlameGame with PanDetector {
  RooftopCurveGame({
    required this.onChallengeChanged,
    required this.onAimingChanged,
    required this.onAttemptsChanged,
    required this.onResult,
  })
    : super(
        camera: CameraComponent.withFixedResolution(
          width: fieldWidth,
          height: fieldHeight,
        ),
      );

  static const double fieldWidth = 360;
  static const double fieldHeight = 640;

  final void Function(Challenge challenge, int challengeIndex, int totalChallenges)
  onChallengeChanged;
  final void Function(bool isAiming) onAimingChanged;
  final void Function(int attempts) onAttemptsChanged;
  final void Function(GameResult result) onResult;

  final List<Challenge> _challenges = productionV1StarterChallenges();
  final AimPreviewComponent _aimPreview = AimPreviewComponent();
  final List<Component> _sceneComponents = [];

  late BallComponent _ball;
  late Challenge _challenge;
  GamePhase _phase = GamePhase.ready;
  int _challengeIndex = 0;
  int _attempts = 1;

  int get currentChallengeNumber => _challengeIndex + 1;
  int get totalChallenges => _challenges.length;
  bool get hasNextChallenge => _challengeIndex < _challenges.length - 1;

  Rect get _fieldBounds => const Rect.fromLTWH(0, 0, fieldWidth, fieldHeight);

  @override
  FutureOr<void> onLoad() {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();

    world.add(FieldComponent());
    _loadChallenge(0);
  }

  void nextChallenge() {
    if (!hasNextChallenge) {
      retry(countAttempt: false);
      return;
    }

    _loadChallenge(_challengeIndex + 1);
  }

  void retry({bool countAttempt = true}) {
    if (countAttempt) {
      _attempts += 1;
      onAttemptsChanged(_attempts);
    }
    _phase = GamePhase.ready;
    onAimingChanged(false);
    _aimPreview.clear();
    _ball.reset(_challenge.ballStart);
  }

  void restartChallenge() {
    _attempts = 1;
    onAttemptsChanged(_attempts);
    _phase = GamePhase.ready;
    onAimingChanged(false);
    _aimPreview.clear();
    _ball.reset(_challenge.ballStart);
  }

  void _loadChallenge(int index) {
    for (final component in _sceneComponents) {
      component.removeFromParent();
    }
    _sceneComponents.clear();

    _challengeIndex = index;
    _challenge = _challenges[index];
    _phase = GamePhase.ready;
    _attempts = 1;
    onAimingChanged(false);
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

    onAttemptsChanged(_attempts);
    onChallengeChanged(_challenge, _challengeIndex, _challenges.length);
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (_phase != GamePhase.ready) {
      return;
    }

    final worldPosition = _toWorld(info.eventPosition.widget);
    if (worldPosition.distanceTo(_ball.position) > 46) {
      return;
    }

    _phase = GamePhase.aiming;
    onAimingChanged(true);
    _updateAim(worldPosition);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (_phase != GamePhase.aiming) {
      return;
    }

    _updateAim(_toWorld(info.eventPosition.widget));
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (_phase != GamePhase.aiming) {
      return;
    }

    final shot = _aimPreview.shot;
    _aimPreview.clear();
    onAimingChanged(false);

    if (shot == null || shot.power <= 0) {
      _phase = GamePhase.ready;
      return;
    }

    _ball.shoot(shot);
    _phase = GamePhase.shotInFlight;
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

  void _updateAim(Vector2 dragPosition) {
    final shot = ShotPhysics.fromDrag(
      ballPosition: _ball.position,
      dragPosition: dragPosition,
    );
    _aimPreview.updateAim(
      startPosition: _ball.position,
      dragPosition: dragPosition,
      shotConfig: shot,
    );
  }

  void _resolve(GameResultType type) {
    _phase = GamePhase.resolved;
    _ball.inFlight = false;
    _ball.velocity = Vector2.zero();
    onAimingChanged(false);
    onResult(
      GameResult(
        type: type,
        attempt: _attempts,
        challengeId: _challenge.id,
      ),
    );
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
