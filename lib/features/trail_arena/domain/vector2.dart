import 'dart:math' as math;

class Vec2 {
  const Vec2(this.x, this.y);

  final double x;
  final double y;

  Vec2 operator +(Vec2 other) => Vec2(x + other.x, y + other.y);

  Vec2 operator -(Vec2 other) => Vec2(x - other.x, y - other.y);

  Vec2 operator *(double scale) => Vec2(x * scale, y * scale);

  double get length => math.sqrt((x * x) + (y * y));

  double get angle => math.atan2(y, x);

  Vec2 normalized() {
    final magnitude = length;
    if (magnitude == 0) {
      return const Vec2(0, 0);
    }
    return Vec2(x / magnitude, y / magnitude);
  }

  double distanceTo(Vec2 other) => (this - other).length;

  Vec2 lerp(Vec2 other, double t) {
    return Vec2(x + ((other.x - x) * t), y + ((other.y - y) * t));
  }

  static Vec2 fromAngle(double angle) {
    return Vec2(math.cos(angle), math.sin(angle));
  }
}
