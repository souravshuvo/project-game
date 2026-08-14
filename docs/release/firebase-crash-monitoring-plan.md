# Signal Reef Firebase And Crash Monitoring Plan

Last updated: 2026-08-14

## Current Decision

Firebase Analytics support is implemented, but real Firebase configuration is not stored in source.

Crashlytics is not implemented yet.

## What Is Implemented Now

The app has:

- `SignalReefTelemetry` event boundary
- `FirebaseSignalReefTelemetry` adapter
- Dart-define gated Firebase initialization
- Gameplay, difficulty, retention, and ad-impact events

If Firebase dart-defines are missing or initialization fails, the app falls back to `NoOpSignalReefTelemetry` and gameplay continues.

## Firebase Analytics Gate

Before enabling Firebase Analytics for release:

- Firebase project created.
- Android app registered with package `com.childhood.signalreef`.
- iOS app registered with bundle ID `com.childhood.signalreef`, if iOS remains in scope.
- Required Firebase dart-defines supplied by CI or local build config.
- Privacy policy and Play Data safety are updated for Analytics behavior.
- Tester build confirms events appear in Firebase DebugView.

## Crashlytics Gate

Only add Crashlytics after these are ready:

- Firebase project exists.
- Analytics configuration is verified.
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
- Unrelated device data

## Official References

- Firebase Flutter setup: https://firebase.google.com/docs/flutter/setup
- Firebase Analytics events for Flutter: https://firebase.google.com/docs/analytics/events?platform=flutter
- Firebase Crashlytics for Flutter: https://firebase.google.com/docs/crashlytics/flutter/get-started
