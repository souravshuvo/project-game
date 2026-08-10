import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/features/game/presentation/emoji_chor_police_app.dart';

void main() {
  testWidgets('main menu shows prototype modes', (WidgetTester tester) async {
    await tester.pumpWidget(const EmojiChorPoliceApp());

    expect(find.text('Emoji Chor-Police'), findsOneWidget);
    expect(find.text('Single Player'), findsOneWidget);
    expect(find.text('Pass & Play'), findsOneWidget);
    expect(find.text('Offline secret-role party game'), findsOneWidget);
  });

  testWidgets('pass-and-play uses a handoff gate before each reveal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EmojiChorPoliceApp());

    await tester.tap(find.text('Pass & Play'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Pass to Player 1'), findsOneWidget);
    expect(find.text('Reveal card'), findsNothing);

    await tester.tap(find.text('I am Player 1'));
    await tester.pumpAndSettle();

    expect(find.text("Player 1's private card"), findsOneWidget);
    expect(find.text('Reveal card'), findsOneWidget);

    await tester.tap(find.text('Reveal card'));
    await tester.pumpAndSettle();

    expect(find.text('Hide and continue'), findsOneWidget);

    await tester.tap(find.text('Hide and continue'));
    await tester.pumpAndSettle();

    expect(find.text('Pass to Player 2'), findsOneWidget);
    expect(find.text('Reveal card'), findsNothing);
  });
}
