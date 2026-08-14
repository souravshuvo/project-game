# Privacy-Safe Analytics Plan

Last updated: 2026-08-14

## Current Decision

Firebase Analytics integration is implemented for production-safe testing.

Reason: the game now needs level difficulty, retention, and ad-impact evidence
before production release. Analytics is initialized only when Firebase is
configured; missing Firebase config safely falls back to no-op analytics.

## Current Implementation

Active analytics adapter:

- `FirebaseAnalyticsService` initializes Firebase Analytics when Firebase config
  is present.
- `NoopAnalyticsService` is used if analytics is disabled or Firebase init
  fails.
- `ANALYTICS_ENABLED=false` disables analytics through dart-define.
- Real Firebase apps/config must be added before production analytics can be
  verified. Do not commit placeholder Firebase config.

## Events

Keep event names simple and avoid personal data:

| Event | Purpose |
| --- | --- |
| `app_open` | Basic launch signal |
| `level_start` | Level funnel entry |
| `tile_select` | Move count and tile-state behavior |
| `triple_clear` | Core satisfaction and pacing |
| `tray_warning` | Tray pressure and difficulty |
| `covered_tile_tap` | Selectability clarity |
| `level_restart` | Frustration or replay signal |
| `level_fail` | Difficulty and fairness |
| `level_complete` | Completion and score |
| `settings_change` | Sound/haptic preference changes |
| `screen_view` | Home/game/help/settings flow |
| `ad_sdk_init` | Ad SDK readiness |
| `ad_sdk_init_failed` | Ad SDK startup failure |
| `ad_request` | Interstitial loading attempt |
| `ad_loaded` | Interstitial load success |
| `ad_load_failed` | Interstitial load failure |
| `ad_capped` | Frequency/policy cap result |
| `ad_show_attempt` | Interstitial show attempt |
| `ad_show` | Interstitial show success |
| `ad_impression` | Interstitial impression |
| `ad_show_failed` | Interstitial show failure |
| `ad_unavailable` | Safe ad fallback reason |

Suggested event properties:

- `level_id`
- `level_number`
- `move_count`
- `tray_size`
- `tray_capacity`
- `remaining_tiles`
- `score`
- `tray_high_water`
- `ad_environment`
- `placement`
- non-PII failure reason/code where available

Do not collect names, emails, precise location, contacts, photos, free-text
input, or unrelated device data.

## MVP Metrics

- Level 1 completion rate
- Level 1 fail/restart rate
- First 10 level completion rate
- Full 50-level completion rate
- Average moves per level
- Average tray high-water mark per level
- Covered-tile tap rate
- Day 1 return rate, only if analytics can be implemented with a compliant
  privacy setup

## Before Release

- Update `docs/release/privacy-and-data-safety.md`.
- Update the hosted privacy policy.
- Update Play Console Data safety.
- Re-check permissions and generated manifests.
- Confirm SDK behavior from the vendor documentation.
- Verify Firebase DebugView with real Firebase config.
