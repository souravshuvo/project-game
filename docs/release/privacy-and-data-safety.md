# Privacy And Data Safety Notes

Trail Arena v1 is offline gameplay, but now includes AdMob and Firebase
Analytics SDK integration for ads and event measurement. It does not include
login, cloud sync, purchases, location, camera, microphone, contacts, or
multiplayer.

Current data behavior:

- Stores best score, games played, settings, and completed Trail Goals locally
  with `shared_preferences`.
- Sends gameplay, difficulty, goal-completion, settings, retention, and ad
  lifecycle events through Firebase Analytics when Firebase is configured.
- Requests AdMob banners on menu/game-over surfaces and capped interstitials
  only at game-over retry/menu transitions.
- Uses non-personalized ad requests by default.
- Uses debug/profile internet permission only for Flutter development tooling.
- Main release manifest declares internet permission for ads and analytics.

Play Console guidance:

- Ads declaration: `Yes`.
- Data collection: analytics/ad SDK data collection must be declared based on
  the final Firebase and AdMob configuration.
- Privacy policy is required and must describe ads, analytics, local progress
  storage, non-personalized ad defaults, and any consent flow used for target
  regions.
- Update this document before adding personalized ads, crash reporting, cloud
  sync, account features, purchases, or rewarded value.
