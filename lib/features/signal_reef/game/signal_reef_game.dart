import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../application/signal_reef_feedback.dart';
import '../application/signal_reef_telemetry.dart';
import '../domain/enemy_type.dart';
import '../domain/run_result.dart';
import '../domain/score_rules.dart';
import '../domain/wave_definition.dart';

enum SignalReefRunState { ready, playing, won, lost }

enum _BulletOwner { player, enemy }

class SignalReefGame extends FlameGame with HasCollisionDetection {
  SignalReefGame({
    required List<WaveDefinition> waves,
    required this.telemetry,
    required this.feedback,
    required this.feedbackSettings,
    required this.onStateChanged,
    required this.onRunFinished,
  }) : waves = List.unmodifiable(waves);

  static const startingHull = 3;

  final List<WaveDefinition> waves;
  final SignalReefTelemetry telemetry;
  final SignalReefFeedback feedback;
  final SignalReefFeedbackSettings Function() feedbackSettings;
  final VoidCallback onStateChanged;
  final ValueChanged<SignalReefRunResult> onRunFinished;

  late final _ArenaComponent _arena;
  late final _PlayerComponent _player;

  SignalReefRunState runState = SignalReefRunState.ready;
  int score = 0;
  int hull = startingHull;
  int wavesCleared = 0;
  int currentWaveNumber = 1;

  var _waveIndex = 0;
  var _spawnCursor = 0;
  var _killsThisWave = 0;
  var _spawnTimer = 0.0;
  var _fireTimer = 0.0;
  var _readyTimer = 0.55;
  var _shotDirection = 1;
  var _finished = false;
  var _runElapsedSeconds = 0.0;
  Vector2? _dragOffset;
  List<SignalEnemyType> _spawnQueue = const [];

  WaveDefinition get _currentWave => waves[_waveIndex];

  int get totalWaves => waves.length;

  @override
  Color backgroundColor() => const Color(0xFF050710);

