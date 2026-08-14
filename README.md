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
- Debug/development ads use Google test IDs by default. Play-ready release
  builds should provide `ADMOB_APP_ID` plus production interstitial ad unit IDs.
- Play-ready release artifacts require `android/key.properties` with an upload
  key. Local release builds use debug signing when the file is missing.

## Android release signing

Local release builds may run without a private upload key by falling back to
debug signing. Play-ready release artifacts still need a private upload key.

1. Create or reuse an Android upload keystore.
2. Copy `android/key.properties.example` to `android/key.properties`.
3. Fill in `storePassword`, `keyPassword`, `keyAlias`, and `storeFile`.
4. Keep `android/key.properties` and the keystore file private.

For a Play release build, also pass a production AdMob app ID with
`ADMOB_APP_ID` or `-PADMOB_APP_ID=...`. If this is missing, the build uses
Google sample ad IDs for local testing only and is not Play-ready.
