# Privacy-Safe Analytics Plan

Last updated: 2026-08-02

## Current Decision

Do not add analytics SDKs in the current build.

Reason: Weather Lab Sort is still validating core gameplay, levels, presentation, and store-readiness. Adding analytics now would create Data safety/privacy work before the product needs it.

## Current Implementation

The app has a no-op telemetry boundary:

- `lib/features/weather_sort/application/game_telemetry.dart`
- Default adapter: `NoOpGameTelemetry`

This is only an internal code boundary. It does not transmit data, does not add Firebase, and does not change the current Data safety draft.

## If Analytics Is Added Later

Only add analytics after deciding:

- Which product questions must be answered.
- Which events are required.
- Whether device identifiers or advertising IDs are collected.
- Whether consent, opt-out, or regional handling is needed.
- How the Play Console Data safety form and privacy policy must change.

## Candidate Events

Keep event names simple and avoid personal data:

- `app_open`
- `level_start`
- `level_complete`
- `level_restart`
- `pour_valid`
- `pour_invalid`
- `undo_used`
- `settings_sound_toggle`
- `settings_haptics_toggle`

Suggested event properties:

- `level_id`
- `level_number`
- `move_count`
- `stars`
- `invalid_reason`
- `layers_moved`

Do not collect names, emails, precise location, contacts, photos, free-text input, or unrelated device data.

## MVP Metrics

- Level 1 completion rate
- Level 1 retry rate
- Level 2 unlock rate
- Average moves per level
- Invalid move rate
- Undo use rate
- Day 1 return rate, only if analytics can be implemented with a compliant privacy setup

## Before Adding Any SDK

- Update `docs/release/privacy-and-data-safety.md`.
- Update the hosted privacy policy.
- Update Play Console Data safety.
- Re-check permissions and generated manifests.
- Confirm SDK behavior from the vendor documentation.

## Official References

- Firebase Flutter setup: https://firebase.google.com/docs/flutter/setup
- Firebase Analytics events for Flutter: https://firebase.google.com/docs/analytics/events?platform=flutter
