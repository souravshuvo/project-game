import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../cloud_courier_game.dart';
import 'hazard_component.dart';
import 'pickup_component.dart';
import 'platform_component.dart';

class BackgroundComponent {
  const BackgroundComponent();

  void paint(Canvas canvas, Size size, CloudCourierGame game) {
    final bounds = Offset.zero & size;
    _drawSky(canvas, bounds);
    _drawDistantWeatherStations(canvas, size, game.cameraY);
    _drawWindStreaks(canvas, size, game);
    _drawPlatforms(canvas, game.platforms, game.cameraY, game.visualTime);
    _drawPickups(canvas, game.pickups, game.cameraY, game.visualTime);
    _drawHazards(canvas, game.hazards, game.cameraY, game.visualTime);
    _drawCourier(canvas, game);
    _drawScreenFlash(canvas, bounds, game.hitFlash);
  }

  void _drawSky(Canvas canvas, Rect bounds) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xfffff2c6), Color(0xff9bd7d5), Color(0xff1d6f78)],
      ).createShader(bounds);

    canvas.drawRect(bounds, paint);
  }

  void _drawDistantWeatherStations(Canvas canvas, Size size, double cameraY) {
    final paint = Paint()..color = const Color(0xff1f5b61).withAlpha(80);
    final drift = (cameraY.abs() * 0.08) % 90;

    for (var i = 0; i < 6; i += 1) {
      final center = Offset(
        (i.isEven ? size.width * 0.22 : size.width * 0.75),
        i * 150.0 + 58 - drift,
      );
      final body = Rect.fromCenter(center: center, width: 92, height: 18);
      canvas.drawRRect(
        RRect.fromRectAndRadius(body, const Radius.circular(8)),
        paint,
      );
      canvas.drawCircle(center.translate(-28, -16), 9, paint);
      canvas.drawCircle(center.translate(30, -14), 7, paint);
    }
  }

  void _drawWindStreaks(Canvas canvas, Size size, CloudCourierGame game) {
    final paint = Paint()
      ..color = const Color(0xfffff8df).withAlpha(76)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 9; i += 1) {
      final y =
          (i * 91 + game.visualTime * 34 - game.cameraY * 0.18) %
          (size.height + 120);
      final x =
          (i.isEven ? size.width * 0.12 : size.width * 0.56) +
          math.sin(game.visualTime * 0.9 + i) * 18;
      final length = 34 + (i % 3) * 18;
      canvas.drawLine(Offset(x, y - 60), Offset(x + length, y - 66), paint);
    }
  }

  void _drawPlatforms(
    Canvas canvas,
    List<PlatformComponent> platforms,
    double cameraY,
    double visualTime,
  ) {
    for (final platform in platforms) {
      final bob =
          math.sin(platform.left * 0.035 + cameraY * 0.012 + visualTime * 1.8) *
          1.8;
      final screenY = platform.top - cameraY + bob;
      final rect = Rect.fromLTWH(
        platform.left,
        screenY,
        platform.width,
        platform.height,
      );
      final body = RRect.fromRectAndRadius(rect, const Radius.circular(6));
      final top = RRect.fromRectAndRadius(
        Rect.fromLTWH(platform.left, screenY - 5, platform.width, 10),
        const Radius.circular(6),
      );

      canvas.drawRRect(
        body.shift(const Offset(0, 5)),
        Paint()..color = const Color(0xff163d3f).withAlpha(92),
      );
      canvas.drawRRect(body, Paint()..color = const Color(0xff274c48));
      canvas.drawRRect(top, Paint()..color = const Color(0xffffcb5b));

      final shineX =
          platform.left + (platform.width * ((cameraY * 0.006) % 1.0));
      final shineEnd = (shineX + platform.width * 0.22)
          .clamp(platform.left, platform.right)
          .toDouble();
      canvas.drawLine(
        Offset(shineX, screenY - 5),
        Offset(shineEnd, screenY - 5),
        Paint()
          ..color = const Color(0xfffff8df).withAlpha(128)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawPickups(
    Canvas canvas,
    List<PickupComponent> pickups,
    double cameraY,
    double visualTime,
  ) {
    for (final pickup in pickups) {
      if (pickup.collected) {
        continue;
      }

      final pulse =
          0.55 + 0.45 * math.sin(visualTime * 5.2 + pickup.position.dx * 0.04);
      final center = Offset(
        pickup.position.dx,
        pickup.position.dy - cameraY + math.sin(visualTime * 3.4) * 2,
      );

      canvas.drawCircle(
        center,
        pickup.radius + 6 + pulse * 3,
        Paint()..color = const Color(0xfffff8df).withAlpha(44),
      );
      canvas.drawCircle(
        center,
        pickup.radius + pulse * 2,
        Paint()..color = const Color(0xffffcb5b).withAlpha(210),
      );
      canvas.drawCircle(
        center,
        pickup.radius * 0.48,
        Paint()..color = const Color(0xff1d6f78),
      );
      canvas.drawLine(
        center.translate(-pickup.radius - 2, 0),
        center.translate(pickup.radius + 2, 0),
        Paint()
          ..color = const Color(0xfffff8df).withAlpha(180)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawHazards(
    Canvas canvas,
    List<HazardComponent> hazards,
    double cameraY,
    double visualTime,
  ) {
    final warning = Paint()
      ..color = const Color(0xfffff1a6)
      ..strokeWidth = 3;

    for (final hazard in hazards) {
      final baseY = hazard.baseY - cameraY;
      final top = hazard.top - cameraY;
      final pulse =
          0.5 +
          0.5 * math.sin(visualTime * 6 + cameraY * 0.03 + hazard.left * 0.07);
      final centerX = hazard.left + hazard.width / 2;
      final path = Path()
        ..moveTo(hazard.left, baseY)
        ..lineTo(centerX, top - pulse * 4)
        ..lineTo(hazard.right, baseY)
        ..close();

      canvas.drawCircle(
        Offset(centerX, top + 3),
        16 + pulse * 5,
        Paint()..color = const Color(0xfffff1a6).withAlpha(38),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Color.lerp(
            const Color(0xffb82435),
            const Color(0xffff5b46),
            pulse,
          )!,
      );
      canvas.drawLine(
        Offset(hazard.left - 7, baseY + 3),
        Offset(hazard.right + 7, baseY + 3),
        warning,
      );
      canvas.drawLine(
        Offset(hazard.left + hazard.width * 0.34, baseY - 9),
        Offset(hazard.left + hazard.width * 0.5, baseY - 21),
        Paint()
          ..color = const Color(0xfffff1a6)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );

      for (var i = 0; i < 3; i += 1) {
        final sparkPhase = pulse + i * 0.7;
        canvas.drawCircle(
          Offset(
            centerX + math.sin(sparkPhase * math.pi * 2) * (8 + i * 3),
            top + 7 + math.cos(sparkPhase * math.pi * 2) * 8,
          ),
          1.6 + pulse,
          Paint()..color = const Color(0xfffff1a6).withAlpha(150),
        );
      }
    }
  }

  void _drawCourier(Canvas canvas, CloudCourierGame game) {
    final rect = game.playerRect.translate(0, -game.cameraY);
    final center = rect.center;
    final tilt = (game.player.velocityX / 520).clamp(-0.35, 0.35).toDouble();
    final squash = game.landingPulse;
    final stretch = (game.player.velocityY < 0 ? 0.08 : 0.0) + squash * 0.12;
    final shadow = Rect.fromCenter(
      center: Offset(rect.center.dx, rect.bottom + 7),
      width: rect.width * (1.18 + squash * 0.25),
      height: 7 + squash * 2,
    );

    canvas.drawOval(
      shadow,
      Paint()..color = const Color(0xff062d33).withAlpha(62),
    );

    for (var i = 0; i < 4; i += 1) {
      final trailOffset = Offset(
        -game.player.velocityX * 0.018 * (i + 1),
        12.0 + i * 10 + game.player.velocityY.abs() * 0.005,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center + trailOffset,
            width: rect.width * (0.55 - i * 0.08),
            height: 8,
          ),
          const Radius.circular(8),
        ),
        Paint()..color = const Color(0xfffff8df).withAlpha(70 - i * 12),
      );
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt);
    canvas.scale(1 + squash * 0.08, 1 + stretch - squash * 0.16);
    canvas.translate(-center.dx, -center.dy);

    final body = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(body, Paint()..color = const Color(0xfff6fbf4));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left + 5, rect.top + 7, rect.width - 10, 12),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xfff06b50),
    );
    canvas.drawRect(
      Rect.fromLTWH(rect.left + 8, rect.bottom - 10, rect.width - 16, 7),
      Paint()..color = const Color(0xff1d6f78),
    );

    canvas.drawCircle(
      Offset(rect.left + rect.width * 0.66, rect.top + 12),
      2.2,
      Paint()..color = const Color(0xff062d33),
    );
    canvas.restore();
  }

  void _drawScreenFlash(Canvas canvas, Rect bounds, double hitFlash) {
    if (hitFlash <= 0) {
      return;
    }

    canvas.drawRect(
      bounds,
      Paint()
        ..color = const Color(0xffff5b46).withAlpha((hitFlash * 90).round()),
    );
  }
}

class CloudCourierPainter extends CustomPainter {
  const CloudCourierPainter(this.game);

  final CloudCourierGame game;
  static const _background = BackgroundComponent();

  @override
  void paint(Canvas canvas, Size size) {
    _background.paint(canvas, size, game);
  }

  @override
  bool shouldRepaint(covariant CloudCourierPainter oldDelegate) => true;
}
