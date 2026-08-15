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
    var completedAfter = widget.progressRepository.completedGameIds.length;
    final completedBefore = widget.progressRepository.completedGameIds.length;
    final nextGame = _nextGameAfter(
      game,
      widget.progressRepository.completedGameIds,
    );
    final wasAlreadyComplete = widget.progressRepository.isGameComplete(
      game.id,
    );
    final gameIndex = kidsGameCatalog.indexWhere(
      (entry) => entry.id == game.id,
    );
    widget.analytics.gameStarted(
      gameId: game.id,
      title: game.title,
      completedGames: completedBefore,
      totalGames: kidsGameCatalog.length,
      category: game.category,
      difficultyTier: game.difficultyTier,
      contentTotal: game.contentTotal,
      gameIndex: gameIndex < 0 ? null : gameIndex + 1,
      replay: wasAlreadyComplete,
    );

    void markCompleted() {
      if (completionRequested) {
        return;
      }
      completionRequested = true;
      completedAfter = wasAlreadyComplete
          ? completedBefore
          : (completedBefore + 1).clamp(0, kidsGameCatalog.length);
      widget.analytics.gameCompleted(
        gameId: game.id,
        title: game.title,
        durationMs: DateTime.now().difference(startedAt).inMilliseconds,
        completedGames: completedAfter,
        totalGames: kidsGameCatalog.length,
        category: game.category,
        difficultyTier: game.difficultyTier,
        contentTotal: game.contentTotal,
        gameIndex: gameIndex < 0 ? null : gameIndex + 1,
        replay: wasAlreadyComplete,
        progressPercent: kidsGameCatalog.isEmpty
            ? 0
            : ((completedAfter / kidsGameCatalog.length) * 100).round(),
      );
      unawaited(widget.progressRepository.markGameComplete(game.id));
    }

    final routeResult = await Navigator.of(context).push<_GameRouteAction>(
      MaterialPageRoute<_GameRouteAction>(
        settings: RouteSettings(name: '/games/${game.id}'),
        builder: (context) => game.builder(
          context,
          markCompleted,
          () {
            _playFeedback((cue) => cue.playTap());
            widget.analytics.gameFlowAction(
              action: 'play_next',
              gameId: game.id,
              nextGameId: nextGame.id,
              nextGameTitle: nextGame.title,
            );
            Navigator.of(context).pop(_GameRouteAction.playNextGame);
          },
          nextGame.title,
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
      category: game.category,
      difficultyTier: game.difficultyTier,
      contentTotal: game.contentTotal,
      gameIndex: gameIndex < 0 ? null : gameIndex + 1,
      completedGames: completionRequested ? completedAfter : completedBefore,
      totalGames: kidsGameCatalog.length,
    );

    if (mounted) {
      setState(() {});
    }

    if (mounted && routeResult == _GameRouteAction.playNextGame) {
      await _openGame(
        _nextGameAfter(game, widget.progressRepository.completedGameIds),
      );
      return;
    }

    if (mounted && completionRequested) {
      await widget.adsController.recordCompletedGameBreak(
        gameId: game.id,
        gameTitle: game.title,
        completedGames: completedAfter,
        totalGames: kidsGameCatalog.length,
        gameDurationMs: DateTime.now().difference(startedAt).inMilliseconds,
      );
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
    final completedIds = widget.progressRepository.completedGameIds;
    final completed = completedIds.length;
    final total = kidsGameCatalog.length;
    final progress = total == 0 ? 0.0 : completed / total;
    final nextGame = _nextRecommendedGame(completedIds);
    final quickGame = _gameById('balloon-pop');
    final practiceGame = completedIds.contains('letter-tracing')
        ? _gameById('number-tracing')
        : _gameById('letter-tracing');
    final adventureGames = _adventureMix(completedIds);

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
                        const SizedBox(height: 18),
                        _HubPlayPanel(
                          nextGame: nextGame,
                          completed: completed,
                          total: total,
                          onPlayNext: () => _openGame(nextGame),
                        ),
                        const SizedBox(height: 14),
                        _PlayPlanRail(
                          continueGame: nextGame,
                          quickGame: quickGame,
                          practiceGame: practiceGame,
                          completedIds: completedIds,
                          onContinue: () => _openGame(nextGame),
                          onQuickPlay: () => _openGame(quickGame),
                          onPractice: () => _openGame(practiceGame),
                        ),
                        const SizedBox(height: 14),
                        _AdventureMixPanel(
                          games: adventureGames,
                          completedIds: completedIds,
                          onStartRun: () => _openGame(adventureGames.first),
                          onGameSelected: _openGame,
                        ),
                        const SizedBox(height: 14),
                        _RewardAlbumPanel(
                          games: kidsGameCatalog,
                          completedIds: completedIds,
                          nextGame: nextGame,
                          onUnlockNext: () => _openGame(nextGame),
                          onGameSelected: _openGame,
                        ),
                        const SizedBox(height: 14),
                        _MissionPanel(
                          completed: completed,
                          total: total,
                          nextGame: nextGame,
                        ),
                        const SizedBox(height: 14),
                        _ProgressBanner(
                          completed: completed,
                          total: total,
                          progress: progress,
                        ),
                        const SizedBox(height: 14),
                        _MilestoneStrip(
                          completedIds: completedIds,
                          completed: completed,
                          total: total,
                        ),
                        const SizedBox(height: 24),
                        const _SectionHeader(
                          title: 'Game Library',
                          trailing: _SafetyBadge(),
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
                    mainAxisExtent: 246,
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
                      recommended: nextGame.id == game.id,
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

  KidsGame _nextRecommendedGame(Set<String> completedIds) {
    return kidsGameCatalog.firstWhere(
      (game) => !completedIds.contains(game.id),
      orElse: () => kidsGameCatalog.first,
    );
  }

  KidsGame _nextGameAfter(KidsGame current, Set<String> completedIds) {
    final currentIndex = kidsGameCatalog.indexWhere(
      (game) => game.id == current.id,
    );
    if (currentIndex < 0) {
      return _nextRecommendedGame(completedIds);
    }

    final updatedCompletedIds = <String>{...completedIds, current.id};
    for (var offset = 1; offset <= kidsGameCatalog.length; offset += 1) {
      final candidate =
          kidsGameCatalog[(currentIndex + offset) % kidsGameCatalog.length];
      if (!updatedCompletedIds.contains(candidate.id)) {
        return candidate;
      }
    }

    return kidsGameCatalog[(currentIndex + 1) % kidsGameCatalog.length];
  }

  KidsGame _gameById(String id) {
    for (final game in kidsGameCatalog) {
      if (game.id == id) {
        return game;
      }
    }
    return kidsGameCatalog.first;
  }

  List<KidsGame> _adventureMix(Set<String> completedIds) {
    const preferredOrder = <String>[
      'balloon-pop',
      'letter-tracing',
      'memory-match',
      'shape-match',
      'counting',
      'magic-drawing',
      'animal-finder',
      'pattern-puzzle',
      'color-sort',
      'number-tracing',
    ];
    final orderedGames = preferredOrder.map(_gameById).toList();
    final startIndex = completedIds.length % orderedGames.length;
    final rotatedGames = <KidsGame>[
      ...orderedGames.skip(startIndex),
      ...orderedGames.take(startIndex),
    ];
    final freshGames = rotatedGames
        .where((game) => !completedIds.contains(game.id))
        .toList();
    final replayGames = rotatedGames
        .where((game) => completedIds.contains(game.id))
        .toList();
    return <KidsGame>[...freshGames, ...replayGames].take(4).toList();
  }
}

enum _GameRouteAction { playNextGame }

class _HubPlayPanel extends StatelessWidget {
  const _HubPlayPanel({
    required this.nextGame,
    required this.completed,
    required this.total,
    required this.onPlayNext,
  });

  final KidsGame nextGame;
  final int completed;
  final int total;
  final VoidCallback onPlayNext;

  @override
  Widget build(BuildContext context) {
    final allComplete = total > 0 && completed >= total;
    final title = allComplete ? 'Replay your favorites' : 'Next up';
    final subtitle = allComplete
        ? 'All games explored. Try for cleaner rounds and higher stars.'
        : nextGame.mission;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF33275C),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2933275C),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final text = _HubPlayCopy(
            title: title,
            game: nextGame,
            subtitle: subtitle,
            completed: completed,
            total: total,
          );
          final button = _PlayNextButton(game: nextGame, onPressed: onPlayNext);

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [text, const SizedBox(height: 16), button],
            );
          }

          return Row(
            children: [
              Expanded(child: text),
              const SizedBox(width: 18),
              SizedBox(width: 210, child: button),
            ],
          );
        },
      ),
    );
  }
}