  @override
  Future<void> onLoad() async {
    _alignCameraToScreenCoordinates();
    _arena = _ArenaComponent();
    _player = _PlayerComponent();

    await world.add(_arena);
    await world.add(_player);

    _arena.size = size;
    _beginWave(0);
    _placePlayer();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _alignCameraToScreenCoordinates();
    if (isLoaded) {
      _arena.size = size;
      _placePlayer();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (runState == SignalReefRunState.ready) {
      _readyTimer -= dt;
      if (_readyTimer <= 0) {
        runState = SignalReefRunState.playing;
        onStateChanged();
      }
      return;
    }

    if (runState != SignalReefRunState.playing) {
      return;
    }

    _runElapsedSeconds += dt;
    _updatePlayerFire(dt);
    _updateWaveSpawns(dt);
    _checkWaveCompletion();
  }

  void beginPlayerDrag(Offset localPosition) {
    if (!isLoaded) {
      return;
    }

    final touch = Vector2(localPosition.dx, localPosition.dy);
    _dragOffset = _player.position - touch;
    _movePlayerWithDrag(localPosition);
  }

  void updatePlayerDrag(Offset localPosition) {
    _movePlayerWithDrag(localPosition);
  }

  void endPlayerDrag() {
    _dragOffset = null;
  }

  void _movePlayerWithDrag(Offset localPosition) {
    if (!isLoaded) {
      return;
    }

    if (runState != SignalReefRunState.playing &&
        runState != SignalReefRunState.ready) {
      return;
    }

    final offset = _dragOffset ?? Vector2.zero();
    _player.target = _clampPlayerPosition(
      Vector2(localPosition.dx, localPosition.dy) + offset,
    );
  }

  void _handleEnemyHit(_BulletComponent bullet, _EnemyComponent enemy) {
    if (!bullet.isMounted ||
        !enemy.isMounted ||
        bullet.owner != _BulletOwner.player) {
      return;
    }

    bullet.removeFromParent();
    enemy.takeDamage(bullet.damage);
    enemy.markHit();

    if (!enemy.isDestroyed) {
      _playFeedback(SignalReefFeedbackCue.validAction);
      _addHitRing(enemy.position, const Color(0xFFB7FFF6));
      return;
    }

    final scoreValue = SignalReefScoreRules.enemyDestroyed(enemy.type);
    score += scoreValue;
    _killsThisWave++;
    _playFeedback(SignalReefFeedbackCue.score);
    _addBurst(enemy.position, enemy.type);
    _addFloatingText('+$scoreValue', enemy.position, const Color(0xFFEAF7F4));
    enemy.removeFromParent();
    onStateChanged();
  }

  void _handlePlayerHitByBullet(_BulletComponent bullet) {
    if (!bullet.isMounted || bullet.owner != _BulletOwner.enemy) {
      return;
    }

    bullet.removeFromParent();
    _damagePlayer();
  }

  void _handlePlayerHitByEnemy(_EnemyComponent enemy) {
    if (!enemy.isMounted) {
      return;
    }

    enemy.removeFromParent();
    _damagePlayer();
  }

  void _spawnEnemyBullet(Vector2 position) {
    world.add(
      _BulletComponent(
        owner: _BulletOwner.enemy,
        position: position,
        velocity: Vector2(0, 255),
        radius: 5,
        damage: 1,
      ),
    );
  }

  void _handleEnemyEscaped(SignalEnemyType type) {
    if (_finished || _killsThisWave >= _currentWave.totalEnemies) {
      return;
    }

    _spawnQueue.add(type);
  }

  void _beginWave(int index) {
    _waveIndex = index;
    final wave = _currentWave;
    currentWaveNumber = wave.number;
    _spawnQueue = wave.buildSpawnQueue();
    _spawnCursor = 0;
    _killsThisWave = 0;
    _spawnTimer = 0.35;
    telemetry.track(
      SignalReefTelemetryEvents.waveStart(
        waveNumber: currentWaveNumber,
        totalEnemies: wave.totalEnemies,
        pulseSeeds: wave.enemyCounts[SignalEnemyType.pulseSeed] ?? 0,
        maxActiveEnemies: wave.maxActiveEnemies,
        spawnIntervalMillis: (wave.spawnInterval * 1000).round(),
      ),
    );
    onStateChanged();
  }

  void _updatePlayerFire(double dt) {
    _fireTimer -= dt;
    if (_fireTimer > 0 || !_player.isMounted) {
      return;
    }

    _fireTimer = 0.20;
    _shotDirection *= -1;
    world.add(
      _BulletComponent(
        owner: _BulletOwner.player,
        position: _player.position + Vector2(8.0 * _shotDirection, -30),
        velocity: Vector2(0, -620),
        radius: 4,
        damage: 1,
      ),
    );
  }

  void _updateWaveSpawns(double dt) {
    if (_spawnCursor >= _spawnQueue.length) {
      return;
    }

    if (_enemyCount >= _currentWave.maxActiveEnemies) {
      return;
    }

    _spawnTimer -= dt;
    if (_spawnTimer > 0) {
      return;
    }

    final type = _spawnQueue[_spawnCursor];
    _spawnCursor++;
    _spawnTimer = _currentWave.spawnInterval;
    world.add(_EnemyComponent(type: type, waveNumber: currentWaveNumber));
  }

  void _checkWaveCompletion() {
    if (_killsThisWave < _currentWave.totalEnemies || _enemyCount > 0) {
      return;
    }

    final clearedWave = currentWaveNumber;
    final waveBonus = SignalReefScoreRules.waveCleared(clearedWave);
    score += waveBonus;
    wavesCleared++;
    _playFeedback(SignalReefFeedbackCue.reward);
    _addFloatingText(
      'Wave clear +$waveBonus',
      Vector2(size.x / 2, size.y * 0.28),
      const Color(0xFFFFC857),
    );
    telemetry.track(
      SignalReefTelemetryEvents.waveComplete(
        waveNumber: clearedWave,
        score: score,
        hullRemaining: hull,
        durationSeconds: _runElapsedSeconds.round(),
      ),
    );

    if (_waveIndex == waves.length - 1) {
      _finishRun(won: true);
      return;
    }

    _beginWave(_waveIndex + 1);
  }

  void _damagePlayer() {
    if (runState != SignalReefRunState.playing || !_player.canTakeDamage) {
      return;
    }

    hull--;
    _player.markDamaged();
    _playFeedback(SignalReefFeedbackCue.damage);
    _addHitRing(_player.position, const Color(0xFFFF6B6B), radius: 46);
    telemetry.track(
      SignalReefTelemetryEvents.playerDamage(
        hullRemaining: hull,
        waveNumber: currentWaveNumber,
      ),
    );
    onStateChanged();

    if (hull <= 0) {
      _finishRun(won: false);
    }
  }

  void _finishRun({required bool won}) {
    if (_finished) {
      return;
    }

    _finished = true;
    if (won) {
      score += SignalReefScoreRules.winBonus;
      runState = SignalReefRunState.won;
      _playFeedback(SignalReefFeedbackCue.win);
      telemetry.track(
        SignalReefTelemetryEvents.gameWin(
          score: score,
          durationSeconds: _runElapsedSeconds.round(),
        ),
      );
    } else {
      runState = SignalReefRunState.lost;
      _playFeedback(SignalReefFeedbackCue.loss);
      telemetry.track(
        SignalReefTelemetryEvents.playerDeath(
          score: score,
          waveNumber: currentWaveNumber,
          durationSeconds: _runElapsedSeconds.round(),
        ),
      );
    }

    onRunFinished(
      SignalReefRunResult(
        score: score,
        waveReached: currentWaveNumber,
        wavesCleared: wavesCleared,
        durationSeconds: _runElapsedSeconds.round(),
        hullRemaining: hull,
        won: won,
      ),
    );
    onStateChanged();
  }

  void _addBurst(Vector2 position, SignalEnemyType type) {
    final color = switch (type) {
      SignalEnemyType.driftNode => const Color(0xFFFF5C8A),
      SignalEnemyType.pulseSeed => const Color(0xFFFFC857),
    };

    for (var index = 0; index < 7; index++) {
      final angle = (math.pi * 2 / 7) * index;
      world.add(
        _SparkComponent(
          position: position.clone(),
          velocity: Vector2(math.cos(angle), math.sin(angle)) * 72,
          color: color,
        ),
      );
    }
  }

  void _addHitRing(Vector2 position, Color color, {double radius = 28}) {
    world.add(
      _RingComponent(
        position: position.clone(),
        color: color,
        maxRadius: radius,
      ),
    );
  }

  void _addFloatingText(String text, Vector2 position, Color color) {
    world.add(
      _FloatingTextComponent(
        text: text,
        position: position.clone() + Vector2(0, -18),
        color: color,
      ),
    );
  }

  void _playFeedback(SignalReefFeedbackCue cue) {
    feedback.play(cue, feedbackSettings());
  }

  void _alignCameraToScreenCoordinates() {
    camera.viewfinder
      ..anchor = Anchor.topLeft
      ..position = Vector2.zero();
  }

  void _placePlayer() {
    if (size.x <= 0 || size.y <= 0) {
      return;
    }

    final start = Vector2(size.x / 2, size.y * 0.82);
    _player.position = _clampPlayerPosition(start);
    _player.target = _player.position.clone();
  }

  Vector2 _clampPlayerPosition(Vector2 position) {
    final halfWidth = _player.size.x / 2;
    final halfHeight = _player.size.y / 2;
    final top = size.y * 0.30;

    return Vector2(
      position.x.clamp(halfWidth, size.x - halfWidth).toDouble(),
      position.y.clamp(top + halfHeight, size.y - halfHeight).toDouble(),
    );
  }

  int get _enemyCount => world.children.whereType<_EnemyComponent>().length;
}

class _ArenaComponent extends PositionComponent {
  var _scroll = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _scroll = (_scroll + dt * 84) % 2000;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Offset.zero & Size(size.x, size.y);
    final background = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF050710), Color(0xFF0B1024), Color(0xFF061A24)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRect(rect, background);

