# Magnetic Marbles

Original Flutter crowd-control arcade game.

## Manual test

1. Start the Flutter app.
2. Tap **Continue**.
3. Hold and drag on the playfield to launch marbles.
4. Steer through math gates and grow the marble crowd.
5. Let the crowd collide with enemy clusters.
6. Confirm win, lose, retry, next-level, unlock, and level-select flow across
   the 30 v1 levels.

## Release notes

- Core levels are playable offline.
- Version 1 includes 30 offline levels with local unlock, score, and star
  progress on Android.
- Ads never appear during active gameplay. Interstitial ads are limited to
  natural level-end transitions and protected by frequency caps.
- Analytics records gameplay, difficulty, progression, retention, and ad-impact
  events when Firebase is configured.
- No shop, login, leaderboard, cloud sync, or live events are included.
- Android package name: `com.childhood.magneticmarbles`.
- Debug/development ads use Google test IDs by default. Production release
  builds must provide `ADMOB_APP_ID` plus production interstitial ad unit IDs.
- Release signing requires `android/key.properties` with an upload key before
  building a Play artifact.
