import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/farm_plot.dart';
import '../../domain/farm_rules.dart';
import '../../domain/farm_state.dart';

class FarmGrid extends StatelessWidget {
  const FarmGrid({
    super.key,
    required this.state,
    required this.rules,
    required this.selectedPlot,
    required this.nowMs,
    required this.onSelect,
    required this.onLockedSelect,
  });

  final FarmState state;
  final FarmRules rules;
  final int selectedPlot;
  final int nowMs;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onLockedSelect;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9CC9D7), Color(0xFFF0D9AA), Color(0xFF8D985D)],
            stops: [0, 0.38, 1],
          ),
          border: Border.all(color: const Color(0xFF8C6B43), width: 1.4),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, 10),
              color: Color(0x22000000),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: _FieldPainter()),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 32, 14, 14),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rules.plotCount,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 9,
                    crossAxisSpacing: 9,
                  ),
                  itemBuilder: (context, index) {
                    final unlocked = rules.isPlotUnlocked(state, index);
                    return _PlotTile(
                      state: state,
                      rules: rules,
                      index: index,
                      nowMs: nowMs,
                      unlocked: unlocked,
                      selected: selectedPlot == index,
                      onTap: unlocked
                          ? () => onSelect(index)
                          : () => onLockedSelect(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldPainter extends CustomPainter {
  const _FieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final wallPaint = Paint()..color = const Color(0xFFE4C997);
    final wallRect = Rect.fromLTWH(0, size.height * 0.18, size.width, 28);
    canvas.drawRect(wallRect, wallPaint);

    final capPaint = Paint()..color = const Color(0xFF7F6546);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.18 + 24, size.width, 5),
      capPaint,
    );

    final railPaint = Paint()
      ..color = const Color(0xAA5D472E)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 7; i++) {
      final x = size.width * (0.08 + i * 0.14);
      canvas.drawLine(
        Offset(x, size.height * 0.06),
        Offset(x, size.height * 0.22),
        railPaint,
      );
    }
    canvas.drawLine(
      Offset(size.width * 0.04, size.height * 0.1),
      Offset(size.width * 0.96, size.height * 0.1),
      railPaint,
    );

    final pathPaint = Paint()..color = const Color(0x33FFFFFF);
    final path = Path()
      ..moveTo(size.width * 0.06, size.height * 0.94)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.75,
        size.width * 0.94,
        size.height * 0.94,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlotTile extends StatelessWidget {
  const _PlotTile({
    required this.state,
    required this.rules,
    required this.index,
    required this.nowMs,
    required this.unlocked,
    required this.selected,
    required this.onTap,
  });

  final FarmState state;
  final FarmRules rules;
  final int index;
  final int nowMs;
  final bool unlocked;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final visual = _PlotVisuals.from(state, rules, index, nowMs);
    final borderRadius = BorderRadius.circular(8);

    return Semantics(
      button: true,
      selected: selected,
      label: 'Plot ${index + 1}, ${visual.label}',
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        scale: selected ? 1.025 : 1,
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(
                  color: selected
                      ? const Color(0xFFFFF3A7)
                      : visual.borderColor,
                  width: selected ? 3 : 1.2,
                ),
                boxShadow: selected
                    ? const [
                        BoxShadow(
                          blurRadius: 16,
                          offset: Offset(0, 6),
                          color: Color(0x33000000),
                        ),
                      ]
                    : const [
                        BoxShadow(
                          blurRadius: 6,
                          offset: Offset(0, 3),
                          color: Color(0x1F000000),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _PlotSurfacePainter(visual)),
                    ),
                    if (visual.status == PlotStatus.empty)
                      Center(
                        child: Icon(
                          Icons.add_circle_outline,
                          color: const Color(0xFF725032).withAlpha(145),
                          size: 30,
                        ),
                      ),
                    if (visual.status == PlotStatus.locked)
                      Center(
                        child: Icon(
                          Icons.lock_outline,
                          color: const Color(0xFF514638).withAlpha(190),
                          size: 30,
                        ),
                      ),
                    if (visual.status == PlotStatus.growing)
                      Positioned(
                        left: 8,
                        right: 8,
                        bottom: 33,
                        child: _GrowthBar(value: visual.progress),
                      ),
                    if (selected)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3A7),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: const Color(0xFFE4C86D)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(3),
                            child: Icon(
                              Icons.check,
                              color: Color(0xFF384B29),
                              size: 13,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 6,
                      right: 6,
                      bottom: 6,
                      child: _PlotLabel(visual: visual, plotNumber: index + 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlotVisuals {
  const _PlotVisuals({
    required this.status,
    required this.cropId,
    required this.soilTop,
    required this.soilBottom,
    required this.borderColor,
    required this.textColor,
    required this.labelBackground,
    required this.label,
    required this.detail,
    required this.progress,
    required this.growth,
    required this.moisture,
  });

  final PlotStatus status;
  final String? cropId;
  final Color soilTop;
  final Color soilBottom;
  final Color borderColor;
  final Color textColor;
  final Color labelBackground;
  final String label;
  final String detail;
  final double progress;
  final double growth;
  final double moisture;

  factory _PlotVisuals.from(
    FarmState state,
    FarmRules rules,
    int index,
    int nowMs,
  ) {
    final status = rules.plotStatus(state, index, nowMs);
    final plot = state.plots[index];
    final cropName = plot.cropId == null
        ? null
        : rules.cropById(plot.cropId!).name;
    final progress = _growthProgress(plot, rules, nowMs);

    return switch (status) {
      PlotStatus.locked => _PlotVisuals(
        status: status,
        cropId: plot.cropId,
        soilTop: const Color(0xFFB7AD9E),
        soilBottom: const Color(0xFF857965),
        borderColor: const Color(0xFF6E6253),
        textColor: const Color(0xFFF2ECE2),
        labelBackground: const Color(0xD94B4136),
        label: 'Locked',
        detail: 'Upgrade',
        progress: 0,
        growth: 0,
        moisture: 0,
      ),
      PlotStatus.empty => _PlotVisuals(
        status: status,
        cropId: plot.cropId,
        soilTop: const Color(0xFFC6905B),
        soilBottom: const Color(0xFF7E5434),
        borderColor: const Color(0xFF694426),
        textColor: const Color(0xFFFFF4E5),
        labelBackground: const Color(0xD95A3720),
        label: 'Empty',
        detail: 'Plot ${index + 1}',
        progress: 0,
        growth: 0,
        moisture: 0,
      ),
      PlotStatus.plantedDry => _PlotVisuals(
        status: status,
        cropId: plot.cropId,
        soilTop: const Color(0xFFB87943),
        soilBottom: const Color(0xFF684126),
        borderColor: const Color(0xFF5D351E),
        textColor: const Color(0xFFFFF4E5),
        labelBackground: const Color(0xD94D2D1B),
        label: cropName ?? 'Dry',
        detail: 'Needs water',
        progress: 0,
        growth: 0.3,
        moisture: 0,
      ),
      PlotStatus.growing => _PlotVisuals(
        status: status,
        cropId: plot.cropId,
        soilTop: const Color(0xFF6D4A31),
        soilBottom: const Color(0xFF3D2B20),
        borderColor: const Color(0xFF4A3324),
        textColor: const Color(0xFFEAF7E6),
        labelBackground: const Color(0xD9293F2C),
        label: '${rules.remainingGrowth(plot, nowMs).inSeconds + 1}s',
        detail: cropName ?? 'Growing',
        progress: progress,
        growth: 0.35 + progress * 0.42,
        moisture: 0.8,
      ),
      PlotStatus.ready => _PlotVisuals(
        status: status,
        cropId: plot.cropId,
        soilTop: const Color(0xFF5D432E),
        soilBottom: const Color(0xFF312418),
        borderColor: const Color(0xFF7E9A3E),
        textColor: const Color(0xFFF6FFE8),
        labelBackground: const Color(0xE9375728),
        label: 'Ready',
        detail: cropName ?? 'Harvest',
        progress: 1,
        growth: 1,
        moisture: 0.55,
      ),
    };
  }

  static double _growthProgress(FarmPlot plot, FarmRules rules, int nowMs) {
    if (plot.cropId == null || plot.wateredAtMs == null) {
      return 0;
    }

    final crop = rules.cropById(plot.cropId!);
    final totalMs = crop.growDuration.inMilliseconds;
    if (totalMs <= 0) {
      return 1;
    }

    final remainingMs = rules.remainingGrowth(plot, nowMs).inMilliseconds;
    return math.max(0, math.min(1, (totalMs - remainingMs) / totalMs));
  }
}

class _PlotSurfacePainter extends CustomPainter {
  const _PlotSurfacePainter(this.visual);

  final _PlotVisuals visual;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = Radius.circular(math.max(6, size.shortestSide * 0.08));
    final rrect = RRect.fromRectAndRadius(rect, radius);

    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [visual.soilTop, visual.soilBottom],
      ).createShader(rect);
    canvas.drawRRect(rrect, basePaint);

    if (visual.status == PlotStatus.locked) {
      _drawHatchedCover(canvas, size);
      return;
    }

    _drawSoilRows(canvas, size);
    _drawPebbles(canvas, size);

    if (visual.moisture > 0) {
      _drawMoisture(canvas, size, visual.moisture);
    }

    if (visual.growth > 0) {
      _drawCrop(canvas, size);
    }

    if (visual.status == PlotStatus.ready) {
      _drawReadyGlow(canvas, size);
    }
  }

  void _drawHatchedCover(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x33554738)
      ..strokeWidth = math.max(2, size.shortestSide * 0.025);
    for (var x = -size.width; x < size.width * 1.6; x += size.width * 0.18) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.width, 0), paint);
    }
  }

  void _drawSoilRows(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = const Color(0x33000000)
      ..strokeWidth = math.max(2.5, size.shortestSide * 0.028)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final highlightPaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..strokeWidth = math.max(1.2, size.shortestSide * 0.012)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 5; i++) {
      final y = size.height * (0.18 + i * 0.13);
      final path = Path()
        ..moveTo(size.width * 0.1, y)
        ..quadraticBezierTo(
          size.width * 0.5,
          y - size.height * 0.045,
          size.width * 0.9,
          y,
        );
      canvas.drawPath(path, shadowPaint);
      canvas.drawPath(
        path.shift(Offset(0, -size.height * 0.018)),
        highlightPaint,
      );
    }
  }

  void _drawPebbles(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x33835F3B);
    const points = [
      Offset(0.18, 0.28),
      Offset(0.76, 0.24),
      Offset(0.33, 0.55),
      Offset(0.82, 0.68),
      Offset(0.2, 0.76),
    ];
    for (final point in points) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(point.dx * size.width, point.dy * size.height),
          width: size.width * 0.045,
          height: size.height * 0.025,
        ),
        paint,
      );
    }
  }

  void _drawMoisture(Canvas canvas, Size size, double moisture) {
    final paint = Paint()
      ..color = Color.lerp(
        const Color(0x002B6B83),
        const Color(0x662B6B83),
        moisture,
      )!;
    for (var i = 0; i < 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            size.width * (0.26 + i * 0.23),
            size.height * (0.62 + (i.isEven ? 0.04 : -0.02)),
          ),
          width: size.width * (0.22 + i * 0.02),
          height: size.height * 0.08,
        ),
        paint,
      );
    }
  }

  void _drawCrop(Canvas canvas, Size size) {
    final palette = _CropPalette.forCrop(visual.cropId);
    final stemPaint = Paint()
      ..color = palette.stem
      ..strokeWidth = math.max(2.4, size.shortestSide * 0.034)
      ..strokeCap = StrokeCap.round;
    final leafPaint = Paint()..color = palette.leaf;
    final accentPaint = Paint()..color = palette.accent;
    final shadowPaint = Paint()..color = const Color(0x33000000);

    final growth = visual.growth;
    final cropCount = visual.status == PlotStatus.plantedDry ? 2 : 3;
    for (var i = 0; i < cropCount; i++) {
      final x = size.width * (0.27 + i * 0.23);
      final base = Offset(x, size.height * (0.74 - (i.isOdd ? 0.02 : 0)));
      final plantHeight = size.height * (0.22 + 0.33 * growth);
      final top = Offset(base.dx, base.dy - plantHeight);
      final scale = 0.86 + i * 0.08;

      canvas.drawOval(
        Rect.fromCenter(
          center: base.translate(0, size.height * 0.025),
          width: size.width * 0.22,
          height: size.height * 0.055,
        ),
        shadowPaint,
      );
      canvas.drawLine(base, top, stemPaint);

      final leafWidth = size.width * (0.11 + growth * 0.04) * scale;
      final leafHeight = size.height * (0.06 + growth * 0.025) * scale;
      _drawLeaf(
        canvas,
        top.translate(-leafWidth * 0.28, plantHeight * 0.38),
        leafWidth,
        leafHeight,
        -0.55,
        leafPaint,
      );
      _drawLeaf(
        canvas,
        top.translate(leafWidth * 0.3, plantHeight * 0.48),
        leafWidth,
        leafHeight,
        0.55,
        leafPaint,
      );

      if (growth > 0.62) {
        _drawLeaf(
          canvas,
          top.translate(-leafWidth * 0.18, plantHeight * 0.14),
          leafWidth * 0.8,
          leafHeight * 0.85,
          -0.35,
          leafPaint,
        );
      }

      if (growth > 0.82) {
        _drawCropAccent(canvas, top, size, palette, accentPaint);
      }
    }
  }

  void _drawLeaf(
    Canvas canvas,
    Offset center,
    double width,
    double height,
    double rotation,
    Paint paint,
  ) {
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(rotation)
      ..drawOval(
        Rect.fromCenter(center: Offset.zero, width: width, height: height),
        paint,
      )
      ..restore();
  }

  void _drawCropAccent(
    Canvas canvas,
    Offset top,
    Size size,
    _CropPalette palette,
    Paint accentPaint,
  ) {
    switch (visual.cropId) {
      case FarmRules.rainBeansId:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: top.translate(size.width * 0.025, size.height * 0.04),
              width: size.width * 0.055,
              height: size.height * 0.16,
            ),
            Radius.circular(size.width * 0.03),
          ),
          accentPaint,
        );
      case FarmRules.amberLeafId:
        _drawLeaf(
          canvas,
          top.translate(0, size.height * 0.025),
          size.width * 0.15,
          size.height * 0.09,
          0.1,
          accentPaint,
        );
      default:
        for (var i = 0; i < 6; i++) {
          final angle = i * math.pi / 3;
          canvas.drawCircle(
            top.translate(
              math.cos(angle) * size.width * 0.035,
              math.sin(angle) * size.width * 0.035,
            ),
            size.width * 0.025,
            accentPaint,
          );
        }
        canvas.drawCircle(
          top,
          size.width * 0.025,
          Paint()..color = palette.seed,
        );
    }
  }

  void _drawReadyGlow(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x22FFF2A7);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.5),
        width: size.width * 0.86,
        height: size.height * 0.58,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PlotSurfacePainter oldDelegate) {
    return oldDelegate.visual.status != visual.status ||
        oldDelegate.visual.cropId != visual.cropId ||
        oldDelegate.visual.progress != visual.progress ||
        oldDelegate.visual.growth != visual.growth ||
        oldDelegate.visual.moisture != visual.moisture;
  }
}

