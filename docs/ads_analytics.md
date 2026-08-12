# Ads and Analytics Notes

## AdMob

- Active gameplay has no ads.
- Interstitials may show only after a level has ended and the player chooses
  Retry, Next, or Home from the result screen.
- Development builds use Google sample test IDs by default.
- Production releases must provide:
  - Gradle property or environment variable `ADMOB_APP_ID`
  - Dart define `USE_PRODUCTION_ADS=true`
  - Dart define `ADMOB_ANDROID_INTERSTITIAL_ID=<production-ad-unit-id>`
- Frequency caps:
  - No interstitial before at least 2 finished level transitions.
  - At least 3 finished level transitions between interstitials.
  - At least 180 seconds between interstitials.
  - Maximum 8 interstitials per app session.
- Ad load or show failure is non-blocking and continues the player action.

## Analytics

Firebase Analytics is used when Firebase is configured. If Firebase is missing
or fails to initialize, the game falls back to no-op analytics so gameplay still
works.

For Android production analytics, add the Firebase `google-services.json` file
to `android/app/`. The Google Services Gradle plugin is applied only when that
file exists.

Tracked event areas:

- Retention: `app_open`, `screen_view`
- Gameplay and difficulty: `level_start`, `level_restart`, `level_win`,
  `level_lose`, `gate_selected`, `enemy_collision`, `enemy_cleared`,
  `reserve_empty`, `crowd_zero`
- Progression: `level_start_requested`, `progress_saved`, `level_select_open`
- Settings/help: `settings_changed`, `help_open`, `game_overlay_open`
- Ad impact: `ads_initialized`, `ads_initialize_failed`,
  `ad_interstitial_request`, `ad_interstitial_loaded`,
  `ad_interstitial_load_failed`, `ad_interstitial_skipped`,
  `ad_interstitial_show`, `ad_interstitial_dismissed`,
  `ad_interstitial_show_failed`

## Data Safety Impact

- Network access is used for AdMob and Firebase Analytics.
- Advertising ID/device identifiers may be processed by AdMob/Firebase SDKs
  depending on Google services configuration and user/device settings.
- Approximate gameplay/progression/ad interaction events may be collected when
  Firebase is configured.
- No login, account, leaderboard, cloud sync, shop, or user-generated content is
  included in V1.
- No ads reward clicks, and no ads appear during active gameplay.