class _HubPlayCopy extends StatelessWidget {
  const _HubPlayCopy({
    required this.title,
    required this.game,
    required this.subtitle,
    required this.completed,
    required this.total,
  });

  final String title;
  final KidsGame game;
  final String subtitle;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: game.colors),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Icon(game.icon, size: 38, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFFFD86B),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                game.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFE8E1FF),
                  fontSize: 15,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$completed/$total games explored',
                style: const TextStyle(
                  color: Color(0xFFBFB3EA),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayNextButton extends StatelessWidget {
  const _PlayNextButton({required this.game, required this.onPressed});

  final KidsGame game;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      key: const ValueKey('play-next-button'),
      onPressed: onPressed,
      iconAlignment: IconAlignment.end,
      icon: const Icon(Icons.play_arrow_rounded, size: 30),
      label: Text(
        'Play ${game.title}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
      ),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 64),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF35275F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _MissionPanel extends StatelessWidget {
  const _MissionPanel({
    required this.completed,
    required this.total,
    required this.nextGame,
  });

  final int completed;
  final int total;
  final KidsGame nextGame;

  @override
  Widget build(BuildContext context) {
    final nextGoal = _nextGoal(completed, total);
    final remaining = (nextGoal - completed).clamp(0, total);
    final complete = total > 0 && completed >= total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFE8F7FF),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(11),
              child: Icon(
                Icons.flag_rounded,
                color: Color(0xFF2377B8),
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complete ? 'Mission board complete' : 'Next mission',
                  style: const TextStyle(
                    color: Color(0xFF40355A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  complete
                      ? 'Replay games to improve scores, stars, and drawings.'
                      : remaining == 1
                      ? 'Finish ${nextGame.title} to reach $nextGoal games.'
                      : 'Explore $remaining more games to reach $nextGoal.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF686078),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _nextGoal(int completed, int total) {
    for (final goal in const [1, 3, 6, 10]) {
      if (completed < goal) {
        return goal.clamp(0, total).toInt();
      }
    }
    return total;
  }
}

class _PlayPlanRail extends StatelessWidget {
  const _PlayPlanRail({
    required this.continueGame,
    required this.quickGame,
    required this.practiceGame,
    required this.completedIds,
    required this.onContinue,
    required this.onQuickPlay,
    required this.onPractice,
  });

  final KidsGame continueGame;
  final KidsGame quickGame;
  final KidsGame practiceGame;
  final Set<String> completedIds;
  final VoidCallback onContinue;
  final VoidCallback onQuickPlay;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    final actions = <_PlayPlanAction>[
      _PlayPlanAction(
        icon: Icons.play_circle_fill_rounded,
        title: 'Continue',
        game: continueGame,
        detail: completedIds.contains(continueGame.id)
            ? 'Replay for a cleaner run'
            : continueGame.mission,
        onPressed: onContinue,
      ),
      _PlayPlanAction(
        icon: Icons.bolt_rounded,
        title: 'Quick run',
        game: quickGame,
        detail: 'Pop a wave and chase score',
        onPressed: onQuickPlay,
      ),
      _PlayPlanAction(
        icon: Icons.gesture_rounded,
        title: 'Practice',
        game: practiceGame,
        detail: completedIds.contains(practiceGame.id)
            ? 'Replay a trace path'
            : practiceGame.mission,
        onPressed: onPractice,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Play Plan',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF35275F),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            if (compact) {
              return SizedBox(
                height: 118,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: actions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 286,
                      child: _PlayPlanCard(action: actions[index]),
                    );
                  },
                ),
              );
            }

            final cards = <Widget>[];

            for (var index = 0; index < actions.length; index += 1) {
              final card = _PlayPlanCard(action: actions[index]);
              cards.add(Expanded(child: card));
              if (index < actions.length - 1) {
                cards.add(const SizedBox(width: 10));
              }
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: cards,
            );
          },
        ),
      ],
    );
  }
}

