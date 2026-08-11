import 'package:flutter/material.dart';

import '../cloud_courier_game.dart';
import 'hazard_component.dart';
import 'platform_component.dart';

class BackgroundComponent {
  const BackgroundComponent();

  void paint(Canvas canvas, Size size, CloudCourierGame game) {
    final bounds = Offset.zero & size;
    _drawSky(canvas, bounds);
    _drawDistantWeatherStations(canvas, size, game.cameraY);
    _drawPlatforms(canvas, game.platforms, game.cameraY);
    _drawHazards(canvas, game.hazards, game.cameraY);
    _drawCourier(canvas, game);
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

  void _drawPlatforms(
    Canvas canvas,
    List<PlatformComponent> platforms,
    double cameraY,
  ) {
    for (final platform in platforms) {
      final screenY = platform.top - cameraY;
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
    }
  }

  void _drawHazards(
    Canvas canvas,
    List<HazardComponent> hazards,
    double cameraY,
  ) {
    final fill = Paint()..color = const Color(0xffd63c3c);
    final warning = Paint()
      ..color = const Color(0xfffff1a6)
      ..strokeWidth = 3;

    for (final hazard in hazards) {
      final baseY = hazard.baseY - cameraY;
      final top = hazard.top - cameraY;
      final path = Path()
        ..moveTo(hazard.left, baseY)
        ..lineTo(hazard.left + hazard.width / 2, top)
        ..lineTo(hazard.right, baseY)
        ..close();

      canvas.drawPath(path, fill);
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
    }
  }

  void _drawCourier(Canvas canvas, CloudCourierGame game) {
    final rect = game.playerRect.translate(0, -game.cameraY);
    final shadow = Rect.fromCenter(
      center: Offset(rect.center.dx, rect.bottom + 7),
      width: rect.width * 1.18,
      height: 7,
    );

    canvas.drawOval(
      shadow,
      Paint()..color = const Color(0xff062d33).withAlpha(62),
    );

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
