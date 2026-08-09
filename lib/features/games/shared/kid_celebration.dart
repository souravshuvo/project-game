import 'dart:math' as math;

import 'package:flutter/material.dart';

const List<Color> kidConfettiColors = <Color>[
  Color(0xFF7257E8),
  Color(0xFFEF5DA8),
  Color(0xFFFFA928),
  Color(0xFF2DBE88),
  Color(0xFF35A7FF),
  Color(0xFFFF7B54),
];

class KidFloaty extends StatefulWidget {
  const KidFloaty({
    required this.child,
    this.amplitude = 5,
    this.sway = 3,
    this.phase = 0,
    this.duration = const Duration(milliseconds: 1700),
    super.key,
  });

  final Widget child;
  final double amplitude;
  final double sway;
  final double phase;
  final Duration duration;

  @override
  State<KidFloaty> createState() => _KidFloatyState();
}

class _KidFloatyState extends State<KidFloaty>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant KidFloaty oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller
        ..duration = widget.duration
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final wave = (_controller.value + widget.phase) * math.pi * 2;
        return Transform.translate(
          offset: Offset(
            math.sin(wave) * widget.sway,
            math.cos(wave) * widget.amplitude,
          ),
          child: Transform.rotate(angle: math.sin(wave) * 0.035, child: child),
        );
      },
    );
  }
}

class KidConfettiOverlay extends StatefulWidget {
  const KidConfettiOverlay({
    required this.active,
    required this.child,
    this.colors = kidConfettiColors,
    this.density = 34,
    this.duration = const Duration(milliseconds: 1900),
    super.key,
  });

  final bool active;
  final Widget child;
  final List<Color> colors;
  final int density;
  final Duration duration;

  @override
  State<KidConfettiOverlay> createState() => _KidConfettiOverlayState();
}

class _KidConfettiOverlayState extends State<KidConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _syncController();
  }

  @override
  void didUpdateWidget(covariant KidConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    _syncController();
  }

  void _syncController() {
    if (widget.active) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (widget.active)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _KidConfettiPainter(
                  progress: _controller,
                  colors: widget.colors,
                  density: widget.density,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class KidPopBurst extends StatefulWidget {
  const KidPopBurst({
    required this.color,
    required this.child,
    this.duration = const Duration(milliseconds: 520),
    super.key,
  });

  final Color color;
  final Widget child;
  final Duration duration;

  @override
  State<KidPopBurst> createState() => _KidPopBurstState();
}

class _KidPopBurstState extends State<KidPopBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void didUpdateWidget(covariant KidPopBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _KidPopBurstPainter(
              progress: CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOutCubic,
              ),
              color: widget.color,
            ),
          ),
        ),
        ScaleTransition(
          scale: Tween<double>(begin: 0.78, end: 1.08).animate(
            CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
          ),
          child: widget.child,
        ),
      ],
    );
  }
}

class _KidConfettiPainter extends CustomPainter {
  _KidConfettiPainter({
    required this.progress,
    required this.colors,
    required this.density,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final List<Color> colors;
  final int density;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || colors.isEmpty || density <= 0) {
      return;
    }

    final paint = Paint()..style = PaintingStyle.fill;
    for (var index = 0; index < density; index++) {
      final lane = ((index * 47) % 100) / 100;
      final drift = math.sin((progress.value * math.pi * 2) + index) * 16;
      final localProgress = (progress.value + (index * 0.071)) % 1;
      final x = (lane * size.width) + drift;
      final y = (localProgress * (size.height + 46)) - 24;
      final side = 5.0 + ((index % 4) * 1.6);
      final alpha = (1 - (localProgress * 0.58)).clamp(0.22, 1.0);

      paint.color = colors[index % colors.length].withValues(alpha: alpha);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((progress.value * math.pi * 2) + index);
      if (index.isEven) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: side * 1.55,
              height: side,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, side * 0.62, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _KidConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.colors != colors ||
        oldDelegate.density != density;
  }
}

class _KidPopBurstPainter extends CustomPainter {
  _KidPopBurstPainter({required this.progress, required this.color})
    : super(repaint: progress);

  final Animation<double> progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.42 * progress.value;
    final alpha = (1 - progress.value).clamp(0.0, 1.0);
    final dotPaint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    final rayPaint = Paint()
      ..color = color.withValues(alpha: alpha * 0.75)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    for (var index = 0; index < 12; index++) {
      final angle = (index / 12) * math.pi * 2;
      final direction = Offset(math.cos(angle), math.sin(angle));
      final start = center + (direction * (radius * 0.28));
      final end = center + (direction * (radius + 8));
      canvas.drawLine(start, end, rayPaint);

      final dotCenter = center + (direction * (radius + 18));
      canvas.drawCircle(dotCenter, 3 + ((index % 3) * 1.2), dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _KidPopBurstPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
