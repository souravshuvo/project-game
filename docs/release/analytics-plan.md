# Privacy-Safe Analytics Plan

Last updated: 2026-08-10

## Current Decision

Do not add analytics SDKs in v1.

Reason: Pocket Observatory XO should validate correctness, readability, replay, and store fit before adding privacy and Data safety complexity.

## Current Implementation

The app has a no-op telemetry boundary:

- `lib/features/tic_tac_toe/application/tic_tac_toe_telemetry.dart`
- Default adapter: `NoOpTicTacToeTelemetry`

This boundary does not transmit data, does not add Firebase, and does not change the current Data safety draft.

## Candidate Events For Later

- `app_opened`
- `mode_selected`
- `round_started`
- `move_made`
- `invalid_cell_tapped`
- `round_ended`
- `rematch_tapped`
- `score_reset`
- `settings_changed`

Suggested event properties:

- `mode`
- `move_index`
- `cell_index`
- `player_type`
- `result`
- `winner_type`
- `move_count`
- `setting_name`
- `enabled`

Do not collect names, emails, precise location, contacts, photos, free-text input, or unrelated device data.

## Before Adding Any SDK

- Update `docs/release/privacy-and-data-safety.md`.
- Update the hosted privacy policy.
- Update Play Console Data safety.
- Re-check permissions and generated manifests.
- Confirm SDK behavior from vendor documentation.
- Decide whether consent, opt-out, or regional handling is needed.