class _GrowthBar extends StatelessWidget {
  const _GrowthBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        minHeight: 5,
        value: value,
        backgroundColor: const Color(0x66252C22),
        valueColor: const AlwaysStoppedAnimation(Color(0xFF9AD66F)),
      ),
    );
  }
}

class _PlotLabel extends StatelessWidget {
  const _PlotLabel({required this.visual, required this.plotNumber});

  final _PlotVisuals visual;
  final int plotNumber;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: visual.labelBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0x26FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        child: Row(
          children: [
            Text(
              '$plotNumber',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: visual.textColor.withAlpha(205),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    visual.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: visual.textColor,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  Text(
                    visual.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: visual.textColor.withAlpha(205),
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropPalette {
  const _CropPalette({
    required this.stem,
    required this.leaf,
    required this.accent,
    required this.seed,
  });

  final Color stem;
  final Color leaf;
  final Color accent;
  final Color seed;

  factory _CropPalette.forCrop(String? cropId) {
    return switch (cropId) {
      FarmRules.rainBeansId => const _CropPalette(
        stem: Color(0xFF489A6A),
        leaf: Color(0xFF2D7C65),
        accent: Color(0xFF62A98F),
        seed: Color(0xFFBFE2D3),
      ),
      FarmRules.amberLeafId => const _CropPalette(
        stem: Color(0xFF7F8C36),
        leaf: Color(0xFF748C32),
        accent: Color(0xFFD9923B),
        seed: Color(0xFF5E421F),
      ),
      _ => const _CropPalette(
        stem: Color(0xFF4D8A35),
        leaf: Color(0xFF3F8F3D),
        accent: Color(0xFFF6C958),
        seed: Color(0xFF7C561F),
      ),
    };
  }
}
