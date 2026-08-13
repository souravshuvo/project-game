import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/game_content.dart';
import 'package:rapid_jump/game_engine.dart';
import 'package:rapid_jump/main.dart';
import 'package:rapid_jump/services/ad_frequency_cap.dart';

void main() {
  group('CricketMatch scoring rules', () {
    test('wide and no-ball add extras without using legal balls', () {
      final match = CricketMatch(
        rules: const GameRules(maxOvers: 1, maxWickets: 1),
      );

      match.deliver(DeliveryOutcome.wide);
      match.deliver(DeliveryOutcome.noBall);

      expect(match.state.firstInnings.runs, 2);
      expect(match.state.firstInnings.extras, 2);
      expect(match.state.firstInnings.legalBalls, 0);
      expect(match.state.phase, MatchPhase.firstInnings);
    });

    test('practice innings ends after its legal balls without a target', () {
      final match = CricketMatch(
        mode: GameMode.practiceInnings,
        rules: const GameRules(maxOvers: 1, maxWickets: 3),
      );

      match
        ..deliver(DeliveryOutcome.one)
        ..deliver(DeliveryOutcome.two)
        ..deliver(DeliveryOutcome.dot)
        ..deliver(DeliveryOutcome.four)
        ..deliver(DeliveryOutcome.dot)
        ..deliver(DeliveryOutcome.wicket);

      expect(match.state.phase, MatchPhase.matchComplete);
      expect(match.state.target, isNull);
      expect(match.state.firstInnings.runs, 7);
      expect(match.state.matchResult, 'Practice complete: 7/1');
    });

    test('first target-chase innings ends cleanly and creates a target', () {
      final match = CricketMatch(
        rules: const GameRules(maxOvers: 1, maxWickets: 3),
      );

      match
        ..deliver(DeliveryOutcome.one)
        ..deliver(DeliveryOutcome.two)
        ..deliver(DeliveryOutcome.dot)
        ..deliver(DeliveryOutcome.four)
        ..deliver(DeliveryOutcome.dot)
        ..deliver(DeliveryOutcome.wicket);

      expect(match.state.phase, MatchPhase.inningsBreak);
      expect(match.state.firstInnings.runs, 7);
      expect(match.state.firstInnings.legalBalls, 6);
      expect(match.state.target, 8);

      match.startChase();

      expect(match.state.phase, MatchPhase.secondInnings);
      expect(match.state.secondInnings.runs, 0);
      expect(match.state.secondInnings.legalBalls, 0);
    });

    test('chase can be won by an extra without using a legal ball', () {
      final match = CricketMatch(
        rules: const GameRules(maxOvers: 1, maxWickets: 1),
      );

      match.deliver(DeliveryOutcome.wicket);
      expect(match.state.target, 1);

      match.startChase();
      match.deliver(DeliveryOutcome.wide);

      expect(match.state.phase, MatchPhase.matchComplete);
      expect(match.state.secondInnings.runs, 1);
      expect(match.state.secondInnings.legalBalls, 0);
      expect(match.state.matchResult, 'Chase won by 1 wicket');
    });

    test('match can tie without exceeding balls or wickets', () {
      final match = CricketMatch(
        rules: const GameRules(maxOvers: 1, maxWickets: 3),
      );

      match
        ..deliver(DeliveryOutcome.one)
        ..deliver(DeliveryOutcome.dot)
        ..deliver(DeliveryOutcome.dot)
        ..deliver(DeliveryOutcome.dot)
        ..deliver(DeliveryOutcome.dot)
        ..deliver(DeliveryOutcome.dot)
        ..startChase()
        ..deliver(DeliveryOutcome.one)
        ..deliver(DeliveryOutcome.dot)
        ..deliver(DeliveryOutcome.dot)
        ..deliver(DeliveryOutcome.dot)
        ..deliver(DeliveryOutcome.dot)
        ..deliver(DeliveryOutcome.dot);

      expect(match.state.phase, MatchPhase.matchComplete);
      expect(match.state.matchResult, 'Match tied');
      expect(match.state.secondInnings.legalBalls, 6);
      expect(match.state.secondInnings.wickets, 0);
    });

    test('deliveries are blocked during innings break', () {
      final match = CricketMatch(
        rules: const GameRules(maxOvers: 1, maxWickets: 1),
      );

      match.deliver(DeliveryOutcome.wicket);

      expect(match.state.phase, MatchPhase.inningsBreak);
      expect(
        () => match.deliver(DeliveryOutcome.six),
        throwsA(isA<StateError>()),
      );
    });

    test('practice mode cannot start a chase', () {
      final match = CricketMatch(
        mode: GameMode.practiceInnings,
        rules: const GameRules(maxOvers: 1, maxWickets: 1),
      );

      match.deliver(DeliveryOutcome.wicket);

      expect(match.state.phase, MatchPhase.matchComplete);
      expect(match.startChase, throwsA(isA<StateError>()));
    });

    test('deliveries are blocked after match completion', () {
      final match = CricketMatch(
        mode: GameMode.practiceInnings,
        rules: const GameRules(maxOvers: 1, maxWickets: 1),
      );

      match.deliver(DeliveryOutcome.wicket);

      expect(match.state.phase, MatchPhase.matchComplete);
      expect(
        () => match.deliver(DeliveryOutcome.six),
        throwsA(isA<StateError>()),
      );
    });

    test('restart clears scores while preserving the mode', () {
      final match = CricketMatch(
        mode: GameMode.practiceInnings,
        rules: const GameRules(maxOvers: 1, maxWickets: 1),
      );

      match
        ..deliver(DeliveryOutcome.wide)
        ..deliver(DeliveryOutcome.wicket)
        ..restart();

      expect(match.state.mode, GameMode.practiceInnings);
      expect(match.state.phase, MatchPhase.firstInnings);
      expect(match.state.firstInnings.runs, 0);
      expect(match.state.firstInnings.extras, 0);
      expect(match.state.firstInnings.wickets, 0);
      expect(match.state.firstInnings.legalBalls, 0);
      expect(match.state.target, isNull);
    });

    test('delivery history records outcomes for challenge validation', () {
      final match = CricketMatch(
        mode: GameMode.practiceInnings,
        rules: const GameRules(maxOvers: 1, maxWickets: 3),
      );

      match
        ..deliver(DeliveryOutcome.four)
        ..deliver(DeliveryOutcome.wide)
        ..deliver(DeliveryOutcome.six);

      expect(match.state.deliveries, hasLength(3));
      expect(match.state.deliveries[0].outcome, DeliveryOutcome.four);
      expect(match.state.deliveries[1].consumedLegalBall, isFalse);
      expect(match.state.deliveries[2].outcome, DeliveryOutcome.six);
    });
  });

  group('Production v1 content', () {
    test('challenge ladder has enough original v1 content and unique ids', () {
      final ids = kChallengeLadder.map((challenge) => challenge.id).toSet();

      expect(kMatchPresets, hasLength(3));
      expect(kChallengeLadder.length, greaterThanOrEqualTo(20));
      expect(ids, hasLength(kChallengeLadder.length));
      expect(kChallengeLadder.first.difficulty, ChallengeDifficulty.beginner);
      expect(kChallengeLadder.last.difficulty, ChallengeDifficulty.sharp);
    });

    test('challenge progression unlocks in order', () {
      var progress = GameProgress.initial();

      expect(progress.isChallengeUnlocked(kChallengeLadder.first), isTrue);
      expect(progress.isChallengeUnlocked(kChallengeLadder[1]), isFalse);

      final match = CricketMatch(
        mode: GameMode.practiceInnings,
        rules: kPocketPreset.rules,
      )
        ..deliver(DeliveryOutcome.wicket)
        ..deliver(DeliveryOutcome.wicket);

      progress = progress.recordMatch(
        setup: GameSetup.challenge(kChallengeLadder.first),
        state: match.state,
      );

      expect(progress.isChallengeComplete(kChallengeLadder.first), isTrue);
      expect(progress.isChallengeUnlocked(kChallengeLadder[1]), isTrue);
    });

    test('progress records best scores and keeps recent history small', () {
      var progress = GameProgress.initial();
      const setup = GameSetup(
        mode: GameMode.practiceInnings,
        preset: kPocketPreset,
      );

      for (var index = 0; index < 6; index++) {
        final match = CricketMatch(
          mode: GameMode.practiceInnings,
          rules: kPocketPreset.rules,
        )
          ..deliver(DeliveryOutcome.six)
          ..deliver(DeliveryOutcome.wicket)
          ..deliver(DeliveryOutcome.wicket);

        progress = progress.recordMatch(setup: setup, state: match.state);
      }

      expect(progress.matchesPlayed, 6);
      expect(progress.bestPracticeRuns, 6);
      expect(progress.recentMatches, hasLength(5));
      expect(
        GameProgress.fromJsonString(progress.toJsonString()).matchesPlayed,
        6,
      );
    });
  });

  group('Production ad safety', () {
    test('interstitial cap blocks active gameplay and early matches', () {
      final cap = InterstitialFrequencyCap(
        minCompletedMatches: 2,
        minMatchesBetweenShows: 2,
        minSecondsBetweenShows: 300,
        maxShowsPerSession: 3,
      );
      final now = DateTime(2026, 8, 13, 12);

      expect(
        cap
            .evaluate(
              now: now,
              adsEnabled: true,
              adReady: true,
              safeBreak: false,
            )
            .reason,
        'not_safe_break',
      );

      cap.recordMatchCompleted();

      expect(
        cap
            .evaluate(
              now: now,
              adsEnabled: true,
              adReady: true,
              safeBreak: true,
            )
            .reason,
        'too_few_matches',
      );
    });

    test('interstitial cap allows after enough safe completed matches', () {
      final cap = InterstitialFrequencyCap(
        minCompletedMatches: 2,
        minMatchesBetweenShows: 2,
        minSecondsBetweenShows: 300,
        maxShowsPerSession: 3,
      );
      final now = DateTime(2026, 8, 13, 12);

      cap
        ..recordMatchCompleted()
        ..recordMatchCompleted();

      final decision = cap.evaluate(
        now: now,
        adsEnabled: true,
        adReady: true,
        safeBreak: true,
      );

      expect(decision.canShow, isTrue);

      cap.recordShown(now);

      expect(
        cap
            .evaluate(
              now: now.add(const Duration(minutes: 1)),
              adsEnabled: true,
              adReady: true,
              safeBreak: true,
            )
            .reason,
        'match_gap',
      );
    });
  });

  group('Flutter v1 shell', () {
    testWidgets('starts on the main menu', (tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text('Pencil Pitch'), findsOneWidget);
      expect(find.text('Match preset'), findsOneWidget);
      expect(find.text('Practice innings'), findsOneWidget);
      expect(find.text('Target chase'), findsOneWidget);
      expect(find.text('Challenge ladder'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('How to play'), findsOneWidget);
      expect(find.text('Sound'), findsOneWidget);
      expect(find.text('Haptics'), findsOneWidget);
    });

    testWidgets('opens the how-to-play sheet from the menu', (tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text('How to play'));
      await tester.pumpAndSettle();

      expect(find.text('Tap Spin'), findsOneWidget);
      expect(find.text('Extras replay the ball'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
    });

    testWidgets('opens practice innings from the menu', (tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text('Practice innings'));
      await tester.pump();

      expect(find.text('Practice innings'), findsWidgets);
      expect(find.text('Spin'), findsOneWidget);
      expect(find.text('0/0'), findsOneWidget);
      expect(find.text('overs 0.0/2.0'), findsOneWidget);
    });
  });
}