    final nebulaPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF2F8BFF).withValues(alpha: 0.18),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.x * 0.24, size.y * 0.22),
              radius: size.x * 0.75,
            ),
          );
    canvas.drawRect(rect, nebulaPaint);

    final lanePaint = Paint()
      ..color = const Color(0xFF61E4FF).withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var x = -size.x; x < size.x * 2; x += 86) {
      canvas.drawLine(
        Offset(x + (_scroll * 0.16), 0),
        Offset(x + size.x * 0.36 + (_scroll * 0.16), size.y),
        lanePaint,
      );
    }

    final starPaint = Paint();
    final streakPaint = Paint()
      ..color = const Color(0xFFEAF7F4).withValues(alpha: 0.18)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    for (var index = 0; index < 72; index++) {
      final x = ((index * 67 + (index % 5) * 31) % math.max(1, size.x.toInt()))
          .toDouble();
      final speed = 0.42 + (index % 4) * 0.18;
      final y = ((index * 113 + _scroll * speed) % (size.y + 80)) - 40;
      final alpha = 0.34 + (index % 3) * 0.14;
      final radius = index % 9 == 0 ? 1.8 : 1.0;
      starPaint.color = const Color(0xFFEAF7F4).withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, starPaint);

      if (index % 11 == 0) {
        canvas.drawLine(Offset(x, y - 8), Offset(x, y + 18), streakPaint);
      }
    }
  }
}

