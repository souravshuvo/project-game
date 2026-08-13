# Sixteen Breed

Sixteen Breed is an offline Flutter Sholo Guti / 16 Beads game.

## Production V1 Scope

- Local two-player mode.
- Player vs Bot mode with Easy, Balanced, and Sharp difficulties.
- Validated 37-node board graph.
- 16 beads per player.
- Legal move and capture highlighting.
- Optional multi-capture chains.
- Capture-all, blocked-player, repetition, and no-capture-limit results.
- Tap and drag board controls with forgiving hit targets.
- Lightweight system sound and haptic feedback with in-session toggles.
- Pause, help, restart, settings, and match result flows.
- Restorable local match history for the latest 20 completed matches.
- AdMob interstitials only after completed matches, with frequency caps.
- Firebase Analytics event hooks for gameplay, difficulty, retention, and ad
  impact.
- No online play, shop, leaderboard, login, cloud sync, or chat.

## Ads and Analytics

- Ads use Google Mobile Ads test IDs by default.
- Production interstitial ad unit IDs are supplied with:
  - `--dart-define=AD_ENVIRONMENT=production`
  - `--dart-define=ADMOB_ANDROID_INTERSTITIAL_ID=...`
  - `--dart-define=ADMOB_IOS_INTERSTITIAL_ID=...`
- Android AdMob app ID defaults to Google's test app ID and can be overridden
  with Gradle property or environment variable `ADMOB_ANDROID_APP_ID`.
- iOS AdMob app ID defaults to Google's test app ID in
  `ios/Flutter/*.xcconfig`; replace it with the production app ID before store
  release.
- Interstitial ads are eligible only after match end and after the result
  animation delay.
- Frequency cap: at least 2 completed matches and at least 8 minutes between
  shown interstitials.
- Ad load/show failure is non-blocking and should never prevent gameplay,
  rematch, home, or history navigation.
- Rewarded ads and banner ads are not enabled in this version because hints,
  undo packs, and cosmetic rewards are not implemented yet.
- Firebase Analytics initializes only when Firebase platform configuration is
  present. If Firebase config is missing, gameplay continues with analytics
  disabled.
- Before production release, configure Firebase for this exact package name
  (`com.childhood.sixteenbreed`) and add the generated platform files.

## Data Safety Notes

- The app has no login, account, chat, cloud save, or online multiplayer.
- AdMob may collect device, app activity, diagnostics, advertising ID, and ad
  interaction data according to Google Mobile Ads SDK behavior.
- Firebase Analytics may collect app activity, app interactions, diagnostics,
  device identifiers, and session data when Firebase is configured.
- Android includes `INTERNET` and `ACCESS_NETWORK_STATE` permissions for ads
  and analytics.
- Local match history is stored on device through Flutter restoration and is not
  uploaded by this app.
- Do not claim analytics/ad collection is absent in Play Data safety once P4 is
  included.

## Release Notes

Release signing is configured to read `android/key.properties`. Copy
`android/key.properties.example` to `android/key.properties` locally and point
`storeFile` at your private upload keystore. Never commit the real keystore or
real passwords.

## Manual QA

1. Open the app and confirm the launcher/app label is `Sixteen Breed`.
2. Start `Local 2 Player`.
3. Confirm the board has 37 intersections, 16 beads per player, and five empty
   center nodes.
4. Select beads and confirm legal moves and captures highlight before commit.
5. Drag a bead to a highlighted point and confirm the same move is accepted.
6. Tap an invalid point and confirm visual plus sound/haptic invalid feedback.
7. Make normal moves, capture moves, and optional multi-capture chains.
8. Confirm `End Turn` appears only during a capture chain.
9. Open `Help`, `Pause`, and `Settings` from the match screen.
10. Toggle sound and haptics off and confirm gameplay continues normally.
11. Start `Player vs Bot` on each difficulty and confirm the bot only makes
    legal highlighted moves.
12. Confirm Easy may stop after one optional capture, while Balanced and Sharp
    continue available capture chains.
13. Confirm capture-all and blocked-player wins.
14. Confirm result animation, `Rematch`, `Home`, and restart reset the board.
15. Finish matches and confirm `History` records mode, result, moves, captures,
    and remaining bead counts.
16. Complete two matches and confirm any interstitial appears only after match
    completion, never during turn selection, bot thinking, move animation,
    capture chain, or result animation.
