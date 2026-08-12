# AdMob And Analytics Data Safety Notes

Emoji Chor Police uses Google Mobile Ads and an analytics service layer.

## Current Implementation

- Banner ads are allowed only on non-gameplay screens: menu, help, settings, progress, and final match summary.
- Interstitial ads are allowed only after a completed match, when the player taps Play again from the match summary.
- Interstitial caps:
  - no interstitial before 2 completed matches,
  - at least 3 completed matches between interstitials,
  - at least 4 minutes between interstitials.
- Ad load/show failure is non-blocking and returns the player to the normal flow.
- Ad requests use non-personalized ads by default.
- AdMob test IDs are the default. Production ad unit IDs must be provided through dart defines.
- The Android AdMob application ID defaults to Google's test app ID. Production builds must provide `ADMOB_APPLICATION_ID` as a Gradle property.
- Firebase Analytics is used when Firebase app config exists. If config is missing, events fall back to a local in-session analytics sink.

## Production Ad Configuration

Use test ads during development. For production, provide real IDs without committing them:

- `--dart-define=ADMOB_USE_TEST_ADS=false`
- `--dart-define=ADMOB_ANDROID_BANNER_ID=<real_banner_unit_id>`
- `--dart-define=ADMOB_ANDROID_INTERSTITIAL_ID=<real_interstitial_unit_id>`
- Gradle property `ADMOB_APPLICATION_ID=<real_android_app_id>`

If a production ID is missing while `ADMOB_USE_TEST_ADS=false`, that placement does not load and gameplay continues normally.

## Analytics Events

The app logs gameplay and monetization events such as:

- `session_start`
- `app_start`
- `match_start`
- `round_start`
- `role_revealed`
- `police_reveal`
- `human_accusation_submitted`
- `bot_accusation_submitted`
- `round_finish`
- `match_finish`
- `challenge_unlocked`
- `progress_open`
- `settings_open`
- `help_open`
- `ad_sdk_initialized`
- `ad_sdk_init_failed`
- `ad_banner_load_requested`
- `ad_banner_loaded`
- `ad_banner_load_failed`
- `ad_banner_impression`
- `ad_banner_clicked`
- `ad_interstitial_load_requested`
- `ad_interstitial_loaded`
- `ad_interstitial_load_failed`
- `ad_interstitial_capped`
- `ad_interstitial_unavailable`
- `ad_interstitial_show`
- `ad_interstitial_impression`
- `ad_interstitial_clicked`
- `ad_interstitial_dismissed`
- `ad_interstitial_show_failed`
- `ad_paid_event`

## Play Console Data Safety Impact

Before release, verify the Data safety form against the final SDK behavior and policies:

- Ads may collect device identifiers, coarse diagnostics, ad interactions, and approximate location depending on Google Mobile Ads SDK behavior and consent state.
- Analytics may collect app interactions, session activity, gameplay settings, match outcome metrics, ad impact events, and diagnostics.
- The game should not collect names, email addresses, account data, contacts, photos, chat, financial data, or precise location.
- No gameplay event should include real-world personal identifiers.
- Update this note if Firebase remote analytics, consent management, or additional SDKs are added.
