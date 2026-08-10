# Crash Monitoring Plan

Last updated: 2026-08-10

## Current Decision

Firebase and Crashlytics are not installed in current v1.

Reason: the game has no real Firebase project/config yet, and adding placeholder
SDK setup would create misleading privacy, build, and policy work.

## Current Implementation

No analytics or crash monitoring adapter exists in active code. No event or
crash data is sent anywhere by current v1.

## Crash Monitoring Gate

Only add crash monitoring after these are ready:

- Real crash-monitoring project exists.
- Android app is registered with package `com.childhood.larderlabels`.
- iOS app is registered with bundle ID `com.childhood.larderlabels`, if iOS is
  in scope.
- Generated config files are created from real project values.
- Privacy policy and Play Data safety are updated for final SDK behavior.
- Crash handlers are added in `main.dart`.
- A test crash is sent and visible in the provider console.

## Candidate Crash Signals

- App launch crash
- Puzzle screen crash
- Level data parsing failure
- Invalid tile selection assertion
- UI layout overflow on small screens

## Do Not Collect

- Names
- Emails
- Precise location
- Contacts
- Photos
- Free-text input
- Advertising ID unless monetization explicitly requires it and policy docs are
  updated

## Later Implementation Notes

If Firebase is chosen later, use real configuration only. Do not commit fake app
IDs or placeholder generated config files.
