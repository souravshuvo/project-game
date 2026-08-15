import 'package:flutter/widgets.dart';

import 'game_analytics.dart';

class AnalyticsLifecycleReporter extends StatefulWidget {
  const AnalyticsLifecycleReporter({
    required this.analytics,
    required this.child,
    super.key,
  });

  final GameAnalytics analytics;
  final Widget child;

  @override
  State<AnalyticsLifecycleReporter> createState() =>
      _AnalyticsLifecycleReporterState();
}

class _AnalyticsLifecycleReporterState extends State<AnalyticsLifecycleReporter>
    with WidgetsBindingObserver {
  late final DateTime _startedAt;
  int _lifecycleTransitions = 0;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleTransitions += 1;
    widget.analytics.appLifecycleChanged(state.name);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.analytics.appLifecycleChanged('disposed');
    widget.analytics.appSessionEnd(
      durationMs: DateTime.now().difference(_startedAt).inMilliseconds,
      lifecycleTransitions: _lifecycleTransitions,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
