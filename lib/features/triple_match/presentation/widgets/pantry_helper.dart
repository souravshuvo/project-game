import 'package:flutter/material.dart';

import '../theme/triple_match_theme.dart';

enum PantryHelperMood { calm, happy, worried }

class PantryHelper extends StatelessWidget {
  const PantryHelper({
    super.key,
    this.size = 96,
    this.mood = PantryHelperMood.calm,
  });

  final double size;
  final PantryHelperMood mood;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _PantryHelperPainter(mood)),
    );
  }
}

class _PantryHelperPainter extends CustomPainter {
  const _PantryHelperPainter(this.mood);

  final PantryHelperMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 96;
    final shadow = Paint()
      ..color = TripleMatchColors.primaryDark.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final body = Paint()
      ..color = TripleMatchColors.surface
      ..style = PaintingStyle.fill;
    final edge = Paint()
      ..color = TripleMatchColors.primary
      ..strokeWidth = 3.4 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final accent = Paint()
      ..color = mood == PantryHelperMood.worried
          ? TripleMatchColors.coral
          : TripleMatchColors.amber
      ..style = PaintingStyle.fill;
    final ink = Paint()
      ..color = TripleMatchColors.primaryDark
      ..strokeWidth = 3.2 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(16 * scale, 18 * scale, 64 * scale, 62 * scale),
      Radius.circular(18 * scale),
    );
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(12 * scale, 12 * scale, 64 * scale, 62 * scale),
      Radius.circular(18 * scale),
    );
    canvas.drawRRect(shadowRect, shadow);
    canvas.drawRRect(bodyRect, body);
    canvas.drawRRect(bodyRect, edge);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(22 * scale, 23 * scale, 44 * scale, 12 * scale),
        Radius.circular(6 * scale),
      ),
      accent,
    );

    final eyePaint = Paint()
      ..color = TripleMatchColors.primaryDark
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(32 * scale, 48 * scale), 3.8 * scale, eyePaint);
    canvas.drawCircle(Offset(56 * scale, 48 * scale), 3.8 * scale, eyePaint);

    final mouthPath = Path();
    switch (mood) {
      case PantryHelperMood.happy:
        mouthPath.moveTo(34 * scale, 58 * scale);
        mouthPath.quadraticBezierTo(
          44 * scale,
          68 * scale,
          56 * scale,
          58 * scale,
        );
        break;
      case PantryHelperMood.worried:
        mouthPath.moveTo(34 * scale, 64 * scale);
        mouthPath.quadraticBezierTo(
          44 * scale,
          56 * scale,
          56 * scale,
          64 * scale,
        );
        break;
      case PantryHelperMood.calm:
        mouthPath.moveTo(34 * scale, 61 * scale);
        mouthPath.lineTo(56 * scale, 61 * scale);
        break;
    }
    canvas.drawPath(mouthPath, ink);

    final armPaint = Paint()
      ..color = TripleMatchColors.primary
      ..strokeWidth = 4 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(15 * scale, 62 * scale),
      Offset(5 * scale, 69 * scale),
      armPaint,
    );
    canvas.drawLine(
      Offset(73 * scale, 61 * scale),
      Offset(87 * scale, 51 * scale),
      armPaint,
    );

    final footPaint = Paint()
      ..color = TripleMatchColors.primaryDark
      ..strokeWidth = 4 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(29 * scale, 78 * scale),
      Offset(22 * scale, 85 * scale),
      footPaint,
    );
    canvas.drawLine(
      Offset(58 * scale, 78 * scale),
      Offset(66 * scale, 85 * scale),
      footPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PantryHelperPainter oldDelegate) {
    return oldDelegate.mood != mood;
  }
}
