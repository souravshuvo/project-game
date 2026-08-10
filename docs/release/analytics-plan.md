# Signal Reef Privacy-Safe Analytics Plan

Last updated: 2026-08-10

## Current Decision

Do not add analytics SDKs in the current build.

Reason: Signal Reef is still validating control feel, shooting feedback, wave readability, and store-readiness. Adding analytics now would create Data safety/privacy work before the product needs it.

## Current Implementation

The app has a no-op telemetry boundary:

- `lib/features/signal_reef/application/signal_reef_telemetry.dart`
- Default adapter: `NoOpSignalReefTelemetry`

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

Suggested event properties:

- `wave_number`
- `score`
- `hull_remaining`
- `source`
- `setting`

Do not collect names, emails, precise location, contacts, photos, free-text input, or unrelated device data.

## MVP Metrics

- Run start rate
- Wave 1 completion rate
- Wave 2 completion rate
- Wave 3 completion rate
- Damage count per run
- Death wave
- Retry rate
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
