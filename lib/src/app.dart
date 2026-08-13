import 'dart:async';

import 'package:flutter/material.dart';

import 'game/infrastructure/ads/game_ads.dart';
import 'game/infrastructure/analytics/game_analytics.dart';
import 'game/presentation/screens/home_screen.dart';
import 'game/presentation/progress/match_history.dart';
import 'game/presentation/settings/game_settings.dart';

class SholoGutiApp extends StatefulWidget {
  const SholoGutiApp({super.key, this.analytics, this.ads});

  final GameAnalytics? analytics;
  final GameAdsController? ads;

  @override
  State<SholoGutiApp> createState() => _SholoGutiAppState();
}

class _SholoGutiAppState extends State<SholoGutiApp>
    with WidgetsBindingObserver {
  final _settings = GameSettingsController();
  late final MatchHistoryController _history;
  late final GameAnalytics _analytics;
  late final GameAdsController _ads;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _history = MatchHistoryController();
    _analytics = widget.analytics ?? GameAnalytics.disabled();
    _ads = widget.ads ?? GameAdsController.disabled(_analytics);
    unawaited(_analytics.logAppOpen());
    unawaited(_analytics.logSessionStart());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_analytics.logSessionEnd());
    _ads.dispose();
    _history.dispose();
    _settings.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_analytics.logAppResume());
      return;
    }
    if (state == AppLifecycleState.paused) {
      unawaited(_analytics.logSessionEnd());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameSettingsScope(
      controller: _settings,
      child: MatchHistoryScope(
        controller: _history,
        child: GameAnalyticsScope(
          analytics: _analytics,
          child: GameAdsScope(
            ads: _ads,
            child: MaterialApp(
              title: 'Sixteen Breed',
              debugShowCheckedModeBanner: false,
              restorationScopeId: 'sixteen_breed',
              navigatorObservers: [GameAnalyticsNavigatorObserver(_analytics)],
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF386A67),
                ),
                useMaterial3: true,
                filledButtonTheme: FilledButtonThemeData(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(64, 48),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                outlinedButtonTheme: OutlinedButtonThemeData(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(64, 48),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              home: const _RestorableHome(),
            ),
          ),
        ),
      ),
    );
  }
}

class _RestorableHome extends StatefulWidget {
  const _RestorableHome();

  @override
  State<_RestorableHome> createState() => _RestorableHomeState();
}

class _RestorableHomeState extends State<_RestorableHome>
    with RestorationMixin {
  final RestorableString _historyJson = RestorableString('[]');
  MatchHistoryController? _history;

  @override
  String? get restorationId => 'home_history';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_historyJson, 'match_history');
    MatchHistoryScope.read(
      context,
    ).restoreFromJson(_historyJson.value, notify: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final history = MatchHistoryScope.read(context);
    if (_history == history) {
      return;
    }
    _history?.removeListener(_syncHistory);
    _history = history..addListener(_syncHistory);
  }

  void _syncHistory() {
    final history = _history;
    if (history == null) {
      return;
    }
    _historyJson.value = history.toRawJson();
  }

  @override
  void dispose() {
    _history?.removeListener(_syncHistory);
    _historyJson.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
