import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../domain/combat_math.dart';
import '../domain/gate_math.dart';
import '../domain/level_definition.dart';
import '../domain/level_result.dart';
import 'components/enemy_group_component.dart';
import 'components/feedback_burst_component.dart';
import 'components/gate_component.dart';
import 'components/launcher_component.dart';
import 'components/level_bounds_component.dart';
import 'components/power_node_component.dart';
import 'components/spark_crowd_component.dart';

class PulseParadeGame extends FlameGame {
  PulseParadeGame({required this.level})
    : snapshot = ValueNotifier<PulseGameSnapshot>(
        PulseGameSnapshot.initial(level),
      );

  final PulseParadeLevel level;
  final ValueNotifier<PulseGameSnapshot> snapshot;

  late final LevelBoundsComponent _background;
  late final LauncherComponent _launcher;
  late final SparkCrowdComponent _crowd;
  late final PowerNodeComponent _powerNode;
  late final Map<String, GateComponent> _gateComponents;
  late final Map<String, EnemyGroupComponent> _enemyComponents;

  final Set<String> _activatedGateIds = <String>{};
  final Set<String> _resolvedEnemyIds = <String>{};

  var _componentsReady = false;
  var _status = PulseLevelStatus.ready;
  var _sparkCount = 0;
  var _polarity = PulsePolarity.cyan;
  var _progressY = 0.0;
  var _crowdX = 180.0;
  var _targetX = 180.0;
  var _deliveredCharge = 0;
  var _message = 'Guide the spark stream';
  var _snapshotTimer = 0.0;
  var _nodeReached = false;

  @override
  Color backgroundColor() => const Color(0xFF101018);

  @override
  Future<void> onLoad() async {
    _background = LevelBoundsComponent();
    _launcher = LauncherComponent();
    _crowd = SparkCrowdComponent(
      sparkCount: level.startingSparkCount,
      polarity: level.startingPolarity,
    );
    _gateComponents = <String, GateComponent>{
      for (final gate in level.gates) gate.id: GateComponent(gate),
    };
    _enemyComponents = <String, EnemyGroupComponent>{
      for (final enemy in level.enemies) enemy.id: EnemyGroupComponent(enemy),
    };
    _powerNode = PowerNodeComponent(level.powerNode);

    await add(_background);
    await addAll(_gateComponents.values);
    await addAll(_enemyComponents.values);
    await add(_powerNode);
    await add(_launcher);
    await add(_crowd);

    _componentsReady = true;
    restart();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _syncComponents();
  }

  void steerToScreenX(double screenX) {
    if (_isFinished || size.x <= 0) {
      return;
    }

    final worldX = ((screenX - _horizontalInset) / _scale).clamp(
      _minCrowdX,
      _maxCrowdX,
    );
    _targetX = worldX.toDouble();
  }

  void restart() {
    if (_componentsReady) {
      removeAll(children.whereType<FeedbackBurstComponent>().toList());
    }
    _activatedGateIds.clear();
    _resolvedEnemyIds.clear();
    _status = PulseLevelStatus.running;
    _sparkCount = level.startingSparkCount;
    _polarity = level.startingPolarity;
    _progressY = 0;
    _crowdX = level.worldWidth / 2;
    _targetX = _crowdX;
    _deliveredCharge = 0;
    _message = 'Guide the spark stream';
    _nodeReached = false;
    _snapshotTimer = 0;
    _syncComponents();
    _publishSnapshot(force: true);
  }

  @override
  void update(double dt) {
    if (_componentsReady && !_isFinished) {
      _progressY = math.min(
        level.worldHeight,
        _progressY + (level.forwardSpeed * dt),
      );

      final deltaX = _targetX - _crowdX;
      final maxStep = level.lateralSpeed * dt;
      _crowdX += deltaX.clamp(-maxStep, maxStep).toDouble();

      _resolveCollisions();
      if (!_nodeReached && _progressY > level.powerNode.area.bottom + 110) {
        _status = PulseLevelStatus.failedUndercharged;
        _message = 'The stream missed the power node';
      }
    }

    _syncComponents();
    _snapshotTimer += dt;
    if (_snapshotTimer >= 0.12 || _isFinished) {
      _snapshotTimer = 0;
      _publishSnapshot();
    }

    super.update(dt);
  }

