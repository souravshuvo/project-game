import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/farm_save_store.dart';
import '../domain/crop_definition.dart';
import '../domain/farm_action_result.dart';
import '../domain/farm_plot.dart';
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
  bool _lastActionChanged = false;
  String _selectedCropId;

  FarmState get state => _state;
  bool get saving => _saving;
  bool get lastActionChanged => _lastActionChanged;
  int get nowMs => clock.nowMs;
  String get selectedCropId => _selectedCropId;
  CropDefinition get selectedCrop => rules.cropById(_selectedCropId);
  List<CropDefinition> get allCrops => rules.crops;
  List<CropDefinition> get unlockedCrops =>
      rules.unlockedCrops(_state.farmLevel);

  void start() {
    WidgetsBinding.instance.addObserver(this);
    analytics.log(FarmAnalyticsEvents.gameStarted, <String, Object?>{
      ..._commonAnalyticsProperties(),
      'farm_level': _state.farmLevel,
      'has_return_progress': returnReport.hasProgress,
    });
    if (returnReport.hasProgress) {
      analytics
          .log(FarmAnalyticsEvents.offlineProgressApplied, <String, Object?>{
            ..._commonAnalyticsProperties(),
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
      _lastActionChanged = false;
      return;
    }
    _selectedCropId = cropId;
    _lastActionChanged = true;
    analytics.log(FarmAnalyticsEvents.plotSelected, <String, Object?>{
      ..._commonAnalyticsProperties(),
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
    _lastActionChanged = true;
    return 'Saved.';
  }

  Future<String> resetProgress() async {
    final now = nowMs;
    _state = rules.initialState(now);
    returnReport = const FarmReturnReport();
    _selectedCropId = rules.unlockedCrops(_state.farmLevel).first.id;
    _lastActionChanged = true;
    analytics.log(FarmAnalyticsEvents.progressReset);

    _saving = true;
    notifyListeners();
    await saveStore.save(_state);
    if (_disposed) {
      return 'New garden started.';
    }
    _saving = false;
    notifyListeners();
    return 'New garden started.';
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
    _lastActionChanged = result.changed;
    _ensureSelectedCropIsAvailable();
    notifyListeners();

    if (result.changed) {
      analytics.log(eventName, <String, Object?>{
        ..._commonAnalyticsProperties(),
        ...properties,
      });
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

  Map<String, Object?> _commonAnalyticsProperties() {
    final unlockedPlots = rules.unlockedPlotCount(_state.farmLevel);
    var activePlots = 0;
    var readyPlots = 0;
    var dryPlots = 0;
    for (var index = 0; index < unlockedPlots; index += 1) {
      final status = rules.plotStatus(_state, index, nowMs);
      if (status != PlotStatus.empty) {
        activePlots += 1;
      }
      if (status == PlotStatus.ready) {
        readyPlots += 1;
      }
      if (status == PlotStatus.plantedDry) {
        dryPlots += 1;
      }
    }

    return <String, Object?>{
      'farm_level': _state.farmLevel,
      'difficulty_stage': 'level_${_state.farmLevel}',
      'unlocked_plots': unlockedPlots,
      'active_plots': activePlots,
      'ready_plots': readyPlots,
      'dry_plots': dryPlots,
      'coins': _state.coins,
      'water': _state.water,
      'seeds': _state.inventory.seeds,
      'crate_items': _state.inventory.totalCrateItems,
      'selected_crop_id': _selectedCropId,
    };
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
