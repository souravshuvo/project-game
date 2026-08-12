import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/ads/app_ads_controller.dart';
import '../../../core/analytics/game_analytics.dart';
import '../../../core/audio/letter_audio_cue.dart';
import '../../../core/audio/telemetry_audio_cue.dart';
import '../../games/game_catalog.dart';
import '../../games/shared/kid_celebration.dart';
import '../../parent/presentation/parent_corner_screen.dart';
import '../../parent/presentation/parent_gate_dialog.dart';
import '../../tracing/data/progress_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.progressRepository,
    required this.audioCue,
    required this.analytics,
    required this.adsController,
    super.key,
  });

  final ProgressRepository progressRepository;
  final LetterAudioCue audioCue;
  final GameAnalytics analytics;
  final AppAdsController adsController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _playFeedback(Future<void> Function(LetterAudioCue cue) action) {
    unawaited(action(widget.audioCue).catchError((Object _) {}));
  }

  Future<void> _openGame(KidsGame game) async {
    _playFeedback((cue) => cue.playTap());
    final startedAt = DateTime.now();
    var completionRequested = false;
    final completedBefore = widget.progressRepository.completedGameIds.length;
    final wasAlreadyComplete = widget.progressRepository.isGameComplete(
      game.id,
    );
    widget.analytics.gameStarted(
      gameId: game.id,
      title: game.title,
      completedGames: completedBefore,
      totalGames: kidsGameCatalog.length,
    );

    void markCompleted() {
      if (completionRequested) {
        return;
      }
      completionRequested = true;
      final completedAfter = wasAlreadyComplete
          ? completedBefore
          : (completedBefore + 1).clamp(0, kidsGameCatalog.length);
      widget.analytics.gameCompleted(
        gameId: game.id,
        title: game.title,
        durationMs: DateTime.now().difference(startedAt).inMilliseconds,
        completedGames: completedAfter,
        totalGames: kidsGameCatalog.length,
      );
      unawaited(widget.progressRepository.markGameComplete(game.id));
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/games/${game.id}'),
        builder: (context) => game.builder(
          context,
          markCompleted,
          TelemetryLetterAudioCue(
            delegate: widget.audioCue,
            analytics: widget.analytics,
            gameId: game.id,
          ),
          widget.progressRepository,
          widget.analytics,
        ),
      ),
    );

    widget.analytics.gameExited(
      gameId: game.id,
      title: game.title,
      completed: completionRequested,
      durationMs: DateTime.now().difference(startedAt).inMilliseconds,
    );
    if (completionRequested) {
      unawaited(
        widget.adsController.recordCompletedGameBreak(
          gameId: game.id,
          gameTitle: game.title,
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openParentCorner() async {
    _playFeedback((cue) => cue.playTap());
    final unlocked = await showParentGate(context);
    widget.analytics.logEvent(
      'parent_gate_result',
      parameters: <String, Object?>{'unlocked': unlocked ? 1 : 0},
    );
    if (!unlocked || !mounted) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/parent'),
        builder: (context) => ParentCornerScreen(
          progressRepository: widget.progressRepository,
          totalGames: kidsGameCatalog.length,
          analytics: widget.analytics,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.progressRepository.completedGameIds.length;
    final total = kidsGameCatalog.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9ED),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF5D9), Color(0xFFF1ECFF)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(child: _BrandMark()),
                            const SizedBox(width: 12),
                            Semantics(
                              button: true,
                              label: 'Open parent settings',
                              child: IconButton.filledTonal(
                                key: const ValueKey('parent-corner-button'),
                                onPressed: _openParentCorner,
                                tooltip: 'Parent Corner',
                                icon: const Icon(
                                  Icons.family_restroom_rounded,
                                  size: 30,
                                ),
                                style: IconButton.styleFrom(
                                  minimumSize: const Size.square(64),
                                  foregroundColor: const Color(0xFF4A397A),
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Pick a game!',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: const Color(0xFF35275F),
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          completed == 0
                              ? 'Tap a big card to start'
                              : 'Ten little adventures for curious minds',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: const Color(0xFF686078),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 18),
                        _ProgressBanner(
                          completed: completed,
                          total: total,
                          progress: progress,
                        ),
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Games',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: const Color(0xFF35275F),
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Flexible(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: _SafetyBadge(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    mainAxisExtent: 224,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final game = kidsGameCatalog[index];
                    return _GameCard(
                      game: game,
                      completed: widget.progressRepository.isGameComplete(
                        game.id,
                      ),
                      recommended: completed == 0 && index == 0,
                      onTap: () => _openGame(game),
                    );
                  }, childCount: kidsGameCatalog.length),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                sliver: SliverToBoxAdapter(
                  child: Center(child: widget.adsController.buildHomeBanner()),
                ),
              ),
            ],
          ),
        ),
      ),
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
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7257E8), Color(0xFFEF5DA8)],
            ),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            'KidsLand',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF35275F),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({
    required this.completed,
    required this.total,
    required this.progress,
  });

  final int completed;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14634FA8),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFFFE9A8),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(11),
              child: Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFD98700),
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  completed == 0
                      ? 'Your adventure starts here'
                      : '$completed of $total games explored',
                  style: const TextStyle(
                    color: Color(0xFF40355A),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(12),
                  backgroundColor: const Color(0xFFE8E1F6),
                  color: const Color(0xFF7257E8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyBadge extends StatelessWidget {
  const _SafetyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: const BoxConstraints(maxWidth: 178, minHeight: 36),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF7EC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 18, color: Color(0xFF237A59)),
          SizedBox(width: 5),
          Flexible(
            child: Text(
              'Kid-safe play',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF237A59),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.completed,
    required this.recommended,
    required this.onTap,
  });

  final KidsGame game;
  final bool completed;
  final bool recommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: completed ? '${game.title}. Completed.' : game.title,
      hint: game.subtitle,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          key: ValueKey('game-card-${game.id}'),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: game.colors,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: game.colors.first.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      KidFloaty(
                        phase: game.id.length * 0.05,
                        amplitude: 2,
                        sway: 1.5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.24),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              game.icon,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (completed)
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(7),
                            child: Icon(
                              Icons.check_rounded,
                              color: Color(0xFF24966C),
                              size: 24,
                            ),
                          ),
                        )
                      else if (recommended)
                        const _StartBadge(),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    game.title,
                    textScaler: TextScaler.noScaling,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    game.subtitle,
                    textScaler: TextScaler.noScaling,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 14,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
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

class _StartBadge extends StatelessWidget {
  const _StartBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow_rounded, color: Color(0xFF7257E8), size: 20),
          SizedBox(width: 3),
          Text(
            'Start',
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              color: Color(0xFF4A397A),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