class _PlayPlanAction {
  const _PlayPlanAction({
    required this.icon,
    required this.title,
    required this.game,
    required this.detail,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final KidsGame game;
  final String detail;
  final VoidCallback onPressed;
}

class _PlayPlanCard extends StatelessWidget {
  const _PlayPlanCard({required this.action});

  final _PlayPlanAction action;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${action.title}: ${action.game.title}',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            onTap: action.onPressed,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: action.game.colors),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(action.icon, color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          action.title.toUpperCase(),
                          textScaler: TextScaler.noScaling,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF756B88),
                            fontSize: 11,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          action.game.title,
                          textScaler: TextScaler.noScaling,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF35275F),
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          action.detail,
                          textScaler: TextScaler.noScaling,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF686078),
                            fontWeight: FontWeight.w700,
                            height: 1.18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF7257E8),
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

class _AdventureMixPanel extends StatelessWidget {
  const _AdventureMixPanel({
    required this.games,
    required this.completedIds,
    required this.onStartRun,
    required this.onGameSelected,
  });

  final List<KidsGame> games;
  final Set<String> completedIds;
  final VoidCallback onStartRun;
  final ValueChanged<KidsGame> onGameSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('adventure-mix-panel'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFBFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE3DAF7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10634FA8),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adventure Mix',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF35275F),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'A quick run across different play styles',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF746B86),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                key: const ValueKey('adventure-start-run'),
                onPressed: onStartRun,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text(
                  'Start run',
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(132, 52),
                  backgroundColor: const Color(0xFF7257E8),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: games.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final game = games[index];
                return SizedBox(
                  width: 228,
                  child: _AdventureGameChip(
                    game: game,
                    completed: completedIds.contains(game.id),
                    onPressed: () => onGameSelected(game),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdventureGameChip extends StatelessWidget {
  const _AdventureGameChip({
    required this.game,
    required this.completed,
    required this.onPressed,
  });

  final KidsGame game;
  final bool completed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${game.title}. ${completed ? 'Replay' : game.mission}',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          key: ValueKey('adventure-chip-${game.id}'),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: game.colors),
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(game.icon, color: Colors.white, size: 30),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          completed ? 'REPLAY' : game.category.toUpperCase(),
                          textScaler: TextScaler.noScaling,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 10,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          game.title,
                          textScaler: TextScaler.noScaling,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          completed ? 'Try a cleaner run' : game.mission,
                          textScaler: TextScaler.noScaling,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 12,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 24,
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

class _RewardAlbumPanel extends StatelessWidget {
  const _RewardAlbumPanel({
    required this.games,
    required this.completedIds,
    required this.nextGame,
    required this.onUnlockNext,
    required this.onGameSelected,
  });

  final List<KidsGame> games;
  final Set<String> completedIds;
  final KidsGame nextGame;
  final VoidCallback onUnlockNext;
  final ValueChanged<KidsGame> onGameSelected;

  @override
  Widget build(BuildContext context) {
    final unlockedCount = games
        .where((game) => completedIds.contains(game.id))
        .length;
    final total = games.length;
    final allUnlocked = total > 0 && unlockedCount >= total;
    final progress = total == 0 ? 0.0 : unlockedCount / total;

    return Container(
      key: const ValueKey('reward-album-panel'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF35275F), Color(0xFF7257E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2635275F),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final header = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Badge Book',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFFFFD86B),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    allUnlocked
                        ? 'All badges unlocked. Replay for cleaner runs.'
                        : 'Unlock ${nextGame.title} to add the next badge.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFE8E1FF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
              final action = FilledButton.icon(
                key: const ValueKey('reward-unlock-next'),
                onPressed: onUnlockNext,
                icon: Icon(
                  allUnlocked
                      ? Icons.replay_rounded
                      : Icons.workspace_premium_rounded,
                ),
                label: Text(
                  allUnlocked ? 'Replay' : 'Unlock next',
                  textScaler: TextScaler.noScaling,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF35275F),
                  minimumSize: const Size(132, 52),
                ),
              );

              if (constraints.maxWidth < 500) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [header, const SizedBox(height: 12), action],
                );
              }

              return Row(
                children: [
                  Expanded(child: header),
                  const SizedBox(width: 12),
                  SizedBox(width: 154, child: action),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    color: const Color(0xFFFFD86B),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$unlockedCount/$total',
                textScaler: TextScaler.noScaling,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 142,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: games.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final game = games[index];
                return SizedBox(
                  width: 142,
                  child: _RewardBadgeTile(
                    game: game,
                    unlocked: completedIds.contains(game.id),
                    recommended: game.id == nextGame.id && !allUnlocked,
                    onPressed: () => onGameSelected(game),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardBadgeTile extends StatelessWidget {
  const _RewardBadgeTile({
    required this.game,
    required this.unlocked,
    required this.recommended,
    required this.onPressed,
  });

  final KidsGame game;
  final bool unlocked;
  final bool recommended;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = unlocked ? Colors.white : const Color(0xFFBFB3EA);
    final badgeColor = unlocked
        ? game.colors.first
        : Colors.white.withValues(alpha: 0.12);

    return Semantics(
      button: true,
      label: unlocked
          ? '${game.title} badge unlocked'
          : '${game.title} badge locked',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: unlocked ? 0.16 : 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: recommended
                    ? const Color(0xFFFFD86B)
                    : Colors.white.withValues(alpha: unlocked ? 0.28 : 0.12),
                width: recommended ? 3 : 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.28),
                        ),
                      ),
                    ),
                    Icon(
                      unlocked ? game.icon : Icons.lock_rounded,
                      color: foreground,
                      size: 27,
                    ),
                    if (unlocked)
                      const Positioned(
                        right: 0,
                        bottom: 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFF25A97A),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  game.title,
                  textScaler: TextScaler.noScaling,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unlocked
                      ? 'Unlocked'
                      : recommended
                      ? 'Next'
                      : 'Locked',
                  textScaler: TextScaler.noScaling,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: recommended ? const Color(0xFFFFD86B) : foreground,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF35275F),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Align(alignment: Alignment.centerRight, child: trailing),
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

class _MilestoneStrip extends StatelessWidget {
  const _MilestoneStrip({
    required this.completedIds,
    required this.completed,
    required this.total,
  });

  final Set<String> completedIds;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final milestones = <_HubMilestone>[
      _HubMilestone(
        icon: Icons.play_circle_fill_rounded,
        label: 'First clear',
        achieved: completed >= 1,
      ),
      _HubMilestone(
        icon: Icons.gesture_rounded,
        label: 'Trace clear',
        achieved:
            completedIds.contains('letter-tracing') ||
            completedIds.contains('number-tracing'),
      ),
      _HubMilestone(
        icon: Icons.extension_rounded,
        label: 'Puzzle run',
        achieved:
            completedIds.contains('shape-match') ||
            completedIds.contains('color-sort') ||
            completedIds.contains('pattern-puzzle'),
      ),
      _HubMilestone(
        icon: Icons.emoji_events_rounded,
        label: 'All explored',
        achieved: total > 0 && completed >= total,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFBFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2DAF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Milestones',
            style: TextStyle(
              color: Color(0xFF35275F),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: milestones.map((milestone) {
              return _MilestoneChip(milestone: milestone);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _HubMilestone {
  const _HubMilestone({
    required this.icon,
    required this.label,
    required this.achieved,
  });

  final IconData icon;
  final String label;
  final bool achieved;
}

class _MilestoneChip extends StatelessWidget {
  const _MilestoneChip({required this.milestone});

  final _HubMilestone milestone;

  @override
  Widget build(BuildContext context) {
    final foreground = milestone.achieved
        ? const Color(0xFF236E55)
        : const Color(0xFF766E86);
    final background = milestone.achieved
        ? const Color(0xFFDFF7EC)
        : const Color(0xFFF1EEF8);

    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: milestone.achieved
              ? const Color(0xFF8FD8BD)
              : const Color(0xFFE4DDEF),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            milestone.achieved ? Icons.check_circle_rounded : milestone.icon,
            color: foreground,
            size: 20,
          ),
          const SizedBox(width: 7),
          Text(
            milestone.label,
            textScaler: TextScaler.noScaling,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w900),
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
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          key: ValueKey('game-card-${game.id}'),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: game.colors,
            ),
            borderRadius: BorderRadius.circular(24),
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
                            borderRadius: BorderRadius.circular(16),
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
                    game.category.toUpperCase(),
                    textScaler: TextScaler.noScaling,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 11,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
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
                    completed
                        ? 'Completed - replay for a cleaner run'
                        : game.mission,
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
