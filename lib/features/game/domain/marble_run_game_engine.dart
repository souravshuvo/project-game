import 'dart:math' as math;
import 'dart:ui';

import 'game_events.dart';
import 'game_model.dart';

class MarbleRunGameEngine {
  MarbleRunGameEngine({
    required this.level,
    required this.levelCount,
    this.onEvent,
  }) {
    restart(emitEvent: false);
  }

  final LevelDefinition level;
  final int levelCount;
  final GameEventSink? onEvent;

  final List<MarbleUnit> units = <MarbleUnit>[];
  final Set<String> triggeredGateIds = <String>{};
  final Set<String> appliedGateIds = <String>{};

  late Map<String, EnemyState> _enemyStates;

  GamePhase phase = GamePhase.ready;
  int reserveCount = 0;
  int activeCount = 0;
  double launcherX = gameWorldSize.width / 2;
  bool isLaunching = false;
  double elapsedSeconds = 0;
  String lastMessage = 'Drag to launch';

  double _spawnAccumulator = 0;
  double _messageTimer = 0;
  double _crowdSpread = 24;
  int _nextUnitId = 0;
  bool _reserveEmptyEmitted = false;
  bool _crowdZeroEmitted = false;

  Iterable<EnemyState> get enemyStates => _enemyStates.values;

  GameSnapshot get snapshot {
    final result = phase == GamePhase.won
        ? scoreLevel(
            level: level,
            remainingCount: activeCount,
            elapsedSeconds: elapsedSeconds,
          )
        : const ScoreResult(score: 0, stars: 0);

    return GameSnapshot(
      phase: phase,
      levelId: level.id,
      levelNumber: level.number,
      levelCount: levelCount,
      levelName: level.name,
      reserveCount: reserveCount,
      activeCount: activeCount,
      enemyStrength: _enemyStates.values.fold<int>(
        0,
        (total, enemy) => total + math.max(0, enemy.remainingStrength),
      ),
      score: result.score,
      stars: result.stars,
      elapsedSeconds: elapsedSeconds,
      message: lastMessage,
    );
  }

  void restart({bool emitEvent = true}) {
    if (emitEvent) {
      _emit(GameEventNames.levelRestart);
    }

    units.clear();
    triggeredGateIds.clear();
    appliedGateIds.clear();
    _enemyStates = {
      for (final enemy in level.enemies) enemy.id: EnemyState(enemy),
    };
    phase = GamePhase.ready;
    reserveCount = level.startReserve;
    activeCount = 0;
    launcherX = gameWorldSize.width / 2;
    isLaunching = false;
    elapsedSeconds = 0;
    lastMessage = 'Drag to launch';
    _spawnAccumulator = 0;
    _messageTimer = 0;
    _crowdSpread = 24;
    _nextUnitId = 0;
    _reserveEmptyEmitted = false;
    _crowdZeroEmitted = false;
  }

  void setLauncherX(double worldX) {
    launcherX = worldX.clamp(36.0, gameWorldSize.width - 36).toDouble();
  }

  void setLaunching(bool launching) {
    if (phase == GamePhase.won || phase == GamePhase.lost) {
      isLaunching = false;
      return;
    }

    isLaunching = launching;
    if (launching && phase == GamePhase.ready) {
      phase = GamePhase.playing;
      _setMessage('Choose a gate');
      _emit(GameEventNames.levelStart);
    }
  }

  void update(double dt) {
    if (phase != GamePhase.playing) {
      return;
    }

    final step = dt.clamp(0.0, 0.05).toDouble();
    elapsedSeconds += step;
    _tickMessage(step);
    _spawnUnits(step);
    _moveUnits(step);
    _checkGates();
    _resolveEnemyCombat();
    _checkEndState();
  }

  void _spawnUnits(double dt) {
    if (!isLaunching || reserveCount <= 0) {
      return;
    }

    _spawnAccumulator += dt * level.launchRate;
    while (_spawnAccumulator >= 1 && reserveCount > 0) {
      _spawnAccumulator -= 1;
      reserveCount -= 1;
      activeCount += 1;
      _addVisualUnits(1, x: launcherX, y: gameWorldSize.height - 68);
    }

    if (reserveCount == 0 && !_reserveEmptyEmitted) {
      _reserveEmptyEmitted = true;
      _emit(GameEventNames.reserveEmpty);
    }
  }

