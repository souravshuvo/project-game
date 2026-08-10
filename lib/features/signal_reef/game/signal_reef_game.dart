import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

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
    required this.onStateChanged,
    required this.onRunFinished,
  }) : waves = List.unmodifiable(waves);

  static const startingHull = 3;

  final List<WaveDefinition> waves;
  final SignalReefTelemetry telemetry;
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
  List<SignalEnemyType> _spawnQueue = const [];

  WaveDefinition get _currentWave => waves[_waveIndex];

  @override
  Color backgroundColor() => const Color(0xFF07131E);

  @override
  Future<void> onLoad() async {
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

    _updatePlayerFire(dt);
    _updateWaveSpawns(dt);
    _checkWaveCompletion();
  }

  void movePlayerTo(Offset localPosition) {
    if (!isLoaded) {
      return;
    }

    if (runState != SignalReefRunState.playing &&
        runState != SignalReefRunState.ready) {
      return;
    }

    _player.target = _clampPlayerPosition(
      Vector2(localPosition.dx, localPosition.dy),
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

    if (!enemy.isDestroyed) {
      return;
    }

    score += SignalReefScoreRules.enemyDestroyed(enemy.type);
    _killsThisWave++;
    _addBurst(enemy.position, enemy.type);
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
        velocity: Vector2(0, 215),
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
      SignalReefTelemetryEvents.waveStart(waveNumber: currentWaveNumber),
    );
    onStateChanged();
  }

  void _updatePlayerFire(double dt) {
    _fireTimer -= dt;
    if (_fireTimer > 0 || !_player.isMounted) {
      return;
    }

    _fireTimer = 0.35;
    _shotDirection *= -1;
    world.add(
      _BulletComponent(
        owner: _BulletOwner.player,
        position: _player.position + Vector2(0, -24),
        velocity: Vector2(68.0 * _shotDirection, -380),
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
    score += SignalReefScoreRules.waveCleared(clearedWave);
    wavesCleared++;
    telemetry.track(
      SignalReefTelemetryEvents.waveComplete(
        waveNumber: clearedWave,
        score: score,
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
      telemetry.track(SignalReefTelemetryEvents.gameWin(score: score));
    } else {
      runState = SignalReefRunState.lost;
      telemetry.track(
        SignalReefTelemetryEvents.playerDeath(
          score: score,
          waveNumber: currentWaveNumber,
        ),
      );
    }

    onRunFinished(
      SignalReefRunResult(
        score: score,
        waveReached: currentWaveNumber,
        wavesCleared: wavesCleared,
        won: won,
      ),
    );
    onStateChanged();
  }

  void _addBurst(Vector2 position, SignalEnemyType type) {
    final color = switch (type) {
      SignalEnemyType.driftNode => const Color(0xFF50D6C7),
      SignalEnemyType.pulseSeed => const Color(0xFFFFC857),
    };

    for (var index = 0; index < 5; index++) {
      final angle = (math.pi * 2 / 5) * index;
      world.add(
        _SparkComponent(
          position: position.clone(),
          velocity: Vector2(math.cos(angle), math.sin(angle)) * 72,
          color: color,
        ),
      );
    }
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
  final _starPaint = Paint()..color = const Color(0xFFB7FFF6);
  final _currentPaint = Paint()
    ..color = const Color(0xFF1F6C80).withValues(alpha: 0.26)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Offset.zero & Size(size.x, size.y);
    final background = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF07131E), Color(0xFF102333), Color(0xFF092621)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRect(rect, background);

    for (var index = 0; index < 36; index++) {
      final x = (index * 47) % math.max(1, size.x.toInt());
      final y = (index * 83) % math.max(1, size.y.toInt());
      canvas.drawCircle(
        Offset(x.toDouble(), y.toDouble()),
        index.isEven ? 1.2 : 0.8,
        _starPaint..color = _starPaint.color.withValues(alpha: 0.28),
      );
    }

    for (var y = -40.0; y < size.y + 80; y += 96) {
      final path = Path()
        ..moveTo(-20, y)
        ..quadraticBezierTo(size.x * 0.42, y + 48, size.x + 20, y + 8);
      canvas.drawPath(path, _currentPaint);
    }
  }
}

class _PlayerComponent extends PositionComponent with CollisionCallbacks {
  _PlayerComponent() : super(size: Vector2(34, 42), anchor: Anchor.center);

  Vector2? target;
  var _invulnerableTimer = 0.0;

  bool get canTakeDamage => _invulnerableTimer <= 0;

  @override
  Future<void> onLoad() async {
    await add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_invulnerableTimer > 0) {
      _invulnerableTimer -= dt;
    }

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

    final body = Paint()..color = const Color(0xFF7EF9D4);
    final core = Paint()..color = const Color(0xFFFFFFFF);
    final trail = Paint()
      ..color = const Color(0xFF2E9CFF).withValues(alpha: 0.72);
    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x, size.y * 0.76)
      ..quadraticBezierTo(size.x / 2, size.y, 0, size.y * 0.76)
      ..close();

    canvas.drawPath(path, body);
    canvas.drawCircle(Offset(size.x / 2, size.y * 0.46), 5, core);
    canvas.drawLine(
      Offset(size.x / 2, size.y * 0.88),
      Offset(size.x / 2, size.y + 12),
      trail..strokeWidth = 3,
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
    final paint = Paint()..color = const Color(0xFF50D6C7);
    final inner = Paint()..color = const Color(0xFF0C3B46);
    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x, size.y / 2)
      ..lineTo(size.x / 2, size.y)
      ..lineTo(0, size.y / 2)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x * 0.18, inner);
  }

  void _renderPulseSeed(Canvas canvas) {
    final shell = Paint()..color = const Color(0xFFFFC857);
    final core = Paint()..color = const Color(0xFF453212);
    final ring = Paint()
      ..color = const Color(0xFFFFF3B0).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawOval(Offset.zero & Size(size.x, size.y), shell);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x * 0.23, core);
    canvas.drawArc(
      Rect.fromLTWH(4, 8, size.x - 8, size.y - 16),
      _age * _direction,
      math.pi * 1.35,
      false,
      ring,
    );
  }

  static Vector2 _sizeFor(SignalEnemyType type) {
    return switch (type) {
      SignalEnemyType.driftNode => Vector2(30, 30),
      SignalEnemyType.pulseSeed => Vector2(38, 42),
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
  var _hasBounced = false;

  @override
  Future<void> onLoad() async {
    await add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    if (owner == _BulletOwner.player) {
      _updateBounce();
    }

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

  void _updateBounce() {
    final left = radius;
    final right = game.size.x - radius;
    final hitSide = position.x <= left || position.x >= right;

    if (!hitSide) {
      return;
    }

    if (_hasBounced) {
      removeFromParent();
      return;
    }

    _hasBounced = true;
    velocity.x = -velocity.x;
    position.x = position.x.clamp(left, right).toDouble();
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
