# Privacy-Safe Analytics Plan

Last updated: 2026-08-14

## Current Decision

Use Firebase Analytics for production builds once real Firebase app config is added. The adapter is safe to ship in test builds because it disables itself if Firebase initialization fails.

## Current Implementation

The app has a telemetry boundary and Firebase adapter:

- `lib/features/weather_sort/application/game_telemetry.dart`
- `lib/features/weather_sort/application/firebase_game_telemetry.dart`
- Default runtime adapter: `FirebaseGameTelemetry`
- Test/fallback adapter: `NoOpGameTelemetry`

`FirebaseGameTelemetry` buffers early events, maps reserved names such as `app_open` and `screen_view` to safe custom event names, and disables itself if Firebase is not configured. Set `WEATHER_SORT_ANALYTICS_ENABLED=false` to disable analytics at build time.

## Before Production Upload

Complete these items before production upload:

- Add real Firebase config files using the approved package `com.childhood.weatherlabsort`.
- Run `flutterfire configure` when dependency/network commands are approved.
- Verify events in Firebase DebugView.
- Update hosted privacy policy and Play Console Data safety.
- Confirm regional consent/opt-out handling for analytics and ads.

## Events

Keep event names simple and avoid personal data:

- `app_open`
- `screen_view`
- `level_start`
- `level_exit`
- `level_complete`
- `level_restart`
- `pour_valid`
- `pour_invalid`
- `undo_used`
- `settings_changed`
- `ad_init_complete`
- `ad_init_skipped`
- `ad_init_failed`
- `ad_load_start`
- `ad_load_complete`
- `ad_load_failed`
- `ad_opportunity`
- `ad_frequency_capped`
- `ad_skipped`
- `ad_show`
- `ad_dismissed`
- `ad_show_failed`
- `ad_show_timeout`

Suggested event properties:

- `level_id`
- `level_number`
- `move_count`
- `stars`
- `invalid_reason`
- `layers_moved`
- `placement`
- `format`
- `reason`

Do not collect names, emails, precise location, contacts, photos, free-text input, or unrelated device data.

## MVP Metrics

- Level 1 completion rate
- Level 1 retry rate
- Level 2 unlock rate
- Average moves per level
- Invalid move rate
- Undo use rate
- Day 1 return rate
- Ad opportunity-to-show rate
- Ad load failure rate
- Completion rate before and after interstitial exposure

## Official References

- Firebase Flutter setup: https://firebase.google.com/docs/flutter/setup
- Firebase Analytics events for Flutter: https://firebase.google.com/docs/analytics/events?platform=flutter
