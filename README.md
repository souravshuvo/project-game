# Dots and Boxes

Production v1 candidate for offline Dots and Boxes matches.

## Scope

- Main menu with local two-player and player-vs-bot matches.
- Board presets: 2x2, 3x3, and 4x4 scoreable boxes.
- Bot difficulties: Casual and Tactical.
- Pure Dart move validation, box completion, scoring, and extra-turn rules.
- Pure Dart board scaling and hit testing.
- Flutter `CustomPainter` board with `GestureDetector` tap input.
- Legal-line touch preview and invalid tap feedback.
- In-session recent match history.
- Production-safe AdMob interstitial integration at post-match breaks only.
- Firebase Analytics integration for gameplay, difficulty, retention, and ad impact events.

## Rule Locks

- Drawing an already drawn line is rejected without changing turn or score.
- A shared line can complete two adjacent boxes and awards both.
- Scoring grants an extra turn; non-scoring moves pass the turn.
- Taps near a line are accepted within tolerance, while ambiguous taps near dot intersections are ignored.

## Validation

Focused tests live in `test/dots_and_boxes_game_test.dart`.

Release signing uses `android/key.properties`, which is intentionally ignored by
git. Without that file, Gradle may create an unsigned local release APK for
smoke testing, but it is not Play-ready. For a signed release artifact, copy
`android/key.properties.example` to `android/key.properties`, fill it with real
upload-keystore values, and keep the keystore and passwords out of git.

## AdMob and Analytics

Ads are test-only by default. Interstitials are requested only after completed
matches when the player chooses `Play Again` or `Menu`; ads are never shown
during active turns, line drawing, capture feedback, bot thinking, or gameplay
animation.

Frequency caps:

- No interstitial before 2 completed matches.
- At least 3 completed matches between shown interstitials.
- At least 8 minutes between shown interstitials.
- If an ad is missing, loading, or fails, gameplay/navigation continues.

Production ad units require explicit configuration:

- Android AdMob app ID: set Gradle property `ADMOB_ANDROID_APP_ID`.
- iOS AdMob app ID: override `ADMOB_IOS_APP_ID` in the iOS build settings.
- Runtime production ad units: build with
  `--dart-define=USE_PRODUCTION_ADS=true`,
  `--dart-define=ADMOB_ANDROID_INTERSTITIAL_ID=<android-unit-id>`, and
  `--dart-define=ADMOB_IOS_INTERSTITIAL_ID=<ios-unit-id>`.
- Ads default to non-personalized requests unless
  `--dart-define=ADS_NON_PERSONALIZED=false` is supplied after consent work is
  complete.

Firebase Analytics initializes from native Firebase configuration when present.
For local non-production smoke tests without Firebase files, pass
`--dart-define=FIREBASE_DEMO_PROJECT_ID=demo-dotsandboxes`. If Firebase
configuration is missing or initialization fails, analytics disables itself and
does not block gameplay. For production analytics, add the Firebase app config
files for `com.childhood.dotsandboxes`, including
`android/app/google-services.json` and the iOS `GoogleService-Info.plist`
through Xcode.

## Manual Test

1. Open the app.
2. Choose `2x2`, `3x3`, or `4x4`.
3. Choose `2 Players` or `Vs Bot`.
4. Tap `Start Local Match` or `Start Vs Bot`.
5. Draw lines around boxes.
6. Confirm non-scoring moves switch turns.
7. Confirm completed boxes update score and keep the same player active.
8. Confirm ambiguous taps do not draw the wrong line.
9. Finish the board and confirm the winner or draw banner appears.
10. Use `Play Again` or `Menu` after the result; interstitials may appear only
    there when frequency caps allow.
