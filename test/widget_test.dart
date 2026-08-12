import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/ads/ad_service.dart';
import 'package:rapid_jump/analytics/analytics_service.dart';
import 'package:rapid_jump/main.dart';

void main() {
  testWidgets('main menu renders original game title', (tester) async {
    final analytics = AnalyticsService.disabled();
    await tester.pumpWidget(
      RooftopCurveApp(
        analytics: analytics,
        ads: AdService.disabled(analytics: analytics),
      ),
    );

    expect(find.text('Rooftop Curve'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('How to Play'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.textContaining('No official teams'), findsOneWidget);
  });

  testWidgets('play opens the game without build-time setState errors', (
    tester,
  ) async {
    final analytics = AnalyticsService.disabled();
    await tester.pumpWidget(
      RooftopCurveApp(
        analytics: analytics,
        ads: AdService.disabled(analytics: analytics),
      ),
    );

    await tester.tap(find.text('Play'));
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Challenge'), findsOneWidget);
    expect(find.textContaining('Attempts'), findsOneWidget);
  });

  testWidgets('player can shoot the first challenge with a drag gesture', (
    tester,
  ) async {
    final analytics = AnalyticsService.disabled();
    await tester.pumpWidget(
      RooftopCurveApp(
        analytics: analytics,
        ads: AdService.disabled(analytics: analytics),
      ),
    );

    await tester.tap(find.text('Play'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    final gesture = await tester.startGesture(const Offset(400, 470));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 105));
    await tester.pump();

    expect(find.text('Power'), findsOneWidget);

    await gesture.up();
    for (var i = 0; i < 120; i += 1) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Goal!'), findsOneWidget);
    expect(find.text('Next Challenge'), findsOneWidget);
  });
}
