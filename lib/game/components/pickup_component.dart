import 'package:flutter/material.dart';

class PickupComponent {
  const PickupComponent({
    required this.position,
    this.radius = 9,
    this.scoreValue = 12,
    this.collected = false,
  });

  final Offset position;
  final double radius;
  final int scoreValue;
  final bool collected;

  Rect get bounds => Rect.fromCircle(center: position, radius: radius);

  PickupComponent markCollected() {
    return PickupComponent(
      position: position,
      radius: radius,
      scoreValue: scoreValue,
      collected: true,
    );
  }
}