  void _moveUnits(double dt) {
    final steering = math.min(1.0, dt * 2.6);
    for (final unit in units) {
      final targetX = launcherX + unit.slot * _crowdSpread;
      unit.x += (targetX - unit.x) * steering;
      unit.x = unit.x.clamp(20.0, gameWorldSize.width - 20).toDouble();
      unit.y -= level.unitSpeed * dt;
    }
  }

  void _checkGates() {
    final gateHits = <_GateHit>[];
    for (final gate in level.gates) {
      if (triggeredGateIds.contains(gate.id)) {
        continue;
      }

      final bounds = gate.bounds.inflate(4);
      final hitCount = units
          .where((unit) => bounds.contains(unit.position))
          .length;
      if (hitCount > 0) {
        gateHits.add(_GateHit(gate: gate, hitCount: hitCount));
      }
    }

    final handledGroups = <String>{};
    for (final hit in gateHits) {
      final groupKey = hit.gate.choiceGroup ?? hit.gate.id;
      if (handledGroups.contains(groupKey)) {
        continue;
      }

      final groupHits = gateHits.where((candidate) {
        final candidateKey = candidate.gate.choiceGroup ?? candidate.gate.id;
        return candidateKey == groupKey;
      }).toList();
      final selectedHit = _selectGateHit(groupHits);
      _applyGate(selectedHit.gate);
      handledGroups.add(groupKey);
    }
  }

  _GateHit _selectGateHit(List<_GateHit> candidates) {
    final crowdCenterX = _crowdCenterX();
    candidates.sort((a, b) {
      final hitCompare = b.hitCount.compareTo(a.hitCount);
      if (hitCompare != 0) {
        return hitCompare;
      }

      final aDistance = (a.gate.center.dx - crowdCenterX).abs();
      final bDistance = (b.gate.center.dx - crowdCenterX).abs();
      final distanceCompare = aDistance.compareTo(bDistance);
      if (distanceCompare != 0) {
        return distanceCompare;
      }

      return a.gate.id.compareTo(b.gate.id);
    });
    return candidates.first;
  }

  void _applyGate(GateDefinition gate) {
    _markGateTriggered(gate);
    appliedGateIds.add(gate.id);

    final before = activeCount;
    final after = gate.effect.applyTo(activeCount, level.maxCrowd);
    activeCount = after;
    _applyFormationEffect(gate.effect);
    _syncVisualTarget(gate.center);
    _setMessage('${gate.effect.label}: $before -> $after');
    _emit(GameEventNames.gateSelected, {
      'gate_id': gate.id,
      'effect': gate.effect.label,
      'before': before,
      'after': after,
    });
  }

  void _markGateTriggered(GateDefinition gate) {
    triggeredGateIds.add(gate.id);

    final choiceGroup = gate.choiceGroup;
    if (choiceGroup == null) {
      return;
    }

    for (final otherGate in level.gates) {
      if (otherGate.choiceGroup == choiceGroup) {
        triggeredGateIds.add(otherGate.id);
      }
    }
  }

  void _applyFormationEffect(GateEffect effect) {
    switch (effect.kind) {
      case GateKind.wide:
        _crowdSpread = math.min(42, _crowdSpread + 12);
        break;
      case GateKind.tight:
        _crowdSpread = math.max(12, _crowdSpread - 12);
        break;
      case GateKind.add:
      case GateKind.multiply:
      case GateKind.subtract:
        break;
    }
  }

  void _resolveEnemyCombat() {
    final enemy = _firstCollidingEnemy();
    if (enemy == null) {
      return;
    }

    final beforeActive = activeCount;
    final beforeEnemy = enemy.remainingStrength;
    final damage = math.min(activeCount, enemy.remainingStrength);
    if (damage <= 0) {
      return;
    }

    activeCount -= damage;
    enemy.remainingStrength -= damage;
    _removeVisualUnits(
      _visualLossForDamage(beforeActive: beforeActive, damage: damage),
      near: enemy.definition.center,
    );
    _syncVisualTarget(enemy.definition.center);

    _emit(GameEventNames.enemyCollision, {
      'enemy_id': enemy.definition.id,
      'before_crowd': beforeActive,
      'after_crowd': activeCount,
      'before_enemy': beforeEnemy,
      'after_enemy': enemy.remainingStrength,
    });

    if (enemy.defeated) {
      _setMessage('Cluster cleared');
      _emit(GameEventNames.enemyCleared, {'enemy_id': enemy.definition.id});
    } else {
      _setMessage('Need more marbles');
    }

    if (activeCount == 0 && !_crowdZeroEmitted) {
      _crowdZeroEmitted = true;
      _emit(GameEventNames.crowdZero);
    }
  }

