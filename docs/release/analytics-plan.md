# Privacy-Safe Analytics Plan

Last updated: 2026-08-12

## Current Decision

Use Firebase Analytics when real Firebase configuration is supplied at build time; otherwise analytics falls back to the existing no-op boundary.

Reason: P4 requires production-safe analytics, but the repository should not ship placeholder Firebase IDs or crash when Firebase has not been configured yet.

## Current Implementation

The app has a telemetry boundary:

- `lib/features/tic_tac_toe/application/tic_tac_toe_telemetry.dart`
- Firebase adapter: `lib/features/tic_tac_toe/data/firebase_tic_tac_toe_telemetry.dart`
- Default fallback: `NoOpTicTacToeTelemetry`

Firebase Analytics is enabled only when all required Dart defines are present:

- `FIREBASE_API_KEY`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_ANDROID_APP_ID` for Android builds
- `FIREBASE_IOS_APP_ID` for iOS builds

If any value is missing, analytics is disabled and gameplay continues.

## Implemented Events

- `app_opened`
- `app_session_started`
- `mode_selected`
- `match_format_selected`
- `round_started`
- `move_made`
- `invalid_cell_tapped`
- `round_ended`
- `match_completed`
- `rematch_tapped`
- `score_reset`
- `settings_changed`
- `ad_sdk_initialized`
- `ad_sdk_initialization_failed`
- `ad_load_started`
- `ad_loaded`
- `ad_load_failed`
- `ad_skipped`
- `ad_show_attempted`
- `ad_shown`
- `ad_dismissed`
- `ad_show_failed`

Suggested event properties:

- `mode`
- `match_format`
- `round_number`
- `move_index`
- `cell_index`
- `player_type`
- `ai_difficulty`
- `result`
- `winner_type`
- `move_count`
- `rounds_played`
- `x_wins`
- `o_wins`
- `draws`
- `open_count`
- `days_since_first_open`
- `days_since_previous_open`
- `placement`
- `ad_format`
- `uses_test_ads`
- `reason`
- `error_code`
- `setting_name`
- `enabled`

Do not collect names, emails, precise location, contacts, photos, free-text input, or unrelated device data.

## Before Production Analytics

- Update `docs/release/privacy-and-data-safety.md`.
- Update the hosted privacy policy.
- Update Play Console Data safety.
- Re-check permissions and generated manifests.
- Confirm SDK behavior from vendor documentation.
- Decide whether consent, opt-out, or regional handling is needed.
- Verify Firebase DebugView receives events from a test build.
- Confirm analytics remains disabled when Dart defines are omitted.
