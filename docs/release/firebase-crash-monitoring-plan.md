# Signal Reef Firebase And Crash Monitoring Plan

Last updated: 2026-08-10

## Current Decision

Firebase is not installed in the current build.

Reason: the game has no real Firebase project/config yet, and adding Firebase placeholders would create misleading privacy, build, and policy work.

## What Is Implemented Now

The app has a no-op `SignalReefTelemetry` boundary in code.

Tracked internal event names:

- `game_start`
- `wave_start`
- `wave_complete`
- `player_damage`
- `player_death`
- `game_win`
- `game_restart`
- `pause_open`
- `pause_resume`
- `settings_changed`
- `best_score_updated`

Current adapter: `NoOpSignalReefTelemetry`

This means no event data is sent anywhere in the current build.

## Firebase Analytics Gate

Only add Firebase Analytics after these are ready:

- Firebase project created.
- Android app registered with package `com.childhood.signalreef`.
- iOS app registered with bundle ID `com.childhood.signalreef`, if iOS remains in scope.
- `flutterfire configure` can create real `firebase_options.dart`.
- Privacy policy and Play Data safety are updated for Analytics behavior.
- Tester build confirms events appear in Firebase DebugView.

## Crashlytics Gate

Only add Crashlytics after these are ready:

- Firebase project exists.
- Analytics decision is made, because Crashlytics breadcrumb logs work best when Analytics is enabled.
- Crash handlers are added in `main.dart`.
- A test crash is sent and visible in Firebase Console.
- Privacy policy discloses crash diagnostics if required by final SDK behavior.

## Implementation Notes For Later

Expected packages:

- `firebase_core`
- `firebase_analytics`
- `firebase_crashlytics`

Expected setup command:

```powershell
flutterfire configure
```

Expected adapter file:

- `lib/features/signal_reef/application/firebase_signal_reef_telemetry.dart`

The adapter should translate `SignalReefTelemetryEvent` to Firebase Analytics events and keep the event/property names already defined in `signal_reef_telemetry.dart`.

## Do Not Collect

- Names
- Emails
- Precise location
- Contacts
- Photos
- Free-text input
- Advertising ID unless monetization explicitly requires it and policy docs are updated

## Official References

- Firebase Flutter setup: https://firebase.google.com/docs/flutter/setup
- Firebase Analytics events for Flutter: https://firebase.google.com/docs/analytics/events?platform=flutter
- Firebase Crashlytics for Flutter: https://firebase.google.com/docs/crashlytics/flutter/get-started