class _PlayerComponent extends PositionComponent with CollisionCallbacks {
  _PlayerComponent() : super(size: Vector2(44, 54), anchor: Anchor.center);

  Vector2? target;
  var _invulnerableTimer = 0.0;
  var _thrusterPulse = 0.0;

  bool get canTakeDamage => _invulnerableTimer <= 0;

  @override
  Future<void> onLoad() async {
    await add(CircleHitbox(radius: 16, anchor: Anchor.center));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_invulnerableTimer > 0) {
      _invulnerableTimer -= dt;
    }
    _thrusterPulse += dt * 8;

    final nextTarget = target;
    if (nextTarget == null) {
      return;
    }

    final delta = nextTarget - position;
    final distance = delta.length;
    if (distance < 1) {
      position = nextTarget;
      return;
    }

    final step = math.min(distance, 640 * dt);
    position += delta.normalized() * step;
  }

  @override
  void render(Canvas canvas) {
    final flickerOff =
        _invulnerableTimer > 0 && (_invulnerableTimer * 12).floor().isEven;
    if (flickerOff) {
      return;
    }

    final wing = Paint()..color = const Color(0xFF1D5C86);
    final body = Paint()..color = const Color(0xFF7EF9D4);
    final nose = Paint()..color = const Color(0xFFEAF7F4);
    final cockpit = Paint()..color = const Color(0xFF07131E);
    final trailAlpha = 0.56 + math.sin(_thrusterPulse).abs() * 0.28;
    final flame = Paint()
      ..color = const Color(0xFF2E9CFF).withValues(alpha: trailAlpha);

    final leftWing = Path()
      ..moveTo(size.x * 0.20, size.y * 0.42)
      ..lineTo(0, size.y * 0.78)
      ..lineTo(size.x * 0.34, size.y * 0.70)
      ..close();
    final rightWing = Path()
      ..moveTo(size.x * 0.80, size.y * 0.42)
      ..lineTo(size.x, size.y * 0.78)
      ..lineTo(size.x * 0.66, size.y * 0.70)
      ..close();
    final hull = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x * 0.74, size.y * 0.72)
      ..lineTo(size.x * 0.60, size.y * 0.94)
      ..lineTo(size.x * 0.40, size.y * 0.94)
      ..lineTo(size.x * 0.26, size.y * 0.72)
      ..close();

    canvas.drawPath(leftWing, wing);
    canvas.drawPath(rightWing, wing);
    canvas.drawPath(hull, body);
    canvas.drawPath(
      Path()
        ..moveTo(size.x / 2, 4)
        ..lineTo(size.x * 0.60, size.y * 0.32)
        ..lineTo(size.x * 0.40, size.y * 0.32)
        ..close(),
      nose,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y * 0.48),
        width: 12,
        height: 16,
      ),
      cockpit,
    );
    canvas.drawLine(
      Offset(size.x * 0.42, size.y * 0.94),
      Offset(size.x * 0.42, size.y + 12),
      flame..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(size.x * 0.58, size.y * 0.94),
      Offset(size.x * 0.58, size.y + 12),
      flame..strokeWidth = 3,
    );
  }

  void markDamaged() {
    _invulnerableTimer = 1.2;
  }
}

class _EnemyComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<SignalReefGame> {
  _EnemyComponent({required this.type, required this.waveNumber})
    : _hull = type.maxHull,
      super(size: _sizeFor(type), anchor: Anchor.center);

  final SignalEnemyType type;
  final int waveNumber;
  int _hull;
  var _age = 0.0;
  var _fireTimer = 1.1;
  var _hitFlashTimer = 0.0;
  late final double _driftSeed;
  late final double _direction;

  bool get isDestroyed => _hull <= 0;

