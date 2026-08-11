# Privacy-Safe Analytics Plan

Last updated: 2026-08-11

## Current Decision

Firebase Analytics is wired through the app telemetry boundary, with a no-op fallback when Firebase is disabled, unsupported, or not configured.

The implementation is intended to answer v1 gameplay, difficulty, retention, and ad-impact questions without collecting names, emails, location, contacts, photos, free-text input, or account data.

## Current Implementation

- Telemetry boundary: `lib/features/arrow_puzzle/application/game_telemetry.dart`
- Firebase adapter: `lib/features/arrow_puzzle/application/firebase_game_telemetry.dart`
- Runtime initialization: `lib/features/arrow_puzzle/application/app_runtime_services.dart`
- Fallback adapter: `NoOpGameTelemetry`

Runtime controls:

- `ARROW_PUZZLE_FIREBASE_ENABLED=true` by default.
- `ARROW_PUZZLE_CRASHLYTICS_ENABLED=true` by default.
- Firebase falls back to no-op if `Firebase.initializeApp()` fails.

## Implemented Events

- `app_open`: total levels, unlocked count, completed count, streak days.
- `screen_view`: home, level select, settings, playing, complete.
- `level_start`: level id/number, source, board size, arrow count, valid move count.
- `level_complete`: moves, invalid taps, hint use, duration, daily flag, unlock count, board size, arrow count.
- `level_retry`: moves, invalid taps, hint use, duration.
- `level_invalid_tap`: invalid-tap count and valid move count.
- `hint_claim`, `hint_use`, `rewarded_hint_grant`.
- `settings_sound_toggle`, `settings_haptics_toggle`.
- `ad_event`: format, action, placement, test/production environment, level number, error metadata.

## MVP Metrics

- Level 1 completion and retry rate.
- Completion rate by level number.
- Average moves, invalid taps, hints used, and time per level.
- Daily challenge starts and completions.
- Hint claim/use rate and rewarded-hint grant rate.
- Day 1 and Day 7 return proxy from `app_open`, Firebase retention reports, and streak days.
- Ad load/show/impression/failure rate by placement and environment.
- Interstitial exposure versus next-level start rate.

## Production Gate

Before using Analytics for release decisions:

- Create Firebase project.
- Register Android app with package `com.childhood.arrowpuzzle`.
- Register iOS app with bundle ID `com.childhood.arrowpuzzle`, if iOS remains in scope.
- Run `flutterfire configure` or add equivalent platform Firebase config.
- Confirm events appear in Firebase DebugView from an internal test build.
- Update hosted privacy policy and Play Console Data safety for Firebase behavior.

## Do Not Collect

- Names
- Emails
- Precise location
- Contacts
- Photos or files
- Free-text input
- Account identifiers
- Unrelated device data

## Official References

- Firebase Flutter setup: https://firebase.google.com/docs/flutter/setup
- Firebase Analytics events for Flutter: https://firebase.google.com/docs/analytics/events?platform=flutter