  int _visualLossForDamage({required int beforeActive, required int damage}) {
    if (units.isEmpty || beforeActive <= 0) {
      return 0;
    }

    final proportionalLoss = units.length * damage / beforeActive;
    return proportionalLoss.ceil().clamp(1, units.length).toInt();
  }

  EnemyState? _firstCollidingEnemy() {
    for (final enemy in _enemyStates.values) {
      if (enemy.defeated) {
        continue;
      }

      final bounds = enemy.definition.bounds.inflate(8);
      final touched = units.any((unit) => bounds.contains(unit.position));
      if (touched) {
        return enemy;
      }
    }

    return null;
  }

  void _checkEndState() {
    if (_enemyStates.values.every((enemy) => enemy.defeated) &&
        activeCount > 0) {
      _finish(GamePhase.won, 'Level clear', GameEventNames.levelWin);
      return;
    }

    if (activeCount <= 0 && reserveCount <= 0) {
      _finish(GamePhase.lost, 'Try again', GameEventNames.levelLose);
      return;
    }

    final allUnitsPassedFinish =
        reserveCount <= 0 &&
        units.isNotEmpty &&
        units.every((unit) => unit.y <= level.finishY);
    if (allUnitsPassedFinish) {
      _finish(GamePhase.lost, 'Cluster survived', GameEventNames.levelLose);
    }
  }

  void _finish(GamePhase result, String message, String eventName) {
    phase = result;
    isLaunching = false;
    _setMessage(message, persist: true);
    _emit(eventName, {
      'result': result.name,
      'remaining_crowd': activeCount,
      'remaining_reserve': reserveCount,
      'elapsed_seconds': elapsedSeconds,
    });
  }

  void _syncVisualTarget(Offset center) {
    final targetVisualCount = math.min(activeCount, level.visualCap);
    if (targetVisualCount > units.length) {
      _addVisualUnits(
        targetVisualCount - units.length,
        x: center.dx,
        y: center.dy + 18,
      );
    } else if (targetVisualCount < units.length) {
      _removeVisualUnits(units.length - targetVisualCount, near: center);
    }

    if (activeCount <= 0) {
      units.clear();
    }
  }

  void _addVisualUnits(int count, {required double x, required double y}) {
    final allowed = math.min(count, level.visualCap - units.length);
    for (var i = 0; i < allowed; i += 1) {
      final id = _nextUnitId;
      _nextUnitId += 1;
      final slot = ((id * 37) % 11 - 5) / 5;
      final yJitter = ((id * 19) % 9 - 4).toDouble();
      units.add(
        MarbleUnit(
          id: id,
          x: (x + slot * _crowdSpread * 0.4)
              .clamp(20.0, gameWorldSize.width - 20)
              .toDouble(),
          y: y + yJitter,
          slot: slot,
        ),
      );
    }
  }

  void _removeVisualUnits(int count, {Offset? near}) {
    if (count <= 0 || units.isEmpty) {
      return;
    }

    if (near != null) {
      units.sort((a, b) {
        final aDistance = _distanceSquared(a.position, near);
        final bDistance = _distanceSquared(b.position, near);
        return aDistance.compareTo(bDistance);
      });
    }

    units.removeRange(0, math.min(count, units.length));
  }

  double _crowdCenterX() {
    if (units.isEmpty) {
      return launcherX;
    }

    final total = units.fold<double>(0, (sum, unit) => sum + unit.x);
    return total / units.length;
  }

  double _distanceSquared(Offset a, Offset b) {
    final dx = a.dx - b.dx;
    final dy = a.dy - b.dy;
    return dx * dx + dy * dy;
  }

  void _setMessage(String message, {bool persist = false}) {
    lastMessage = message;
    _messageTimer = persist ? double.infinity : 1.2;
  }

  void _tickMessage(double dt) {
    if (_messageTimer == double.infinity || _messageTimer <= 0) {
      return;
    }

    _messageTimer -= dt;
    if (_messageTimer <= 0) {
      lastMessage = '';
    }
  }

  void _emit(String name, [Map<String, Object?> properties = const {}]) {
    onEvent?.call(name, {
      'level_id': level.id,
      'level_number': level.number,
      ...properties,
    });
  }
}

class _GateHit {
  const _GateHit({required this.gate, required this.hitCount});

  final GateDefinition gate;
  final int hitCount;
}
