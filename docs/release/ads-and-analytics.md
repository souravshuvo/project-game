# Ads And Analytics Setup

## AdMob Defaults

- The app uses Google Mobile Ads test ad units by default.
- Production ad units are enabled only with `--dart-define=TRAIL_ARENA_PROD_ADS=true`.
- Android production ad unit IDs:
  - `TRAIL_ARENA_ANDROID_BANNER_AD_UNIT_ID`
  - `TRAIL_ARENA_ANDROID_INTERSTITIAL_AD_UNIT_ID`
- iOS production ad unit IDs:
  - `TRAIL_ARENA_IOS_BANNER_AD_UNIT_ID`
  - `TRAIL_ARENA_IOS_INTERSTITIAL_AD_UNIT_ID`
- Android app ID uses the Gradle property `TRAIL_ARENA_ADMOB_APP_ID`.
- iOS app ID uses `GAD_APPLICATION_IDENTIFIER` in `ios/Flutter/*.xcconfig`.
- Keep test IDs until the AdMob app is approved and release QA is complete.

## Placements

- Banner: main menu.
- Banner: game-over result screen.
- Interstitial: only after game over when the player taps retry or menu.
- No ad placement is allowed during active gameplay, ready countdown, or pause.

## Interstitial Frequency Caps

- Minimum 3 completed runs since the previous interstitial.
- Minimum 20-second run length.
- Minimum 2 minutes between interstitials.
- If loading or showing fails, gameplay/navigation continues without blocking.

## Analytics Events

- App and retention: `app_open`, `screen_view`.
- Gameplay: `game_run_start`, `game_run_end`, `game_pause`, `game_resume`.
- Difficulty: `game_difficulty_phase`.
- Actions: `game_food_collect`, `game_bot_crash`, `game_goal_complete`.
- Settings/help: `settings_open`, `settings_changed`, `help_open`.
- Ads: `ad_sdk_initialized`, `ad_sdk_init_failed`, `ad_banner_disabled`,
  `ad_banner_sdk_init_failed`, `ad_banner_loaded`, `ad_banner_load_failed`,
  `ad_banner_impression`, `ad_banner_click`, `game_run_complete_for_ads`,
  `ad_interstitial_disabled`, `ad_interstitial_loaded`,
  `ad_interstitial_load_failed`, `ad_interstitial_skipped`,
  `ad_interstitial_unavailable`, `ad_interstitial_show`,
  `ad_interstitial_show_failed`, `ad_interstitial_dismissed`,
  `ad_interstitial_impression`, `ad_interstitial_click`.

## Release Requirements

- Add Firebase config files before expecting analytics events to transmit.
- Confirm Firebase DebugView events on a real device.
- Complete consent/privacy review before using production ads.
- Update Data safety after final Firebase and AdMob settings are known.
