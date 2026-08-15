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
    required this.isValidTarget,
    required this.isInvalid,
    required this.isRecentSource,
    required this.isRecentDestination,
    required this.feedbackToken,
    required this.moveFeedbackToken,
    required this.isPourAnimating,
    required this.pourAnimation,
    required this.pourDirection,
    required this.transferringEssence,
    required this.transferringLayerCount,
    required this.drainingLayerCount,
    required this.onTap,
  });

  final WaterTube tube;
  final int index;
  final bool isSelected;
  final bool isValidTarget;
  final bool isInvalid;
  final bool isRecentSource;
  final bool isRecentDestination;
  final int feedbackToken;
  final int moveFeedbackToken;
  final bool isPourAnimating;
  final Animation<double>? pourAnimation;
  final int pourDirection;
  final WeatherEssence? transferringEssence;
  final int transferringLayerCount;
  final int drainingLayerCount;
  final VoidCallback onTap;

  @override
  State<TubeWidget> createState() => _TubeWidgetState();
}

class _TubeWidgetState extends State<TubeWidget> with TickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
  }

  @override
  void didUpdateWidget(covariant TubeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isInvalid && widget.feedbackToken != oldWidget.feedbackToken) {
      _shakeController.forward(from: 0);
    }
    final isRecentMove = widget.isRecentSource || widget.isRecentDestination;
    if (isRecentMove &&
        widget.moveFeedbackToken != oldWidget.moveFeedbackToken) {
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pulseController.dispose();
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
      hint: widget.isValidTarget
          ? 'Valid landing for the selected vessel.'
          : widget.isSelected
          ? 'Source selected. Tap another vessel to try the pour.'
          : 'Tap to choose this vessel.',
      child: RepaintBoundary(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.isPourAnimating ? null : widget.onTap,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _shakeController,
              _pulseController,
              if (widget.pourAnimation != null) widget.pourAnimation!,
            ]),
            builder: (context, child) {
              final shake =
                  math.sin(_shakeController.value * math.pi * 4) *
                  7 *
                  (1 - _shakeController.value);
              final pulse = math.sin(_pulseController.value * math.pi);
              final pulseScale =
                  1 + pulse * (widget.isRecentDestination ? 0.055 : 0.035);
              final pourProgress = widget.pourAnimation?.value ?? 0;
              final pourPulse = math.sin(pourProgress * math.pi);
              final sourceLift = widget.isRecentSource ? -10 * pourPulse : 0.0;
              final targetLift = widget.isRecentDestination
                  ? -2 * pourPulse
                  : 0.0;
              final pourTilt = widget.isRecentSource
                  ? widget.pourDirection * 0.045 * pourPulse
                  : 0.0;

              return Transform.translate(
                offset: Offset(shake, sourceLift + targetLift),
                child: Transform.rotate(
                  angle: pourTilt,
                  alignment: Alignment.topCenter,
                  child: Transform.scale(scale: pulseScale, child: child),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _TubeFace(
                      tube: widget.tube,
                      isSelected: widget.isSelected,
                      isValidTarget: widget.isValidTarget,
                      isInvalid: widget.isInvalid,
                      isPourSource: widget.isRecentSource,
                      pourAnimation: widget.pourAnimation,
                      drainingLayerCount: widget.drainingLayerCount,
                      transferringEssence: widget.transferringEssence,
                      transferringLayerCount: widget.transferringLayerCount,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.index + 1}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: widget.isSelected
                          ? WeatherSortColors.primary
                          : widget.isValidTarget
                          ? WeatherSortColors.mint
                          : WeatherSortColors.mutedInk,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TubeFace extends StatelessWidget {
  const _TubeFace({
    required this.tube,
    required this.isSelected,
    required this.isValidTarget,
    required this.isInvalid,
    required this.isPourSource,
    required this.pourAnimation,
    required this.drainingLayerCount,
    required this.transferringEssence,
    required this.transferringLayerCount,
  });

  final WaterTube tube;
  final bool isSelected;
  final bool isValidTarget;
  final bool isInvalid;
  final bool isPourSource;
  final Animation<double>? pourAnimation;
  final int drainingLayerCount;
  final WeatherEssence? transferringEssence;
  final int transferringLayerCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const verticalPadding = 30.0;
        const layerGap = 3.0;
        final usableHeight =
            constraints.maxHeight -
            verticalPadding -
            (tube.capacity * layerGap);
        final layerHeight = (usableHeight / tube.capacity).clamp(18.0, 52.0);

        Widget contents(double pourProgress) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _GlassTubePainter(
                  isSelected: isSelected,
                  isValidTarget: isValidTarget,
                  isInvalid: isInvalid,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (transferringEssence != null)
                      for (
                        var index = 0;
                        index < transferringLayerCount;
                        index++
                      )
                        _LayerFill(
                          layer: transferringEssence!,
                          height: layerHeight,
                          fillProgress: pourProgress,
                        ),
                    for (var index = 0; index < tube.layers.length; index++)
                      _LayerFill(
                        layer: tube.layers.reversed.elementAt(index),
                        height: layerHeight,
                        drainProgress:
                            isPourSource && index < drainingLayerCount
                            ? pourProgress
                            : 0,
                      ),
                  ],
                ),
              ),
            ],
          );
        }

        final animation = pourAnimation;
        if (animation == null) {
          return contents(0);
        }
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) => contents(animation.value),
        );
      },
    );
  }
}

