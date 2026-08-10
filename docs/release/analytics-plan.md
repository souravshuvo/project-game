# Privacy-Safe Analytics Plan

Last updated: 2026-08-10

## Current Decision

Do not add analytics SDKs in current v1.

Reason: Larder Labels is still validating the core puzzle loop, readable tile
state, level difficulty, and store-readiness. Adding analytics now would create
privacy and Data safety work before the product needs it.

## Current Implementation

No active analytics adapter exists in the current code. No event data is sent
anywhere.

## If Analytics Is Added Later

Only add analytics after deciding:

- Which product questions must be answered.
- Which events are required.
- Whether device identifiers or advertising IDs are collected.
- Whether consent, opt-out, or regional handling is needed.
- How the Play Console Data safety form and privacy policy must change.

## Candidate Events

Keep event names simple and avoid personal data:

| Event | Purpose |
| --- | --- |
| `app_open` | Basic launch signal |
| `level_start` | Level funnel entry |
| `tile_select` | Move count and tile-state behavior |
| `triple_clear` | Core satisfaction and pacing |
| `tray_depth_changed` | Tray pressure and difficulty |
| `covered_tile_tap` | Selectability clarity |
| `level_restart` | Frustration or replay signal |
| `level_fail` | Difficulty and fairness |
| `level_complete` | Completion and score |
| `session_end` | Session length |

Suggested event properties:

- `level_id`
- `level_number`
- `move_count`
- `tray_size`
- `tray_capacity`
- `remaining_tiles`
- `score`

Do not collect names, emails, precise location, contacts, photos, free-text
input, or unrelated device data.

## MVP Metrics

- Level 1 completion rate
- Level 1 fail/restart rate
- First five level completion rate
- Average moves per level
- Average tray high-water mark per level
- Covered-tile tap rate
- Day 1 return rate, only if analytics can be implemented with a compliant
  privacy setup

## Before Adding Any SDK

- Update `docs/release/privacy-and-data-safety.md`.
- Update the hosted privacy policy.
- Update Play Console Data safety.
- Re-check permissions and generated manifests.
- Confirm SDK behavior from the vendor documentation.
