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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.analytics.appLifecycleChanged(state.name);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.analytics.appLifecycleChanged('disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
