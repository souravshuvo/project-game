# AdMob and Analytics Data Safety Notes

## Placements

- `home_footer` banner: appears below the Home game grid only.
- `completed_game_home_return` interstitial: considered only after a game reports completion and the route returns to Home.
- Play Next / continue-to-next-game actions do not create an interstitial opportunity.
- No ads are requested from active gameplay screens.
- No rewarded, app-open, native, or gameplay-overlay ads are implemented.

## Frequency Caps

Interstitial ads are capped by `InterstitialFrequencyCap`:

- First interstitial requires 2 completed game sessions.
- Later interstitials require 2 more completed game sessions.
- Minimum interval between interstitial shows is 4 minutes.
- Maximum interstitials per app session is 3.

If an ad is not loaded, fails to load, or fails to show, gameplay continues and the app records a non-blocking analytics event.

The interstitial controller also blocks duplicate full-screen attempts while another interstitial is showing.

## Test and Production Separation

Debug/test mode uses Google sample ad IDs. Release builds disable ads when `ADMOB_MODE=test`, so a production artifact should not accidentally serve test ad units.

Production ad serving requires:

- `ADMOB_MODE=production`
- Platform banner and interstitial ad unit Dart defines.
- Real Android/iOS AdMob app IDs in native configuration. Android reads `ADMOB_ANDROID_APP_ID` from a Gradle property or environment variable; iOS must replace the sample `GADApplicationIdentifier` before production upload.
- Final child-directed/Families policy review before upload.
- Android network permissions `INTERNET` and `ACCESS_NETWORK_STATE`.

Ad requests set max ad content rating to `G` and use child age treatment in the Google Mobile Ads request configuration.

## Analytics Events

The app logs event names and bounded parameters only. Event names and parameter names are normalized for Firebase-compatible characters and length.

Firebase consent defaults deny ad storage, ad personalization signals, and ad user data while allowing analytics storage for the configured gameplay events.

Implemented event areas:

- App retention: `app_session_start`, `app_lifecycle`, `app_session_end`
- Gameplay: `game_start`, `game_complete`, `game_exit`, `game_flow_action`
- Content/difficulty: `content_start`, `content_complete`, `game_feedback`, catalog `content_total`, catalog `difficulty_tier`
- Parent/settings: `parent_gate_result`, `settings_open`, `settings_change`, `progress_reset`
- Ad impact: `ad_opportunity`, `ad_init`, `ad_load`, `ad_show`, `ad_impression`, `ad_click`, `ad_dismiss`, `ad_error`, `ad_paid`

Ad opportunity analytics include the source game, game duration, progress totals, frequency-cap state, and decision reason. Paid ad callbacks record currency, value in micros, and precision when the SDK provides them.

The app must not send child names, profiles, raw touch coordinates, drawings, free text, precise timestamps, location, camera, microphone, contacts, or account identifiers.

## Play Data Safety Review Items

Review the final SDK versions and generated release artifact before upload. The Data safety form and privacy policy should account for:

- Firebase Analytics app interaction events.
- Google Mobile Ads ad events, impressions, clicks, diagnostics, and any identifiers used by Google SDKs.
- Child-directed ad request configuration and max ad content rating.
- No account system and no child profile.
- Local Hive progress and settings storage.
- Disabled Android backup/device transfer rules for app data.

Crash monitoring is still not implemented in this P4 pass.
