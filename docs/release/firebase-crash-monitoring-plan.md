# Firebase And Crash Monitoring Plan

Last updated: 2026-08-14

## Current Decision

Firebase Analytics is wired behind the game telemetry boundary, but production release still requires real Firebase app configuration.

Crashlytics is still deferred. Reason: crash monitoring needs a real Firebase project, release crash handlers, a verified test crash, and updated privacy/Data safety disclosures.

## What Is Implemented Now

The app has a `GameTelemetry` boundary in code and a `FirebaseGameTelemetry` adapter. The adapter buffers early events, initializes Firebase if real config is present, and disables itself if Firebase initialization fails.

Tracked internal event names:

- `app_open`
- `screen_view`
- `level_start`
- `level_complete`
- `level_exit`
- `level_restart`
- `pour_valid`
- `pour_invalid`
- `undo_used`
- `settings_changed`
- `ad_init_complete`
- `ad_init_skipped`
- `ad_init_failed`
- `ad_load_start`
- `ad_load_complete`
- `ad_load_failed`
- `ad_opportunity`
- `ad_frequency_capped`
- `ad_skipped`
- `ad_show`
- `ad_dismissed`
- `ad_show_failed`
- `ad_show_timeout`

Current runtime adapter: `FirebaseGameTelemetry`

Fallback/test adapter: `NoOpGameTelemetry`

Analytics can be disabled at build time with `WEATHER_SORT_ANALYTICS_ENABLED=false`.

## Firebase Analytics Production Gate

Do not treat Analytics as production-ready until these are done:

- Firebase project created.
- Android app registered with package `com.childhood.weatherlabsort`.
- iOS app registered with bundle ID `com.childhood.weatherlabsort`, if iOS remains in scope.
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

Implemented packages:

- `firebase_core`
- `firebase_analytics`

Expected package when Crashlytics is approved:

- `firebase_crashlytics`

Expected setup command:

```powershell
flutterfire configure
```

Implemented adapter file:

- `lib/features/weather_sort/application/firebase_game_telemetry.dart`

The adapter translates `GameTelemetryEvent` to Firebase Analytics events and keeps event/property names aligned with `game_telemetry.dart`.

## Do Not Collect

- Names
- Emails
- Precise location
- Contacts
- Photos
- Free-text input
- Advertising ID beyond what the configured Google/Firebase SDK behavior requires and what policy docs disclose

## Official References

- Firebase Flutter setup: https://firebase.google.com/docs/flutter/setup
- Firebase Analytics events for Flutter: https://firebase.google.com/docs/analytics/events?platform=flutter
- Firebase Crashlytics for Flutter: https://firebase.google.com/docs/crashlytics/flutter/get-started
