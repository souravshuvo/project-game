import 'package:flutter_test/flutter_test.dart';
import 'package:kidsland/core/analytics/game_analytics.dart';

void main() {
  test('analytics names and parameters stay Firebase-safe', () {
    expect(normalizeAnalyticsName('9 bad-event name'), 'app_9_bad_event_name');
    expect(normalizeAnalyticsName('game_complete'), 'game_complete');

    final parameters = normalizeAnalyticsParameters(<String, Object?>{
      'game-id': 'letter-tracing',
      'completed': true,
      'ignored': null,
      'long': 'x' * 120,
    });

    expect(parameters['game_id'], 'letter-tracing');
    expect(parameters['completed'], 1);
    expect(parameters.containsKey('ignored'), isFalse);
    expect((parameters['long'] as String).length, 100);
  });
}
