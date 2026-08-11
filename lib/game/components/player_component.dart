import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../world/world_config.dart';

class PlayerComponent {
  PlayerComponent();

  double x = 0;
  double y = 0;
  double velocityX = 0;
  double velocityY = 0;

  Size get size => WorldConfig.playerSize;

  Rect get rect => Rect.fromLTWH(x, y, size.width, size.height);

  void reset({required Size viewport, required double platformTop}) {
    x = viewport.width / 2 - size.width / 2;
    y = platformTop - size.height;
    velocityX = 0;
    velocityY = 0;
  }

  void launch() {
    velocityY = WorldConfig.jumpImpulse;
  }

  void stop() {
    velocityX = 0;
    velocityY = 0;
  }

  void applyHorizontalInput(double dt, int inputAxis) {
    if (inputAxis != 0) {
      velocityX += inputAxis * WorldConfig.moveAcceleration * dt;
    } else {
      final drag = WorldConfig.airDrag * dt;
      if (velocityX.abs() <= drag) {
        velocityX = 0;
      } else {
        velocityX -= drag * velocityX.sign;
      }
    }

    velocityX = velocityX
        .clamp(-WorldConfig.maxHorizontalSpeed, WorldConfig.maxHorizontalSpeed)
        .toDouble();
  }

  void step(double dt, Size viewport) {
    x = (x + velocityX * dt).clamp(
      0.0,
      math.max(0.0, viewport.width - size.width),
    );
    y += velocityY * dt;
    velocityY += WorldConfig.gravity * dt;
  }

  void landOn(double platformTop) {
    y = platformTop - size.height;
    launch();
  }
}