class _LayerFill extends StatelessWidget {
  const _LayerFill({
    required this.layer,
    required this.height,
    this.fillProgress = 1,
    this.drainProgress = 0,
  });

  final WeatherEssence layer;
  final double height;
  final double fillProgress;
  final double drainProgress;

  @override
  Widget build(BuildContext context) {
    final resolvedFill = Curves.easeOutCubic.transform(fillProgress);
    final resolvedDrain = Curves.easeInCubic.transform(drainProgress);
    final renderedHeight = height * resolvedFill * (1 - resolvedDrain);
    if (renderedHeight <= 0.5) {
      return const SizedBox.shrink();
    }

    return Container(
      height: renderedHeight,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 1),
      child: CustomPaint(painter: _LiquidLayerPainter(color: layer.color)),
    );
  }
}

class _LiquidLayerPainter extends CustomPainter {
  const _LiquidLayerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final wave = math.min(3.0, size.height / 4);
    final surface = wave + 0.5;
    final liquid = Path()
      ..moveTo(0, surface)
      ..quadraticBezierTo(
        size.width * 0.25,
        surface - wave,
        size.width * 0.5,
        surface,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        surface + wave,
        size.width,
        surface,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(liquid, Paint()..color = color);

    final surfacePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.46)
      ..strokeWidth = math.min(2.0, size.height / 5)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final surfacePath = Path()
      ..moveTo(0, surface)
      ..quadraticBezierTo(
        size.width * 0.25,
        surface - wave,
        size.width * 0.5,
        surface,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        surface + wave,
        size.width,
        surface,
      );
    canvas.drawPath(surfacePath, surfacePaint);
  }

  @override
  bool shouldRepaint(covariant _LiquidLayerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _GlassTubePainter extends CustomPainter {
  const _GlassTubePainter({
    required this.isSelected,
    required this.isValidTarget,
    required this.isInvalid,
  });

  final bool isSelected;
  final bool isValidTarget;
  final bool isInvalid;

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

    final highlightColor = isInvalid
        ? WeatherSortColors.coral
        : isSelected
        ? WeatherSortColors.primary
        : isValidTarget
        ? WeatherSortColors.mint
        : WeatherSortColors.primary;
    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..style = PaintingStyle.fill;
    final targetWashPaint = Paint()
      ..color = highlightColor.withValues(
        alpha: isSelected || isValidTarget || isInvalid ? 0.1 : 0,
      )
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = WeatherSortColors.primaryDark.withValues(alpha: 0.34)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final rimPaint = Paint()
      ..color = highlightColor.withValues(
        alpha: isSelected || isValidTarget || isInvalid ? 0.88 : 0.24,
      )
      ..strokeWidth = isSelected || isValidTarget || isInvalid ? 5 : 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, targetWashPaint);
    canvas.drawLine(
      Offset(rect.left - 1, rect.top),
      Offset(rect.right + 1, rect.top),
      rimPaint,
    );
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _GlassTubePainter oldDelegate) {
    return oldDelegate.isSelected != isSelected ||
        oldDelegate.isValidTarget != isValidTarget ||
        oldDelegate.isInvalid != isInvalid;
  }
}
