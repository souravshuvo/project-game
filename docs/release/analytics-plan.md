# Signal Reef Privacy-Safe Analytics Plan

Last updated: 2026-08-14

## Current Decision

Firebase Analytics support is implemented behind a configuration gate.

Default behavior:

- No Firebase project values are bundled in source.
- `FirebaseSignalReefTelemetry.create()` returns `NoOpSignalReefTelemetry` unless Firebase dart-defines are supplied.
- Gameplay and ad events still use the local `SignalReefTelemetry` boundary.

Production analytics requires:

- `SIGNAL_REEF_FIREBASE_ANALYTICS_ENABLED=true`
- `SIGNAL_REEF_FIREBASE_API_KEY`
- `SIGNAL_REEF_FIREBASE_APP_ID`
- `SIGNAL_REEF_FIREBASE_MESSAGING_SENDER_ID`
- `SIGNAL_REEF_FIREBASE_PROJECT_ID`

## Implemented Events

Gameplay and difficulty:

- `app_open`
- `game_start`
- `wave_start`
- `wave_complete`
- `player_damage`
- `player_death`
- `game_win`
- `game_result`
- `game_restart`
- `pause_open`
- `pause_resume`
- `settings_changed`
- `best_score_updated`

Ad impact:

- `ad_sdk_initialized`
- `ad_sdk_failed`
- `ad_load_start`
- `ad_loaded`
- `ad_load_failed`
- `ad_showed`
- `ad_dismissed`
- `ad_show_failed`
- `ad_skipped`

## Measurement Goals

- Session/run length through `duration_seconds`.
- Difficulty by wave through `wave_number`, `total_enemies`, `pulse_seeds`, `max_active_enemies`, `spawn_interval_ms`, `hull_remaining`, and death wave.
- Retention proxies through `app_open`, `runs_played`, `best_score`, and `best_wave_reached`.
- Ad impact through ad load/show/failure/skip events and retry behavior after result screens.

## Privacy Rules

- Do not log names, emails, precise location, contacts, photos, free-text input, or unrelated device data.
- Boolean values are converted to numeric flags before Firebase logging.
- Update Play Console Data safety and the hosted privacy policy before enabling Firebase Analytics in production.

## Official References

- Firebase Flutter setup: https://firebase.google.com/docs/flutter/setup
- Firebase Analytics events for Flutter: https://firebase.google.com/docs/analytics/events?platform=flutter
