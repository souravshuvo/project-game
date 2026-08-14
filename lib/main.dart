import 'package:flutter/material.dart';

import 'features/triple_match/application/triple_match_controller.dart';
import 'features/triple_match/data/local_level_pack.dart';
import 'features/triple_match/domain/puzzle_engine.dart';
import 'features/triple_match/presentation/pages/game_shell_page.dart';
import 'features/triple_match/presentation/theme/triple_match_theme.dart';
import 'shared/ads/ad_mob_service.dart';
import 'shared/analytics/analytics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final analytics = await FirebaseAnalyticsService.initialize();
  analytics.logEvent('app_open', const {});
  final adMobService = AdMobService(analytics: analytics)..start();

  runApp(TripleMatchApp(analytics: analytics, adMobService: adMobService));
}

class TripleMatchApp extends StatelessWidget {
  const TripleMatchApp({
    super.key,
    required this.analytics,
    required this.adMobService,
  });

  final AnalyticsService analytics;
  final AdMobService adMobService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Larder Labels',
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'larder_labels',
      theme: TripleMatchTheme.light(),
      home: _RestorableGameHost(
        analytics: analytics,
        adMobService: adMobService,
      ),
    );
  }
}

class _RestorableGameHost extends StatefulWidget {
  const _RestorableGameHost({
    required this.analytics,
    required this.adMobService,
  });

  final AnalyticsService analytics;
  final AdMobService adMobService;

  @override
  State<_RestorableGameHost> createState() => _RestorableGameHostState();
}

class _RestorableGameHostState extends State<_RestorableGameHost>
    with RestorationMixin {
  final RestorableInt _currentLevelIndex = RestorableInt(0);
  final RestorableInt _highestUnlockedLevelIndex = RestorableInt(0);
  final RestorableString _completedLevelIds = RestorableString('');

  late final TripleMatchController _controller;

  @override
  String? get restorationId => 'game_host';

  @override
  void initState() {
    super.initState();
    _controller = TripleMatchController(
      engine: const PuzzleEngine(),
      levels: localLevelPack,
      analytics: widget.analytics,
    )..addListener(_syncProgressSnapshot);
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_currentLevelIndex, 'current_level_index');
    registerForRestoration(
      _highestUnlockedLevelIndex,
      'highest_unlocked_level_index',
    );
    registerForRestoration(_completedLevelIds, 'completed_level_ids');

    _controller.restoreProgress(
      currentLevelIndex: _currentLevelIndex.value,
      highestUnlockedLevelIndex: _highestUnlockedLevelIndex.value,
      completedLevelIds: _decodeCompletedLevelIds(_completedLevelIds.value),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.adMobService.dispose();
    _currentLevelIndex.dispose();
    _highestUnlockedLevelIndex.dispose();
    _completedLevelIds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameShellPage(
      controller: _controller,
      adMobService: widget.adMobService,
    );
  }

  void _syncProgressSnapshot() {
    _currentLevelIndex.value =
        _controller.state.isWon && !_controller.isLastLevel
        ? _controller.highestUnlockedLevelIndex
        : _controller.currentLevelIndex;
    _highestUnlockedLevelIndex.value = _controller.highestUnlockedLevelIndex;
    final completedIds = _controller.completedLevelIds.toList()..sort();
    _completedLevelIds.value = completedIds.join(',');
  }

  Set<int> _decodeCompletedLevelIds(String value) {
    if (value.isEmpty) {
      return const {};
    }

    final ids = <int>{};
    for (final part in value.split(',')) {
      final parsed = int.tryParse(part);
      if (parsed != null) {
        ids.add(parsed);
      }
    }
    return ids;
  }
}
