import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/game/board_hit_tester.dart';
import 'package:rapid_jump/game/dots_and_boxes.dart';
import 'package:rapid_jump/game/dots_and_boxes_bot.dart';
import 'package:rapid_jump/main.dart';

void main() {
  group('DotsAndBoxesGame', () {
    test('uses scoreable boxes for board sizing formulas', () {
      final game = DotsAndBoxesGame(rows: 4, columns: 4);

      expect(game.totalBoxes, 16);
      expect(game.totalLines, 40);
      expect(game.openLines.length, 40);
      expect(game.isLineInBounds(const BoardLine.horizontal(4, 3)), isTrue);
      expect(game.isLineInBounds(const BoardLine.vertical(3, 4)), isTrue);
      expect(game.isLineInBounds(const BoardLine.horizontal(5, 0)), isFalse);
      expect(game.isLineInBounds(const BoardLine.vertical(4, 0)), isFalse);
    });

    test('rejects invalid board dimensions', () {
      expect(() => DotsAndBoxesGame(rows: 0, columns: 4), throwsArgumentError);
      expect(() => DotsAndBoxesGame(rows: 4, columns: 0), throwsArgumentError);
    });

    test('rejects an already drawn line without changing state', () {
      final game = DotsAndBoxesGame(rows: 2, columns: 2);

      final firstMove = game.drawLine(const BoardLine.horizontal(0, 0));
      expect(firstMove.accepted, isTrue);
      expect(game.drawnLines.length, 1);
      expect(game.currentPlayer, Player.two);

      final duplicateMove = game.drawLine(const BoardLine.horizontal(0, 0));
      expect(duplicateMove.accepted, isFalse);
      expect(duplicateMove.rejectionReason, contains('already drawn'));
      expect(game.drawnLines.length, 1);
      expect(game.scoreFor(Player.one), 0);
      expect(game.scoreFor(Player.two), 0);
      expect(game.currentPlayer, Player.two);
    });

    test('predicts boxes completed by an open line', () {
      final game = DotsAndBoxesGame(rows: 2, columns: 1);

      game.drawLine(const BoardLine.horizontal(0, 0));
      game.drawLine(const BoardLine.horizontal(2, 0));
      game.drawLine(const BoardLine.vertical(0, 0));
      game.drawLine(const BoardLine.vertical(0, 1));
      game.drawLine(const BoardLine.vertical(1, 0));
      game.drawLine(const BoardLine.vertical(1, 1));

      const scoringLine = BoardLine.horizontal(1, 0);
      expect(game.completedBoxesForLine(scoringLine), 2);

      final result = game.drawLine(scoringLine);
      expect(result.boxesCompleted, 2);
      expect(game.completedBoxesForLine(scoringLine), 0);
    });

    test('awards both adjacent boxes when one shared line completes them', () {
      final game = DotsAndBoxesGame(rows: 2, columns: 1);

      game.drawLine(const BoardLine.horizontal(0, 0));
      game.drawLine(const BoardLine.horizontal(2, 0));
      game.drawLine(const BoardLine.vertical(0, 0));
      game.drawLine(const BoardLine.vertical(0, 1));
      game.drawLine(const BoardLine.vertical(1, 0));
      game.drawLine(const BoardLine.vertical(1, 1));

      final scoringMove = game.drawLine(const BoardLine.horizontal(1, 0));

      expect(scoringMove.accepted, isTrue);
      expect(scoringMove.player, Player.one);
      expect(scoringMove.boxesCompleted, 2);
      expect(scoringMove.extraTurn, isTrue);
      expect(game.scoreFor(Player.one), 2);
      expect(game.currentPlayer, Player.one);
      expect(game.isGameOver, isTrue);
    });

    test('switches turns on open lines and preserves turn after scoring', () {
      final game = DotsAndBoxesGame(rows: 1, columns: 1);

      final openingMove = game.drawLine(const BoardLine.horizontal(0, 0));
      expect(openingMove.extraTurn, isFalse);
      expect(game.currentPlayer, Player.two);

      game.drawLine(const BoardLine.vertical(0, 0));
      game.drawLine(const BoardLine.vertical(0, 1));

      final scoringMove = game.drawLine(const BoardLine.horizontal(1, 0));
      expect(scoringMove.accepted, isTrue);
      expect(scoringMove.player, Player.two);
      expect(scoringMove.boxesCompleted, 1);
      expect(scoringMove.extraTurn, isTrue);
      expect(game.currentPlayer, Player.two);
    });

    test('rejects lines outside the board', () {
      final game = DotsAndBoxesGame(rows: 2, columns: 2);

      final result = game.drawLine(const BoardLine.vertical(2, 0));

      expect(result.accepted, isFalse);
      expect(result.rejectionReason, contains('outside'));
      expect(game.drawnLines, isEmpty);
      expect(game.currentPlayer, Player.one);
    });

    test('ends the match with a winner and rejects post-game moves', () {
      final game = DotsAndBoxesGame(rows: 1, columns: 1);

      game.drawLine(const BoardLine.horizontal(0, 0));
      game.drawLine(const BoardLine.vertical(0, 0));
      game.drawLine(const BoardLine.vertical(0, 1));
      final finalMove = game.drawLine(const BoardLine.horizontal(1, 0));

      expect(finalMove.accepted, isTrue);
      expect(game.isGameOver, isTrue);
      expect(game.scoreFor(Player.one), 0);
      expect(game.scoreFor(Player.two), 1);
      expect(game.winner, Player.two);

      final postGameMove = game.drawLine(const BoardLine.horizontal(0, 0));
      expect(postGameMove.accepted, isFalse);
      expect(postGameMove.rejectionReason, contains('complete'));
      expect(game.scoreFor(Player.two), 1);
      expect(game.currentPlayer, Player.two);
    });

    test('detects a draw when final scores are equal', () {
      final game = DotsAndBoxesGame(rows: 2, columns: 2);

      for (final line in const <BoardLine>[
        BoardLine.horizontal(0, 0),
        BoardLine.horizontal(0, 1),
        BoardLine.horizontal(1, 0),
        BoardLine.horizontal(1, 1),
        BoardLine.horizontal(2, 0),
        BoardLine.horizontal(2, 1),
        BoardLine.vertical(0, 0),
        BoardLine.vertical(0, 1),
        BoardLine.vertical(0, 2),
        BoardLine.vertical(1, 0),
        BoardLine.vertical(1, 1),
        BoardLine.vertical(1, 2),
      ]) {
        final result = game.drawLine(line);
        expect(result.accepted, isTrue);
      }

      expect(game.isGameOver, isTrue);
      expect(game.scoreFor(Player.one), 2);
      expect(game.scoreFor(Player.two), 2);
      expect(game.winner, isNull);
    });
  });

  group('DotsAndBoxesBot', () {
    test('casual bot takes a scoring move when one is available', () {
      final game = DotsAndBoxesGame(rows: 1, columns: 1);
      game.drawLine(const BoardLine.horizontal(0, 0));
      game.drawLine(const BoardLine.vertical(0, 0));
      game.drawLine(const BoardLine.vertical(0, 1));

      final bot = DotsAndBoxesBot(difficulty: BotDifficulty.casual);

      expect(bot.chooseMove(game), const BoardLine.horizontal(1, 0));
    });

    test('tactical bot avoids an immediate giveaway when possible', () {
      final game = DotsAndBoxesGame(rows: 1, columns: 2);
      game.drawLine(const BoardLine.horizontal(0, 0));
      game.drawLine(const BoardLine.vertical(0, 0));

      final bot = DotsAndBoxesBot(difficulty: BotDifficulty.tactical);
      final move = bot.chooseMove(game);

      expect(move, isNot(const BoardLine.horizontal(1, 0)));
      expect(move, isNot(const BoardLine.vertical(0, 1)));
      expect(game.openLines, contains(move));
    });

    test('bot can complete a 2x2 match without illegal moves', () {
      final game = DotsAndBoxesGame(rows: 2, columns: 2);
      final bot = DotsAndBoxesBot(difficulty: BotDifficulty.tactical);

      while (!game.isGameOver) {
        final move = bot.chooseMove(game);

        expect(move, isNotNull);
        expect(game.openLines, contains(move));
        expect(game.drawLine(move!).accepted, isTrue);
      }

      expect(game.drawnLines.length, game.totalLines);
      expect(game.scoreFor(Player.one) + game.scoreFor(Player.two), 4);
    });
  });

  group('BoardHitTester', () {
    test('selects a nearby line when the tap is inside tolerance', () {
      const hitTester = BoardHitTester(
        rows: 2,
        columns: 2,
        width: 240,
        height: 240,
        edgePadding: 20,
        touchTolerance: 18,
        ambiguityMargin: 6,
      );
      final layout = hitTester.metrics;
      final x = (layout.dotX(0) + layout.dotX(1)) / 2;
      final y = layout.dotY(0) + 12;

      expect(hitTester.hitTest(x, y), const BoardLine.horizontal(0, 0));
    });

    test('selects a vertical line on the 4x4 production board', () {
      const hitTester = BoardHitTester(
        rows: 4,
        columns: 4,
        width: 360,
        height: 360,
        edgePadding: 30,
        touchTolerance: 24,
        ambiguityMargin: 8,
      );
      final layout = hitTester.metrics;
      final x = layout.dotX(2) + 10;
      final y = (layout.dotY(1) + layout.dotY(2)) / 2;

      expect(hitTester.hitTest(x, y), const BoardLine.vertical(1, 2));
    });

    test('rejects ambiguous taps near dot intersections', () {
      const hitTester = BoardHitTester(
        rows: 2,
        columns: 2,
        width: 240,
        height: 240,
        edgePadding: 20,
        touchTolerance: 18,
        ambiguityMargin: 6,
      );
      final layout = hitTester.metrics;

      expect(hitTester.hitTest(layout.dotX(0) + 3, layout.dotY(0) + 3), isNull);
    });

    test('ignores taps that are not close enough to any line', () {
      const hitTester = BoardHitTester(
        rows: 2,
        columns: 2,
        width: 240,
        height: 240,
        edgePadding: 20,
        touchTolerance: 18,
        ambiguityMargin: 6,
      );
      final layout = hitTester.metrics;
      final x = (layout.dotX(0) + layout.dotX(1)) / 2;
      final y = (layout.dotY(0) + layout.dotY(1)) / 2;

      expect(hitTester.hitTest(x, y), isNull);
    });
  });

  testWidgets('starts a local 4x4 match from the main menu', (tester) async {
    await tester.pumpWidget(const DotsAndBoxesApp());

    expect(find.text('Dots & Boxes'), findsOneWidget);
    expect(find.text('2x2'), findsOneWidget);
    expect(find.text('3x3'), findsOneWidget);
    expect(find.text('4x4'), findsOneWidget);
    expect(find.text('2 Players'), findsOneWidget);
    expect(find.text('Vs Bot'), findsOneWidget);
    expect(find.text('Start Local Match'), findsOneWidget);
    expect(find.byType(DotsAndBoxesBoard), findsNothing);

    await tester.tap(find.text('Start Local Match'));
    await tester.pumpAndSettle();

    expect(find.text('Local 2 Player'), findsOneWidget);
    expect(find.text('4x4 boxes'), findsOneWidget);
    expect(find.byType(DotsAndBoxesBoard), findsOneWidget);
  });

  testWidgets('starts a bot match from the main menu', (tester) async {
    await tester.pumpWidget(const DotsAndBoxesApp());

    await tester.tap(find.text('Vs Bot'));
    await tester.pumpAndSettle();

    expect(find.text('Casual'), findsOneWidget);
    expect(find.text('Tactical'), findsOneWidget);
    expect(find.text('Start Vs Bot'), findsOneWidget);

    await tester.ensureVisible(find.text('Start Vs Bot'));
    await tester.tap(find.text('Start Vs Bot'));
    await tester.pumpAndSettle();

    expect(find.text('Player vs Bot'), findsOneWidget);
    expect(find.byType(DotsAndBoxesBoard), findsOneWidget);
  });
}
