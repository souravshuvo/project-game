import 'package:flutter/material.dart';

import '../models/spawn_pattern.dart';
import 'platform_component.dart';

class HazardComponent {
  const HazardComponent(this.left, this.baseY, this.width, this.height);

  factory HazardComponent.fromPlatform(
    PlatformComponent platform,
    HazardSlot slot,
  ) {
    const hazardWidth = 30.0;
    const hazardHeight = 34.0;
    final left = switch (slot) {
      HazardSlot.left => platform.left + 18,
      HazardSlot.center => platform.left + platform.width / 2 - hazardWidth / 2,
      HazardSlot.right => platform.right - 18 - hazardWidth,
      HazardSlot.none => platform.left,
    };

    return HazardComponent(left, platform.top, hazardWidth, hazardHeight);
  }

  final double left;
  final double baseY;
  final double width;
  final double height;

  double get right => left + width;
  double get top => baseY - height;

  Rect get hitBox =>
      Rect.fromLTWH(left + width * 0.22, top + 8, width * 0.56, height - 10);
}
