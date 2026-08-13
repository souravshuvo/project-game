import 'package:flutter_test/flutter_test.dart';
import 'package:sixteen_breed/src/app.dart';

void main() {
  testWidgets('opens a local Sholo Guti match', (tester) async {
    await tester.pumpWidget(const SholoGutiApp());

    expect(find.text('Sixteen Breed'), findsWidgets);
    expect(find.text('Sholo Guti / 16 Beads'), findsOneWidget);
    expect(find.text('Local 2 Player'), findsOneWidget);
    expect(find.text('Player vs Bot'), findsOneWidget);
    expect(find.text('History (0)'), findsOneWidget);

    await tester.tap(find.text('Local 2 Player'));
    await tester.pumpAndSettle();

    expect(find.text('Local 2 Player'), findsWidgets);
    expect(find.text('Player 1 turn'), findsOneWidget);
    expect(find.text('Player 1: select one of your beads.'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);
  });
}
