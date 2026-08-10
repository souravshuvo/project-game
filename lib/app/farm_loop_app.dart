import 'package:flutter/material.dart';

import '../features/farm/application/clock.dart';
import '../features/farm/application/farm_controller.dart';
import '../features/farm/data/farm_save_store.dart';
import '../features/farm/domain/farm_return_report.dart';
import '../features/farm/domain/farm_rules.dart';
import '../features/farm/domain/farm_simulation.dart';
import '../features/farm/domain/farm_state.dart';
import '../features/farm/presentation/farm_screen.dart';
import 'app_theme.dart';

class FarmLoopApp extends StatefulWidget {
  const FarmLoopApp({
    super.key,
    required this.rules,
    required this.simulation,
    required this.saveStore,
    required this.initialState,
    required this.returnReport,
    required this.clock,
  });

  static const title = 'Rooftop Rain Garden';

  final FarmRules rules;
  final FarmSimulation simulation;
  final FarmSaveStore saveStore;
  final FarmState initialState;
  final FarmReturnReport returnReport;
  final Clock clock;

  @override
  State<FarmLoopApp> createState() => _FarmLoopAppState();
}

class _FarmLoopAppState extends State<FarmLoopApp> {
  late final FarmController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FarmController(
      rules: widget.rules,
      simulation: widget.simulation,
      saveStore: widget.saveStore,
      initialState: widget.initialState,
      returnReport: widget.returnReport,
      clock: widget.clock,
    )..start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FarmLoopApp.title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: FarmScreen(controller: _controller),
    );
  }
}
