import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/game_services.dart';
import '../../game/data/game_ads.dart';
import '../../game/data/game_analytics.dart';
import '../../game/data/game_progress_store.dart';
import '../../game/data/level_library.dart';
import '../../game/domain/game_model.dart';
import '../../game/presentation/game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({this.services = GameServices.fallback, super.key});

  final GameServices services;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GameProgressStore _progressStore;
  late final GameAnalytics _analytics;
  late final GameAdService _ads;
  GameProgress _progress = GameProgress.initial();

  @override
  void initState() {
    super.initState();
    _progressStore = widget.services.progressStore;
    _analytics = widget.services.analytics;
    _ads = widget.services.ads;
    unawaited(_analytics.logScreenView('home'));
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await _progressStore.load(levelCount: v1Levels.length);
    if (!mounted) {
      return;
    }

    setState(() => _progress = progress);
  }

  Future<void> _openGame({int? initialLevelIndex}) async {
    final targetLevelIndex =
        initialLevelIndex ?? _progress.nextPlayableLevelIndex(v1Levels.length);
    await _analytics.logEvent('level_start_requested', {
      'source': initialLevelIndex == null ? 'continue' : 'level_select',
      'level_number': targetLevelIndex + 1,
      'unlocked_level_number': _progress.unlockedLevelNumber,
      'total_stars': _progress.totalStars,
    });

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(
          initialLevelIndex: targetLevelIndex,
          progressStore: _progressStore,
          analytics: _analytics,
          ads: _ads,
        ),
      ),
    );

    await _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.bubble_chart_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Magnetic Marbles',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Steer a marble stream through gates and clear every cluster.',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF475569),
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ProgressChip(
                        icon: Icons.lock_open_rounded,
                        label:
                            'Unlocked ${_progress.unlockedLevelNumber}/${v1Levels.length}',
                      ),
                      _ProgressChip(
                        icon: Icons.star_rounded,
                        label:
                            'Stars ${_progress.totalStars}/${v1Levels.length * 3}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const ValueKey('play-button'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: () => _openGame(),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Continue'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const ValueKey('level-select-button'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () => _showLevelSelect(context),
                      icon: const Icon(Icons.grid_view_rounded),
                      label: const Text('Levels'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const ValueKey('home-help-button'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () => _showHelp(context),
                      icon: const Icon(Icons.help_outline_rounded),
                      label: const Text('How to play'),
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

  void _showLevelSelect(BuildContext context) {
    unawaited(
      _analytics.logEvent('level_select_open', {
        'unlocked_level_number': _progress.unlockedLevelNumber,
        'total_stars': _progress.totalStars,
      }),
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _LevelSelectSheet(
          progress: _progress,
          onLevelSelected: (index) {
            Navigator.of(context).pop();
            unawaited(_openGame(initialLevelIndex: index));
          },
        );
      },
    );
  }

  void _showHelp(BuildContext context) {
    unawaited(_analytics.logEvent('help_open', {'source': 'home'}));

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const _HomeHelpSheet(),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  const _ProgressChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelSelectSheet extends StatelessWidget {
  const _LevelSelectSheet({
    required this.progress,
    required this.onLevelSelected,
  });

  final GameProgress progress;
  final ValueChanged<int> onLevelSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Levels',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${progress.unlockedLevelNumber} unlocked | ${progress.totalStars} stars',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.builder(
                  itemCount: v1Levels.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.08,
                  ),
                  itemBuilder: (context, index) {
                    final level = v1Levels[index];
                    return _LevelTile(
                      level: level,
                      unlocked: progress.isUnlocked(level.number),
                      stars: progress.bestStarsFor(level.number),
                      onTap: () => onLevelSelected(index),
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

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.level,
    required this.unlocked,
    required this.stars,
    required this.onTap,
  });

  final LevelDefinition level;
  final bool unlocked;
  final int stars;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: unlocked ? Colors.white : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: unlocked ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: unlocked ? colorScheme.primary : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                unlocked ? Icons.bubble_chart_rounded : Icons.lock_rounded,
                color: unlocked ? colorScheme.primary : const Color(0xFF94A3B8),
              ),
              const SizedBox(height: 6),
              Text(
                'Level ${level.number}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: unlocked
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              _SmallStars(stars: stars),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallStars extends StatelessWidget {
  const _SmallStars({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final filled = index < stars;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          color: filled ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
          size: 15,
        );
      }),
    );
  }
}

class _HomeHelpSheet extends StatelessWidget {
  const _HomeHelpSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick guide',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            const _HelpPoint(
              icon: Icons.touch_app_rounded,
              title: 'Hold and drag',
              body: 'The whole lane is your control area.',
            ),
            const _HelpPoint(
              icon: Icons.add_circle_outline_rounded,
              title: 'Choose a gate',
              body: 'Grow the crowd before reaching enemies.',
            ),
            const _HelpPoint(
              icon: Icons.flag_rounded,
              title: 'Clear the level',
              body: 'Win by defeating every cluster with marbles left.',
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpPoint extends StatelessWidget {
  const _HelpPoint({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
