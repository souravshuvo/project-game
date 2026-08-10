import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/main.dart';

void main() {
  testWidgets('main menu renders original game title', (tester) async {
    await tester.pumpWidget(const RooftopCurveApp());

    expect(find.text('Rooftop Curve'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.textContaining('No official teams'), findsOneWidget);
  });
}
