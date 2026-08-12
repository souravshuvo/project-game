import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/features/game/presentation/emoji_chor_police_app.dart';

void main() {
  testWidgets('main menu shows prototype modes', (WidgetTester tester) async {
    await tester.pumpWidget(const EmojiChorPoliceApp());

    expect(find.text('Emoji Chor-Police'), findsOneWidget);
    expect(find.text('Start match'), findsOneWidget);
    expect(find.text('Pass & Play'), findsNothing);
    expect(find.text('One phone. One player. Three bots.'), findsOneWidget);
  });

  testWidgets('solo match reveals only the human card first', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EmojiChorPoliceApp());

    await tester.tap(find.text('Start match'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Your secret card'), findsOneWidget);
    expect(find.text('Reveal my card'), findsOneWidget);
    expect(
      find.text('Bots stay hidden. No one else opens a card.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Reveal my card'));
    await tester.pumpAndSettle();

    expect(find.text('Continue'), findsOneWidget);
  });
}
