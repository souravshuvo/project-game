import 'dart:collection';
import 'dart:math' as math;

import '../../domain/run_state.dart';
import '../../domain/vector2.dart';

class TrailActorComponent {
  TrailActorComponent({
    required this.id,
    required this.kind,
    required Vec2 spawn,
    required double heading,
    required this.baseSpeed,
    required this.turnRate,
    required this.initialLength,
  }) {
    reset(spawn: spawn, heading: heading);
  }

  final int id;
  final ActorKind kind;
  final double baseSpeed;
  final double turnRate;
  final double initialLength;

  final List<Vec2> _trail = <Vec2>[];
  Vec2 head = const Vec2(0, 0);
  double heading = 0;
  double desiredHeading = 0;
  double targetLength = 0;
  bool alive = true;
  double respawnTimer = 0;
  double wanderHeading = 0;
  double wanderClock = 0;

  UnmodifiableListView<Vec2> get trail => UnmodifiableListView(_trail);

  void reset({required Vec2 spawn, required double heading}) {
    head = spawn;
    this.heading = heading;
    desiredHeading = heading;
    targetLength = initialLength;
    alive = true;
    respawnTimer = 0;
    wanderHeading = heading;
    wanderClock = 0;
    _trail
      ..clear()
      ..addAll(_initialTrail());
  }

  void kill({double respawnDelay = 0}) {
    alive = false;
    respawnTimer = respawnDelay;
  }

  void steerWithDirection(Vec2 direction) {
    if (!alive || direction.length < 0.05) {
      return;
    }
    desiredHeading = direction.angle;
  }

  void grow(double amount) {
    targetLength += amount;
  }

  void updateMovement(double dt, {double speedScale = 1}) {
    if (!alive) {
      return;
    }

    final maxTurn = turnRate * dt;
    heading = _turnToward(heading, desiredHeading, maxTurn);
    head = head + (Vec2.fromAngle(heading) * baseSpeed * speedScale * dt);
    _pushTrailPoint(head);
    _trimTrail();
  }

  Iterable<Vec2> _initialTrail() sync* {
    for (var distance = 0.0; distance <= targetLength; distance += 6) {
      yield head - (Vec2.fromAngle(heading) * distance);
    }
  }

  void _pushTrailPoint(Vec2 point) {
    if (_trail.isEmpty || point.distanceTo(_trail.first) >= 5) {
      _trail.insert(0, point);
    } else {
      _trail[0] = point;
    }
  }

  void _trimTrail() {
    if (_trail.length < 2) {
      return;
    }

    var traveled = 0.0;
    for (var i = 0; i < _trail.length - 1; i++) {
      final current = _trail[i];
      final next = _trail[i + 1];
      final segmentLength = current.distanceTo(next);
      if (segmentLength == 0) {
        continue;
      }

      if (traveled + segmentLength >= targetLength) {
        final remaining = targetLength - traveled;
        _trail[i + 1] = current.lerp(next, remaining / segmentLength);
        if (_trail.length > i + 2) {
          _trail.removeRange(i + 2, _trail.length);
        }
        return;
      }
      traveled += segmentLength;
    }
  }

  double _turnToward(double current, double target, double maxStep) {
    final delta = _normalizeAngle(target - current);
    if (delta.abs() <= maxStep) {
      return target;
    }
    return current + (maxStep * delta.sign);
  }

  double _normalizeAngle(double angle) {
    var normalized = angle;
    while (normalized > math.pi) {
      normalized -= math.pi * 2;
    }
    while (normalized < -math.pi) {
      normalized += math.pi * 2;
    }
    return normalized;
  }
}