  bool get _isFinished {
    return switch (_status) {
      PulseLevelStatus.won ||
      PulseLevelStatus.failedDepleted ||
      PulseLevelStatus.failedUndercharged => true,
      PulseLevelStatus.ready || PulseLevelStatus.running => false,
    };
  }

  void _resolveCollisions() {
    final crowdCenter = Offset(_crowdX, _progressY);
    final crowdRect = Rect.fromCircle(
      center: crowdCenter,
      radius: _crowdRadius,
    );

    final gate = choosePulseGateAtPoint(
      point: crowdCenter,
      gates: level.gates,
      activatedGateIds: _activatedGateIds,
    );
    if (gate != null) {
      final countBefore = _sparkCount;
      final polarityBefore = _polarity;
      final result = applyPulseGate(
        sparkCount: _sparkCount,
        polarity: _polarity,
        gate: gate,
      );
      _sparkCount = result.sparkCount;
      _polarity = result.polarity;
      _activatedGateIds.add(gate.id);
      final gateCenter = _screenRectFor(gate.area).center;
      final countDelta = _sparkCount - countBefore;
      if (countDelta != 0) {
        _showFeedback(
          label: _countDeltaLabel(countDelta),
          color: const Color(0xFF31E69E),
          screenPosition: gateCenter,
        );
      }
      if (_polarity != polarityBefore) {
        _showFeedback(
          label: _polarity.name.toUpperCase(),
          color: _polarityColor(_polarity),
          screenPosition: gateCenter.translate(0, -34),
          lifetime: 1.1,
        );
      }
      _message = switch (gate.type) {
        PulseGateType.amplifier => 'Amplified to $_sparkCount sparks',
        PulseGateType.resonator => 'Resonated to $_sparkCount sparks',
        PulseGateType.polarity => 'Polarity tuned to ${_polarity.name}',
      };
      _publishSnapshot(force: true);
    }

    for (final enemy in level.enemies) {
      if (_resolvedEnemyIds.contains(enemy.id) ||
          !crowdRect.overlaps(enemy.area)) {
        continue;
      }
      final result = resolveStaticGlitchCombat(
        sparkCount: _sparkCount,
        polarity: _polarity,
        enemy: enemy,
      );
      _sparkCount = result.sparkCount;
      _resolvedEnemyIds.add(enemy.id);
      _message = result.damagePerSpark == 2
          ? 'Matched polarity cut the glitch down'
          : 'The glitch drained ${result.sparkLoss} sparks';
      final enemyCenter = _screenRectFor(enemy.area).center;
      _showFeedback(
        label: '-${result.sparkLoss}',
        color: const Color(0xFFFF5B7D),
        screenPosition: enemyCenter,
      );
      if (result.damagePerSpark == 2) {
        _showFeedback(
          label: 'MATCH',
          color: _polarityColor(_polarity),
          screenPosition: enemyCenter.translate(0, -38),
          lifetime: 0.8,
        );
      }
      if (_sparkCount <= 0) {
        _status = PulseLevelStatus.failedDepleted;
        _message = 'The glitch drained every spark';
      }
      _publishSnapshot(force: true);
    }

    if (!_nodeReached && crowdRect.overlaps(level.powerNode.area)) {
      _nodeReached = true;
      _deliveredCharge = _sparkCount;
      if (_sparkCount >= level.powerNode.chargeRequired) {
        _status = PulseLevelStatus.won;
        _message = 'Power node charged';
        _showFeedback(
          label: 'CHARGED',
          color: const Color(0xFF8DFF8A),
          screenPosition: _screenRectFor(level.powerNode.area).center,
          lifetime: 1.2,
        );
      } else {
        _status = PulseLevelStatus.failedUndercharged;
        _message = 'The node needed more charge';
      }
      _publishSnapshot(force: true);
    }
  }

