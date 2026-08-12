import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../games/dew_bubble/data/dew_levels.dart';
import '../../games/game_catalog.dart';
import '../../games/shared/kid_celebration.dart';
import '../../parent/presentation/parent_corner_screen.dart';
import '../../parent/presentation/parent_gate_dialog.dart';
import '../../tracing/data/progress_repository.dart';
import '../../../shared/ads/game_ad_service.dart';
import '../../../shared/analytics/game_analytics.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.progressRepository,
    this.analytics = const NoopGameAnalytics(),
    this.adService = const NoopGameAdService(),
    super.key,
  });

  final ProgressRepository progressRepository;
  final GameAnalytics analytics;
  final GameAdService adService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  KidsGame get _game => kidsGameCatalog.single;

  @override
  void initState() {
    super.initState();
    unawaited(
      widget.analytics.logEvent(GameAnalyticsEvents.homeViewed, {
        'game_id': _game.id,
        'total_levels': dewBubbleLevels.length,
      }),
    );
  }

  Future<void> _openGame() async {
    final game = _game;
    var completionRequested = false;
    unawaited(
      widget.analytics.logEvent(GameAnalyticsEvents.gameOpened, {
        'game_id': game.id,
        'source': 'home_card',
      }),
    );

    void markCompleted() {
      if (completionRequested) {
        return;
      }
      completionRequested = true;
      unawaited(widget.progressRepository.markGameComplete(game.id));
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/games/${game.id}'),
        builder: (context) => game.builder(
          context,
          markCompleted,
          widget.progressRepository,
          widget.analytics,
          widget.adService,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openParentCorner() async {
    final unlocked = await showParentGate(context);
    if (!unlocked || !mounted) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/parent'),
        builder: (context) => ParentCornerScreen(
          progressRepository: widget.progressRepository,
          gameIds: [for (final game in kidsGameCatalog) game.id],
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    final totalLevels = dewBubbleLevels.length;
    final highestUnlocked = widget
        .progressRepository
        .dewBubbleHighestUnlockedLevelIndex
        .clamp(0, math.max(0, totalLevels - 1))
        .toInt();
    final unlockedLevels = totalLevels == 0 ? 0 : highestUnlocked + 1;
    final savedStars = dewBubbleLevels.fold<int>(
      0,
      (total, level) =>
          total + widget.progressRepository.dewBubbleBestStars(level.id),
    );
    final bestScore = dewBubbleLevels.fold<int>(
      0,
      (best, level) => math.max(
        best,
        widget.progressRepository.dewBubbleBestScore(level.id),
      ),
    );
    final completed = widget.progressRepository.isGameComplete(game.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6FAF5), Color(0xFFFFF8E8), Color(0xFFF8F0FF)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HomeHeader(onParentCorner: _openParentCorner),
                          const SizedBox(height: 20),
                          _BubbleGardenPreview(completed: completed),
                          const SizedBox(height: 18),
                          Text(
                            game.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: const Color(0xFF243C4A),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            game.subtitle,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: const Color(0xFF5F6F74),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0,
                                ),
                          ),
                          const SizedBox(height: 22),
                          _PlayButton(
                            completed: completed,
                            onPressed: _openGame,
                          ),
                          const SizedBox(height: 18),
                          _ProgressSummary(
                            unlockedLevels: unlockedLevels,
                            totalLevels: totalLevels,
                            savedStars: savedStars,
                            maxStars: totalLevels * 3,
                            bestScore: bestScore,
                          ),
                          const SizedBox(height: 14),
                          const _OfflineNote(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onParentCorner});

  final VoidCallback onParentCorner;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _BrandMark()),
        const SizedBox(width: 12),
        Semantics(
          button: true,
          label: 'Open parent settings',
          child: IconButton.filledTonal(
            key: const ValueKey('parent-corner-button'),
            onPressed: onParentCorner,
            tooltip: 'Parent Corner',
            icon: const Icon(Icons.family_restroom_rounded, size: 28),
            style: IconButton.styleFrom(
              minimumSize: const Size.square(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              foregroundColor: const Color(0xFF2E6E65),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF2CB9A0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.bubble_chart_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            'Dew Bubble',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF243C4A),
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _BubbleGardenPreview extends StatelessWidget {
  const _BubbleGardenPreview({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Dew Bubble Garden preview',
      image: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = math.min(
            260.0,
            math.max(168.0, constraints.maxWidth * 0.38),
          );

          return SizedBox(
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x183F8FEF),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const CustomPaint(painter: _BubbleGardenPreviewPainter()),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: KidFloaty(
                        amplitude: 3,
                        sway: 2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: completed
                                ? const Color(0xFFFFF0B8)
                                : const Color(0xFFE7FAFF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  completed
                                      ? Icons.check_rounded
                                      : Icons.spa_rounded,
                                  key: completed
                                      ? const ValueKey(
                                          'dew-bubble-complete-check',
                                        )
                                      : null,
                                  color: completed
                                      ? const Color(0xFFD98700)
                                      : const Color(0xFF2CB9A0),
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  completed ? 'Cleared' : 'Ready',
                                  style: const TextStyle(
                                    color: Color(0xFF34415F),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.completed, required this.onPressed});

  final bool completed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      key: const ValueKey('game-card-dew-bubble'),
      onPressed: onPressed,
      icon: const Icon(Icons.play_arrow_rounded, size: 32),
      label: Text(completed ? 'Play Again' : 'Play'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        backgroundColor: const Color(0xFF2CB9A0),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({
    required this.unlockedLevels,
    required this.totalLevels,
    required this.savedStars,
    required this.maxStars,
    required this.bestScore,
  });

  final int unlockedLevels;
  final int totalLevels;
  final int savedStars;
  final int maxStars;
  final int bestScore;

  @override
  Widget build(BuildContext context) {
    final progress = totalLevels == 0 ? 0.0 : unlockedLevels / totalLevels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.lock_open_rounded,
                label: 'Open',
                value: '$unlockedLevels/$totalLevels',
                color: const Color(0xFF3F8FEF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.star_rounded,
                label: 'Stars',
                value: '$savedStars/$maxStars',
                color: const Color(0xFFFFA928),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.emoji_events_rounded,
                label: 'Best',
                value: '$bestScore',
                color: const Color(0xFF7257E8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.white.withValues(alpha: 0.75),
            color: const Color(0xFF2CB9A0),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF243C4A),
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF68758B),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineNote extends StatelessWidget {
  const _OfflineNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.offline_bolt_rounded, size: 18, color: Color(0xFF237A59)),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            'Offline / Ad-free',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF237A59),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _BubbleGardenPreviewPainter extends CustomPainter {
  const _BubbleGardenPreviewPainter();

  static const _bubbles = <_PreviewBubble>[
    _PreviewBubble(0.18, 0.24, 0.12, Color(0xFF67B8F7)),
    _PreviewBubble(0.31, 0.23, 0.12, Color(0xFFEF5DA8)),
    _PreviewBubble(0.44, 0.24, 0.12, Color(0xFFFFD15C)),
    _PreviewBubble(0.57, 0.23, 0.12, Color(0xFF2DBE88)),
    _PreviewBubble(0.25, 0.39, 0.12, Color(0xFF67B8F7)),
    _PreviewBubble(0.38, 0.39, 0.12, Color(0xFFEF5DA8)),
    _PreviewBubble(0.51, 0.39, 0.12, Color(0xFFFFD15C)),
    _PreviewBubble(0.64, 0.39, 0.12, Color(0xFF2DBE88)),
    _PreviewBubble(0.70, 0.63, 0.1, Color(0xFFEF5DA8)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE9FBFF), Color(0xFFFFFAEA)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    final groundPaint = Paint()..color = const Color(0xFFE0F6D8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.66, size.width, size.height * 0.34),
        const Radius.circular(28),
      ),
      groundPaint,
    );

    final stemPaint = Paint()
      ..color = const Color(0xFF52A869)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(2, size.shortestSide * 0.018);
    canvas.drawLine(
      Offset(size.width * 0.72, size.height * 0.73),
      Offset(size.width * 0.72, size.height * 0.58),
      stemPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.78, size.height * 0.74),
      Offset(size.width * 0.78, size.height * 0.62),
      stemPaint,
    );

    for (final bubble in _bubbles) {
      final center = Offset(bubble.x * size.width, bubble.y * size.height);
      final radius = bubble.radius * size.shortestSide;
      final shadowPaint = Paint()
        ..color = const Color(0x2234415F)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(
        center.translate(0, radius * 0.16),
        radius,
        shadowPaint,
      );

      final fillPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.45, -0.45),
          radius: 0.9,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            bubble.color.withValues(alpha: 0.92),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, fillPaint);

      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.4, radius * 0.08)
        ..color = Colors.white.withValues(alpha: 0.7);
      canvas.drawCircle(center, radius * 0.9, ringPaint);
    }

    final shooterCenter = Offset(size.width * 0.5, size.height * 0.83);
    final shooterPaint = Paint()..color = const Color(0xFF34415F);
    final barrelPaint = Paint()
      ..color = const Color(0xFF34415F)
      ..strokeWidth = math.max(8, size.shortestSide * 0.04)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      shooterCenter,
      shooterCenter.translate(size.width * 0.12, -size.height * 0.18),
      barrelPaint,
    );
    canvas.drawCircle(shooterCenter, size.shortestSide * 0.075, shooterPaint);
    canvas.drawCircle(
      shooterCenter,
      size.shortestSide * 0.046,
      Paint()..color = const Color(0xFFFFD15C),
    );
  }

  @override
  bool shouldRepaint(covariant _BubbleGardenPreviewPainter oldDelegate) {
    return false;
  }
}

class _PreviewBubble {
  const _PreviewBubble(this.x, this.y, this.radius, this.color);

  final double x;
  final double y;
  final double radius;
  final Color color;
}
