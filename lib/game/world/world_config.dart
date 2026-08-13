import 'package:flutter/material.dart';

class WorldConfig {
  const WorldConfig._();

  static const gameTitle = 'Cloud Courier Climb';
  static const bestScoreChannel = 'cloud_courier_climb/best_score';
  static const settingsChannel = 'cloud_courier_climb/settings';

  static const playerSize = Size(30, 40);
  static const gravity = 1600.0;
  static const jumpImpulse = -640.0;
  static const moveAcceleration = 1900.0;
  static const maxHorizontalSpeed = 300.0;
  static const airDrag = 980.0;

  static const maxFrameStep = 1 / 30;
  static const cameraAnchor = 0.42;
  static const cameraEase = 8.0;
  static const fallMargin = 130.0;
  static const trimMargin = 280.0;

  static const safeMaxVerticalGap = 110.0;
  static const safeMinVerticalGap = 76.0;
  static const safeMaxHorizontalOffset = 106.0;
  static const hazardMinPlatformWidth = 132.0;
  static const firstHazardPlatform = 5;

  static double startPlatformTop(Size viewport) {
    return viewport.height * 0.74 > 280.0 ? viewport.height * 0.74 : 280.0;
  }

  static double starterPlatformWidth(Size viewport) {
    final responsiveWidth = viewport.width * 0.78;
    return responsiveWidth < 260.0 ? responsiveWidth : 260.0;
  }
}