  void _syncComponents() {
    if (!_componentsReady || size.x <= 0 || size.y <= 0) {
      return;
    }

    _background.sync(size);
    _launcher.sync(
      screenPosition: Vector2(_screenX(level.worldWidth / 2), size.y * 0.89),
      scale: _scale,
    );
    _crowd.sync(
      screenPosition: Vector2(_screenX(_crowdX), _playerScreenY),
      crowdRadius: _crowdRadius * _scale,
      sparkCount: _sparkCount,
      polarity: _polarity,
    );

    for (final gate in level.gates) {
      final screenRect = _screenRectFor(gate.area);
      _gateComponents[gate.id]?.sync(
        screenRect: screenRect,
        isActivated: _activatedGateIds.contains(gate.id),
        isVisible: _isVisible(screenRect),
      );
    }

    for (final enemy in level.enemies) {
      final screenRect = _screenRectFor(enemy.area);
      _enemyComponents[enemy.id]?.sync(
        screenRect: screenRect,
        isResolved: _resolvedEnemyIds.contains(enemy.id),
        isVisible: _isVisible(screenRect),
      );
    }

    final nodeRect = _screenRectFor(level.powerNode.area);
    _powerNode.sync(
      screenRect: nodeRect,
      isReached: _nodeReached,
      isVisible: _isVisible(nodeRect),
    );
  }

  void _publishSnapshot({bool force = false}) {
    final progress = (_progressY / level.powerNode.area.center.dy)
        .clamp(0, 1)
        .toDouble();
    final next = PulseGameSnapshot(
      sparkCount: _sparkCount,
      polarity: _polarity,
      status: _status,
      progress: progress,
      message: _message,
      deliveredCharge: _deliveredCharge,
      requiredCharge: level.powerNode.chargeRequired,
    );

    if (force || next != snapshot.value) {
      snapshot.value = next;
    }
  }

  Rect _screenRectFor(Rect worldRect) {
    return Rect.fromLTWH(
      _screenX(worldRect.left),
      _playerScreenY - ((worldRect.top - _progressY) * _scale),
      worldRect.width * _scale,
      worldRect.height * _scale,
    );
  }

  bool _isVisible(Rect screenRect) {
    return screenRect.bottom >= -140 && screenRect.top <= size.y + 140;
  }

  void _showFeedback({
    required String label,
    required Color color,
    required Offset screenPosition,
    double lifetime = 0.95,
  }) {
    if (!_componentsReady || size.x <= 0 || size.y <= 0) {
      return;
    }
    add(
      FeedbackBurstComponent(
        label: label,
        color: color,
        position: Vector2(screenPosition.dx, screenPosition.dy),
        lifetime: lifetime,
      ),
    );
  }

  String _countDeltaLabel(int delta) => delta > 0 ? '+$delta' : '$delta';

  Color _polarityColor(PulsePolarity polarity) {
    return switch (polarity) {
      PulsePolarity.cyan => const Color(0xFF43F0D8),
      PulsePolarity.amber => const Color(0xFFFFC44D),
    };
  }

  double _screenX(double worldX) => _horizontalInset + (worldX * _scale);

  double get _scale {
    if (size.x <= 0) {
      return 1;
    }
    return math.min(size.x / level.worldWidth, 1.35);
  }

  double get _horizontalInset => (size.x - (level.worldWidth * _scale)) / 2;

  double get _playerScreenY => size.y * 0.72;

  double get _crowdRadius {
    final normalized = math.min(_sparkCount, 160) / 160;
    return 18 + (normalized * 44);
  }

  double get _minCrowdX => 24;

  double get _maxCrowdX => level.worldWidth - 24;
}
