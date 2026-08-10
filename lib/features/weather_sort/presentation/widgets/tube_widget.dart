import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/water_tube.dart';
import '../../domain/weather_essence.dart';
import '../theme/weather_sort_theme.dart';
import 'weather_essence_view.dart';

class TubeWidget extends StatefulWidget {
  const TubeWidget({
    super.key,
    required this.tube,
    required this.index,
    required this.isSelected,
    required this.isInvalid,
    required this.feedbackToken,
    required this.onTap,
  });

  final WaterTube tube;
  final int index;
  final bool isSelected;
  final bool isInvalid;
  final int feedbackToken;
  final VoidCallback onTap;

  @override
  State<TubeWidget> createState() => _TubeWidgetState();
}

class _TubeWidgetState extends State<TubeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void didUpdateWidget(covariant TubeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isInvalid && widget.feedbackToken != oldWidget.feedbackToken) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contents = widget.tube.layers.map((layer) => layer.label).join(', ');
    final label = widget.tube.isEmpty
        ? 'Empty vessel ${widget.index + 1}'
        : 'Vessel ${widget.index + 1}, bottom to top: $contents';

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final shake =
                math.sin(_shakeController.value * math.pi * 4) *
                7 *
                (1 - _shakeController.value);

            return Transform.translate(
              offset: Offset(shake, widget.isSelected ? -9 : 0),
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? WeatherSortColors.wash
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: WeatherSortColors.primary.withValues(
                          alpha: 0.18,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _TubeFace(tube: widget.tube)),
                const SizedBox(height: 6),
                Text(
                  '${widget.index + 1}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: WeatherSortColors.mutedInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TubeFace extends StatelessWidget {
  const _TubeFace({required this.tube});

  final WaterTube tube;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final usableHeight = constraints.maxHeight - 28;
        final layerHeight = (usableHeight / tube.capacity).clamp(18.0, 52.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _GlassTubePainter()),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (final layer in tube.layers.reversed)
                    _LayerFill(layer: layer, height: layerHeight),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LayerFill extends StatelessWidget {
  const _LayerFill({required this.layer, required this.height});

  final WeatherEssence layer;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: height,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 3),
      decoration: BoxDecoration(
        color: layer.color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.54)),
      ),
      child: Center(
        child: Icon(layer.icon, color: layer.foregroundColor, size: 20),
      ),
    );
  }
}

class _GlassTubePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(6, 8, size.width - 12, size.height - 12);
    final path = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.left, rect.bottom - 16)
      ..quadraticBezierTo(rect.left, rect.bottom, rect.left + 16, rect.bottom)
      ..lineTo(rect.right - 16, rect.bottom)
      ..quadraticBezierTo(rect.right, rect.bottom, rect.right, rect.bottom - 16)
      ..lineTo(rect.right, rect.top);

    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = WeatherSortColors.primaryDark.withValues(alpha: 0.34)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final rimPaint = Paint()
      ..color = WeatherSortColors.primary.withValues(alpha: 0.24)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, fillPaint);
    canvas.drawLine(
      Offset(rect.left - 1, rect.top),
      Offset(rect.right + 1, rect.top),
      rimPaint,
    );
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
