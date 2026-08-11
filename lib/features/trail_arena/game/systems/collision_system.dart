import '../../domain/vector2.dart';
import '../components/trail_actor_component.dart';

class CollisionSystem {
  const CollisionSystem({
    required this.arenaWidth,
    required this.arenaHeight,
    required this.headRadius,
    required this.bodyRadius,
  });

  final double arenaWidth;
  final double arenaHeight;
  final double headRadius;
  final double bodyRadius;

  bool hitsBoundary(Vec2 head) {
    return head.x < headRadius ||
        head.x > arenaWidth - headRadius ||
        head.y < headRadius ||
        head.y > arenaHeight - headRadius;
  }

  bool hitsTrail(
    Vec2 head,
    TrailActorComponent actor, {
    double skipHeadDistance = 0,
  }) {
    final trail = actor.trail;
    if (trail.length < 2) {
      return false;
    }

    var skippedLength = 0.0;
    for (var i = 0; i < trail.length - 1; i++) {
      final a = trail[i];
      final b = trail[i + 1];
      final segmentLength = a.distanceTo(b);
      if (skippedLength < skipHeadDistance) {
        skippedLength += segmentLength;
        continue;
      }

      if (_distanceToSegment(head, a, b) <= headRadius + bodyRadius - 5) {
        return true;
      }
    }
    return false;
  }

  bool hitsHead(Vec2 a, Vec2 b) {
    return a.distanceTo(b) <= headRadius * 1.65;
  }

  double _distanceToSegment(Vec2 point, Vec2 a, Vec2 b) {
    final ab = b - a;
    final ap = point - a;
    final lengthSquared = (ab.x * ab.x) + (ab.y * ab.y);
    if (lengthSquared == 0) {
      return point.distanceTo(a);
    }

    final rawT = ((ap.x * ab.x) + (ap.y * ab.y)) / lengthSquared;
    final t = rawT.clamp(0.0, 1.0);
    return point.distanceTo(a.lerp(b, t));
  }
}
