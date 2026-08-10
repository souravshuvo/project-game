import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/farm_save_store.dart';
import '../domain/crop_definition.dart';
import '../domain/farm_action_result.dart';
import '../domain/farm_return_report.dart';
import '../domain/farm_rules.dart';
import '../domain/farm_simulation.dart';
import '../domain/farm_state.dart';
import 'analytics_events.dart';
import 'clock.dart';

class FarmController extends ChangeNotifier with WidgetsBindingObserver {
  FarmController({
    required this.rules,
    required this.simulation,
    required this.saveStore,
    required FarmState initialState,
    required this.returnReport,
    this.clock = const SystemClock(),
    this.analytics = const NoOpFarmAnalytics(),
  }) : _state = initialState,
       _selectedCropId = rules.unlockedCrops(initialState.farmLevel).first.id;

  final FarmRules rules;
  final FarmSimulation simulation;
  final FarmSaveStore saveStore;
  final Clock clock;
  final FarmAnalytics analytics;

  FarmState _state;
  FarmReturnReport returnReport;
  Timer? _ticker;
  bool _saving = false;
  bool _disposed = false;
  String _selectedCropId;

  FarmState get state => _state;
  bool get saving => _saving;
  int get nowMs => clock.nowMs;
  String get selectedCropId => _selectedCropId;
  CropDefinition get selectedCrop => rules.cropById(_selectedCropId);
  List<CropDefinition> get allCrops => rules.crops;
  List<CropDefinition> get unlockedCrops =>
      rules.unlockedCrops(_state.farmLevel);

  void start() {
    WidgetsBinding.instance.addObserver(this);
    analytics.log(FarmAnalyticsEvents.gameStarted, <String, Object?>{
      'farm_level': _state.farmLevel,
      'has_return_progress': returnReport.hasProgress,
    });
    if (returnReport.hasProgress) {
      analytics
          .log(FarmAnalyticsEvents.offlineProgressApplied, <String, Object?>{
            'ready_plots': returnReport.readyPlots,
            'water_restored': returnReport.waterRestored,
            'away_seconds': returnReport.awaySeconds,
            'was_capped': returnReport.wasCapped,
          });
    }
    _tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(save(manual: false));
    }
  }

  void selectCrop(String cropId) {
    if (!rules.isCropUnlocked(cropId, _state.farmLevel)) {
      return;
    }
    _selectedCropId = cropId;
    analytics.log(FarmAnalyticsEvents.plotSelected, <String, Object?>{
      'crop_id': cropId,
    });
    notifyListeners();
  }

  void dismissReturnReport() {
    if (!returnReport.hasProgress) {
      return;
    }
    returnReport = const FarmReturnReport();
    notifyListeners();
  }

  Future<String> plant(int plotIndex) async {
    return _runAction(
      simulation.plant(
        _state,
        plotIndex: plotIndex,
        cropId: _selectedCropId,
        nowMs: nowMs,
      ),
      FarmAnalyticsEvents.plotPlanted,
      <String, Object?>{'plot_index': plotIndex, 'crop_id': _selectedCropId},
    );
  }

  Future<String> water(int plotIndex) async {
    return _runAction(
      simulation.water(_state, plotIndex: plotIndex, nowMs: nowMs),
      FarmAnalyticsEvents.plotWatered,
      <String, Object?>{'plot_index': plotIndex},
    );
  }

  Future<String> harvest(int plotIndex) async {
    final cropId = _state.plots[plotIndex].cropId;
    return _runAction(
      simulation.harvest(_state, plotIndex: plotIndex, nowMs: nowMs),
      FarmAnalyticsEvents.cropHarvested,
      <String, Object?>{'plot_index': plotIndex, 'crop_id': cropId},
    );
  }

  Future<String> sellCrate() async {
    return _runAction(
      simulation.sellCrate(_state, nowMs: nowMs),
      FarmAnalyticsEvents.crateSold,
      <String, Object?>{
        'items_sold': _state.inventory.totalCrateItems,
        'coins_earned': rules.crateSellValue(_state.inventory),
      },
    );
  }

  Future<String> buySeeds() async {
    return _runAction(
      simulation.buySeeds(_state, nowMs: nowMs),
      FarmAnalyticsEvents.seedPackBought,
      <String, Object?>{
        'cost': rules.seedPackCost,
        'seeds_added': rules.seedPackAmount,
      },
    );
  }

  Future<String> upgradeFarm() async {
    final nextUpgrade = rules.nextUpgrade(_state.farmLevel);
    return _runAction(
      simulation.upgradeFarm(_state, nowMs: nowMs),
      FarmAnalyticsEvents.farmUpgraded,
      <String, Object?>{
        'target_level': nextUpgrade?.targetLevel,
        'cost': nextUpgrade?.cost,
      },
    );
  }

  Future<String> saveManually() async {
    analytics.log(FarmAnalyticsEvents.manualSaveTapped);
    await save(manual: true);
    return 'Saved.';
  }

  Future<void> save({required bool manual}) async {
    final now = nowMs;
    _state = simulation
        .applyTimeProgress(_state, now)
        .copyWith(lastSavedAtMs: now);
    if (manual) {
      returnReport = const FarmReturnReport();
    }
    _saving = true;
    notifyListeners();
    await saveStore.save(_state);
    if (_disposed) {
      return;
    }
    _saving = false;
    notifyListeners();
  }

  Future<String> _runAction(
    FarmActionResult result,
    String eventName,
    Map<String, Object?> properties,
  ) async {
    _state = result.state;
    _ensureSelectedCropIsAvailable();
    notifyListeners();

    if (result.changed) {
      analytics.log(eventName, properties);
      await save(manual: false);
    }

    return result.message;
  }

  void _ensureSelectedCropIsAvailable() {
    if (rules.isCropUnlocked(_selectedCropId, _state.farmLevel)) {
      return;
    }
    _selectedCropId = rules.unlockedCrops(_state.farmLevel).first.id;
  }

  void _tick() {
    _state = simulation.applyTimeProgress(_state, nowMs);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    final now = nowMs;
    final stateToSave = simulation
        .applyTimeProgress(_state, now)
        .copyWith(lastSavedAtMs: now);
    unawaited(saveStore.save(stateToSave));
    super.dispose();
  }
}