  @override
  Future<void> onLoad() async {
    _driftSeed = (waveNumber * 41 + hashCode % 97).toDouble();
    _direction = hashCode.isEven ? 1 : -1;
    position = _spawnPosition();
    await add(CircleHitbox(radius: size.x * 0.42, anchor: Anchor.center));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_hitFlashTimer > 0) {
      _hitFlashTimer -= dt;
    }

    switch (type) {
      case SignalEnemyType.driftNode:
        position += Vector2(
          math.sin(_age * 2.5 + _driftSeed) * 28 * dt,
          type.baseSpeed * dt,
        );
      case SignalEnemyType.pulseSeed:
        position += Vector2(
          math.sin(_age * 1.8 + _driftSeed) * 20 * dt,
          type.baseSpeed * dt,
        );
        _updatePulseSeedAttack(dt);
    }

    if (position.y > game.size.y + 48) {
      game._handleEnemyEscaped(type);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    switch (type) {
      case SignalEnemyType.driftNode:
        _renderDriftNode(canvas);
      case SignalEnemyType.pulseSeed:
        _renderPulseSeed(canvas);
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is _PlayerComponent) {
      game._handlePlayerHitByEnemy(this);
    }
  }

  void takeDamage(int damage) {
    _hull -= damage;
  }

  void markHit() {
    _hitFlashTimer = 0.12;
  }

  Vector2 _spawnPosition() {
    final laneCount = type == SignalEnemyType.pulseSeed ? 4 : 5;
    final lane = (hashCode.abs() + waveNumber) % laneCount;
    final spacing = game.size.x / (laneCount + 1);
    final x = spacing * (lane + 1);
    final y = -size.y - ((hashCode.abs() % 4) * 10);

    return Vector2(x, y);
  }

  void _updatePulseSeedAttack(double dt) {
    _fireTimer -= dt;
    if (_fireTimer > 0 || position.y < 60 || position.y > game.size.y * 0.7) {
      return;
    }

    _fireTimer = 1.65;
    game._spawnEnemyBullet(position + Vector2(0, size.y * 0.35));
  }

  void _renderDriftNode(Canvas canvas) {
    final paint = Paint()
      ..color = _hitFlashTimer > 0 ? Colors.white : const Color(0xFFFF5C8A);
    final wing = Paint()..color = const Color(0xFF70254E);
    final core = Paint()..color = const Color(0xFFFFD3E0);
    final hull = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x * 0.86, size.y * 0.36)
      ..lineTo(size.x * 0.72, size.y * 0.82)
      ..lineTo(size.x / 2, size.y)
      ..lineTo(size.x * 0.28, size.y * 0.82)
      ..lineTo(size.x * 0.14, size.y * 0.36)
      ..close();

    canvas.drawPath(
      Path()
        ..moveTo(0, size.y * 0.42)
        ..lineTo(size.x * 0.24, size.y * 0.66)
        ..lineTo(size.x * 0.12, size.y * 0.88)
        ..close(),
      wing,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.x, size.y * 0.42)
        ..lineTo(size.x * 0.76, size.y * 0.66)
        ..lineTo(size.x * 0.88, size.y * 0.88)
        ..close(),
      wing,
    );
    canvas.drawPath(hull, paint);
    canvas.drawCircle(Offset(size.x / 2, size.y * 0.48), size.x * 0.13, core);
  }

  void _renderPulseSeed(Canvas canvas) {
    final shell = Paint()
      ..color = _hitFlashTimer > 0 ? Colors.white : const Color(0xFFFFC857);
    final armor = Paint()..color = const Color(0xFF765221);
    final core = Paint()..color = const Color(0xFF23180B);
    final ring = Paint()
      ..color = const Color(0xFFFFF3B0).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(
      Path()
        ..moveTo(size.x / 2, 0)
        ..lineTo(size.x, size.y * 0.42)
        ..lineTo(size.x * 0.80, size.y * 0.92)
        ..lineTo(size.x / 2, size.y * 0.76)
        ..lineTo(size.x * 0.20, size.y * 0.92)
        ..lineTo(0, size.y * 0.42)
        ..close(),
      armor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x * 0.18,
          size.y * 0.16,
          size.x * 0.64,
          size.y * 0.58,
        ),
        const Radius.circular(6),
      ),
      shell,
    );
    canvas.drawCircle(Offset(size.x / 2, size.y * 0.44), size.x * 0.18, core);
    canvas.drawLine(
      Offset(size.x / 2, size.y * 0.68),
      Offset(size.x / 2, size.y + 4),
      armor..strokeWidth = 4,
    );
    canvas.drawArc(
      Rect.fromLTWH(6, 6, size.x - 12, size.y - 14),
      _age * _direction,
      math.pi * 1.25,
      false,
      ring,
    );

    if (_fireTimer < 0.35 && position.y > 60) {
      final warning = Paint()
        ..color = const Color(0xFFFF6B6B).withValues(alpha: 0.64)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x * 0.58, warning);
    }
  }

  static Vector2 _sizeFor(SignalEnemyType type) {
    return switch (type) {
      SignalEnemyType.driftNode => Vector2(36, 34),
      SignalEnemyType.pulseSeed => Vector2(46, 48),
    };
  }
}

