# Firebase And Crash Monitoring Plan

Last updated: 2026-08-11

## Current Decision

Firebase Analytics and Crashlytics packages are installed and wired behind runtime initialization.

The app remains safe for development builds because Firebase initialization falls back to `NoOpGameTelemetry` if no Firebase project config is present or if the platform is unsupported.

## What Is Implemented Now

- Packages: `firebase_core`, `firebase_analytics`, `firebase_crashlytics`.
- Runtime bootstrap: `AppRuntimeServices.initialize()`.
- Analytics adapter: `FirebaseGameTelemetry`.
- Crash handlers: Flutter framework errors and platform dispatcher errors are forwarded to Crashlytics after Firebase initializes.
- Debug Crashlytics collection is disabled in code with `setCrashlyticsCollectionEnabled(!kDebugMode)`.
- Android and iOS default Crashlytics collection are disabled in platform config.

Tracked event names:

- `app_open`
- `screen_view`
- `level_start`
- `level_complete`
- `level_retry`
- `level_invalid_tap`
- `hint_claim`
- `hint_use`
- `rewarded_hint_grant`
- `settings_sound_toggle`
- `settings_haptics_toggle`
- `ad_event`

## Firebase Configuration Gate

Before release telemetry is considered production-ready:

- Create Firebase project.
- Register Android app with package `com.childhood.arrowpuzzle`.
- Register iOS app with bundle ID `com.childhood.arrowpuzzle`, if iOS remains in scope.
- Run `flutterfire configure` or add equivalent platform Firebase config.
- Confirm `Firebase.initializeApp()` succeeds on a physical Android test device.
- Confirm Analytics events appear in Firebase DebugView.
- Confirm a non-fatal test error or controlled test crash appears in Crashlytics.
- Update privacy policy and Play Console Data safety for Firebase SDK behavior.

## Do Not Collect

- Names
- Emails
- Precise location
- Contacts
- Photos
- Free-text input
- Account identifiers
- Unrelated device data

## Official References

- Firebase Flutter setup: https://firebase.google.com/docs/flutter/setup
- Firebase Analytics events for Flutter: https://firebase.google.com/docs/analytics/events?platform=flutter
- Firebase Crashlytics for Flutter: https://firebase.google.com/docs/crashlytics/flutter/get-started
