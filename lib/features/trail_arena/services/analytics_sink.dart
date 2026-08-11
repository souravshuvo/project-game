abstract class AnalyticsSink {
  void log(String name, [Map<String, Object?> parameters = const {}]);
}

class NoOpAnalyticsSink implements AnalyticsSink {
  const NoOpAnalyticsSink();

  @override
  void log(String name, [Map<String, Object?> parameters = const {}]) {}
}