class _BulletComponent extends CircleComponent
    with CollisionCallbacks, HasGameReference<SignalReefGame> {
  _BulletComponent({
    required this.owner,
    required Vector2 position,
    required this.velocity,
    required double radius,
    required this.damage,
  }) : super(
         position: position,
         radius: radius,
         anchor: Anchor.center,
         paint: Paint()
           ..color = owner == _BulletOwner.player
               ? const Color(0xFFB7FFF6)
               : const Color(0xFFFF6B6B),
       );

  final _BulletOwner owner;
  final Vector2 velocity;
  final int damage;

  @override
  Future<void> onLoad() async {
    await add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    if (position.y < -30 ||
        position.y > game.size.y + 30 ||
        position.x < -40 ||
        position.x > game.size.x + 40) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    switch (owner) {
      case _BulletOwner.player:
        if (other is _EnemyComponent) {
          game._handleEnemyHit(this, other);
        }
      case _BulletOwner.enemy:
        if (other is _PlayerComponent) {
          game._handlePlayerHitByBullet(this);
        }
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(radius, radius);
    final isPlayerShot = owner == _BulletOwner.player;
    final beamColor = isPlayerShot
        ? const Color(0xFF9AFBFF)
        : const Color(0xFFFF4E5F);
    final coreColor = isPlayerShot ? Colors.white : const Color(0xFFFFD0D5);
    final height = isPlayerShot ? 28.0 : 18.0;
    final width = isPlayerShot ? 5.0 : 8.0;
    final glow = Paint()..color = beamColor.withValues(alpha: 0.24);
    final beam = Paint()..color = beamColor;
    final core = Paint()..color = coreColor;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: width + 6, height: height + 8),
        const Radius.circular(8),
      ),
      glow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: width, height: height),
        const Radius.circular(5),
      ),
      beam,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: width * 0.42,
          height: height * 0.70,
        ),
        const Radius.circular(4),
      ),
      core,
    );
  }
}

class _SparkComponent extends PositionComponent {
  _SparkComponent({
    required Vector2 position,
    required this.velocity,
    required this.color,
  }) : super(position: position, size: Vector2.all(4), anchor: Anchor.center);

  final Vector2 velocity;
  final Color color;
  var _life = 0.35;

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt;
    position += velocity * dt;
    if (_life <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final alpha = (_life / 0.35).clamp(0.0, 1.0);
    final paint = Paint()..color = color.withValues(alpha: alpha);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 2.4, paint);
  }
}

class _RingComponent extends PositionComponent {
  _RingComponent({
    required Vector2 position,
    required this.color,
    required this.maxRadius,
  }) : super(position: position, anchor: Anchor.center);

  final Color color;
  final double maxRadius;
  var _life = 0.28;

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt;
    if (_life <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (1 - (_life / 0.28)).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withValues(alpha: (1 - progress) * 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawCircle(Offset.zero, maxRadius * progress, paint);
  }
}

class _FloatingTextComponent extends PositionComponent {
  _FloatingTextComponent({
    required this.text,
    required Vector2 position,
    required this.color,
  }) : super(position: position, anchor: Anchor.center);

  final String text;
  final Color color;
  var _life = 0.72;

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt;
    position += Vector2(0, -36 * dt);
    if (_life <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final alpha = (_life / 0.72).clamp(0.0, 1.0);
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color.withValues(alpha: alpha),
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
  }
}
