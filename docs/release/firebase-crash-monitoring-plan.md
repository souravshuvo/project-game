# Firebase And Crash Monitoring Plan

Last updated: 2026-08-10

## Current Decision

Firebase and Crashlytics are not installed in v1.

Reason: the game has no real Firebase project/config yet, and adding placeholder SDK setup would create misleading privacy, build, and policy work.

## What Is Implemented Now

The app has a no-op `TicTacToeTelemetry` boundary in code.

Tracked internal event names:

- `app_opened`
- `mode_selected`
- `round_started`
- `move_made`
- `invalid_cell_tapped`
- `round_ended`
- `rematch_tapped`
- `score_reset`
- `settings_changed`

Current adapter: `NoOpTicTacToeTelemetry`

This means no event data is sent anywhere in the current build.

## Firebase Analytics Gate

Only add Firebase Analytics after:

- Firebase project is created.
- Android app is registered with package `com.childhood.pocketobservatory`.
- iOS app is registered with bundle ID `com.childhood.pocketobservatory`, if iOS remains in scope.
- `flutterfire configure` can create real `firebase_options.dart`.
- Privacy policy and Play Data safety are updated for Analytics behavior.
- Tester build confirms events appear in Firebase DebugView.

## Crashlytics Gate

Only add Crashlytics after:

- Firebase project exists.
- Crash diagnostics are approved for the next release.
- Crash handlers are added in `main.dart`.
- A test crash is sent and visible in Firebase Console.
- Privacy policy discloses crash diagnostics if required by final SDK behavior.

## Do Not Collect

- Names
- Emails
- Precise location
- Contacts
- Photos
- Free-text input
- Advertising ID unless monetization explicitly requires it and policy docs are updated
