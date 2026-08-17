import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/shared/analytics/game_analytics.dart';

void main() {
  test('analytics names and parameters are Firebase-safe', () {
    final parameters = sanitizeGameAnalyticsParameters({
      '1 invalid key': true,
      'reason': 'x' * 140,
      'score': 120,
      'ratio': 0.75,
      'bad-value': double.nan,
      'object': Object(),
    });

    expect(
      sanitizeGameAnalyticsName('1 bad event!'),
      'game_event_1_bad_event_',
    );
    expect(parameters['param_1_invalid_key'], 1);
    expect(parameters['reason'], hasLength(100));
    expect(parameters['score'], 120);
    expect(parameters['ratio'], 0.75);
    expect(parameters['bad_value'], 0);
    expect(parameters['object'], isA<String>());
  });

  test('analytics parameters are capped to Firebase event limits', () {
    final parameters = sanitizeGameAnalyticsParameters({
      for (var index = 0; index < 40; index++) 'param_$index': index,
    });

    expect(parameters, hasLength(25));
    expect(parameters['param_0'], 0);
    expect(parameters.containsKey('param_25'), isFalse);
  });

  test('duplicate sanitized keys receive stable suffixes', () {
    final parameters = sanitizeGameAnalyticsParameters({
      'bad-key': 1,
      'bad key': 2,
    });

    expect(parameters['bad_key'], 1);
    expect(parameters['bad_key_2'], 2);
  });
}
