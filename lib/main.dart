import 'dart:async';

import 'package:flutter/material.dart';

import 'features/weather_sort/application/ad_config.dart';
import 'features/weather_sort/application/ad_frequency_store.dart';
import 'features/weather_sort/application/firebase_game_telemetry.dart';
import 'features/weather_sort/application/game_ad_service.dart';
import 'features/weather_sort/application/game_telemetry.dart';
import 'features/weather_sort/application/google_mobile_ads_game_ad_service.dart';
import 'features/weather_sort/application/water_sort_controller.dart';
import 'features/weather_sort/data/local_water_level_pack.dart';
import 'features/weather_sort/data/water_progress_store.dart';
import 'features/weather_sort/domain/water_player_progress.dart';
import 'features/weather_sort/domain/water_sort_engine.dart';
import 'features/weather_sort/presentation/pages/home_page.dart';
import 'features/weather_sort/presentation/pages/level_complete_page.dart';
import 'features/weather_sort/presentation/pages/level_select_page.dart';
import 'features/weather_sort/presentation/pages/puzzle_page.dart';
import 'features/weather_sort/presentation/pages/settings_page.dart';
import 'features/weather_sort/presentation/theme/weather_sort_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final progressStore = SharedPreferencesWaterProgressStore();
  final initialProgress = await progressStore.load();
  final telemetry = FirebaseGameTelemetry();
  final adService = GoogleMobileAdsGameAdService(
    config: const WeatherSortAdConfig(),
    frequencyStore: SharedPreferencesAdFrequencyStore(),
    telemetry: telemetry,
  );

  runApp(
    WeatherSortApp(
      progressStore: progressStore,
      initialProgress: initialProgress,
      telemetry: telemetry,
      adService: adService,
    ),
  );

  unawaited(telemetry.initialize());
  unawaited(adService.initialize());
}

class WeatherSortApp extends StatefulWidget {
  const WeatherSortApp({
    super.key,
    required this.progressStore,
    required this.initialProgress,
    required this.telemetry,
    required this.adService,
  });

  final WaterProgressStore progressStore;
  final WaterPlayerProgress initialProgress;
  final GameTelemetry telemetry;
  final GameAdService adService;

  @override
  State<WeatherSortApp> createState() => _WeatherSortAppState();
}

class _WeatherSortAppState extends State<WeatherSortApp> {
  late final WaterSortController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WaterSortController(
      engine: const WaterSortEngine(),
      levels: localWaterLevelPack,
      progressStore: widget.progressStore,
      initialProgress: widget.initialProgress,
      telemetry: widget.telemetry,
      adService: widget.adService,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Lab Sort',
      debugShowCheckedModeBanner: false,
      theme: WeatherSortTheme.light(),
      home: _WeatherSortScreenHost(controller: _controller),
    );
  }
}

class _WeatherSortScreenHost extends StatelessWidget {
  const _WeatherSortScreenHost({required this.controller});

  final WaterSortController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final screen = controller.screen;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          reverseDuration: const Duration(milliseconds: 120),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: KeyedSubtree(key: ValueKey(screen), child: _pageFor(screen)),
        );
      },
    );
  }

  Widget _pageFor(WaterSortScreen screen) {
    return switch (screen) {
      WaterSortScreen.home => WaterHomePage(controller: controller),
      WaterSortScreen.levelSelect => WaterLevelSelectPage(
        controller: controller,
      ),
      WaterSortScreen.settings => WaterSettingsPage(controller: controller),
      WaterSortScreen.playing => WaterPuzzlePage(controller: controller),
      WaterSortScreen.complete => WaterLevelCompletePage(
        controller: controller,
      ),
    };
  }
}
