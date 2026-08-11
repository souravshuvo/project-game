import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/src/app.dart';

void main() {
  testWidgets('opens a local Sholo Guti match', (tester) async {
    await tester.pumpWidget(const SholoGutiApp());

    expect(find.text('Rapid Jump'), findsOneWidget);
    expect(find.text('Play Local'), findsOneWidget);

    await tester.tap(find.text('Play Local'));
    await tester.pumpAndSettle();

    expect(find.text('Local Match'), findsOneWidget);
    expect(find.text('Player 1 turn'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
  });
}
