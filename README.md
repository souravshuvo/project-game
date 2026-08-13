# Pencil Pitch

Pencil Pitch is an offline pen cricket spinner game built with Flutter. Version 1 focuses on quick, family-friendly practice innings and target chases with clear cricket scoring.

## Current v1 scope

- Main menu
- 3 match presets: Pocket Over, Notebook Classic, and Long Page
- Practice innings
- Target chase
- 24 offline challenge ladder missions
- Restored local progress for completed challenges, best scores, chase wins, and recent match history
- Tap-to-spin and tap-to-stop spinner
- Runs, wickets, legal balls, overs, extras, and target display
- Wide and no-ball extras without consuming legal deliveries
- Innings end and match result
- Restart and menu return
- How-to-play help and in-match hints
- Clear match result summary panel
- Score/result animation feedback
- Basic sound and haptics settings
- Production-safe AdMob placements on menu, result, and capped match-end breaks
- Firebase Analytics event hooks for gameplay, challenge difficulty, retention, and ad impact
- No shop, login, leaderboard, cloud sync, or online play

## Manual QA checklist

1. Open the app and confirm the title is Pencil Pitch.
2. Select each match preset and confirm Practice innings uses the selected over/wicket limits.
3. Confirm wides and no-balls add 1 extra without advancing balls.
4. Restart from a completed practice innings.
5. Start Target chase and complete the first innings.
6. Confirm the target is first-innings score + 1.
7. Start the chase and confirm win, tie, and defended results across repeated plays.
8. Tap rapidly during spin, settling, and result feedback; confirm scoring happens once per delivery.
9. Confirm menu/restart/start-chase controls are disabled during delivery feedback.
10. Check phone-sized and landscape layouts for readable score and spinner labels.
11. Toggle Sound and Haptics off and confirm built-in feedback is muted.
12. Open How to play from the menu and match header; confirm the first action is clear.
13. Open Challenge ladder, confirm only the next unfinished challenge is unlocked, and complete First Scribble.
14. Return to the menu and confirm Progress updates match count, completed challenge count, and recent history.
15. Confirm banner ads are absent during active deliveries and only appear on menu or idle match-result state.
16. Complete two matches and confirm any interstitial appears only after the result animation, never while the spinner is active.
17. Disable network or force ad load failure; confirm gameplay, restart, menu, and scoring still work.

## Release notes

Android release signing expects `android/key.properties`, based on `android/key.properties.example`. Do not commit signing secrets or keystore files.

AdMob uses Google test IDs by default. For production Android builds, copy `android/admob.properties.example` to `android/admob.properties` and pass production ad unit IDs with Dart defines:

```shell
--dart-define=USE_TEST_ADS=false
--dart-define=ADMOB_ANDROID_BANNER_ID=ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB
--dart-define=ADMOB_ANDROID_INTERSTITIAL_ID=ca-app-pub-XXXXXXXXXXXXXXXX/IIIIIIIIII
```

For iOS, replace `ADMOB_IOS_APP_ID` in the release xcconfig or provide it from CI, and pass:

```shell
--dart-define=USE_TEST_ADS=false
--dart-define=ADMOB_IOS_BANNER_ID=ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB
--dart-define=ADMOB_IOS_INTERSTITIAL_ID=ca-app-pub-XXXXXXXXXXXXXXXX/IIIIIIIIII
```

Firebase Analytics is optional at runtime and fails closed when Firebase config is missing. Production analytics requires the app's Firebase configuration before release.

## Data safety notes

- Ads/analytics SDKs may collect device identifiers, diagnostics, approximate interaction events, and ad performance data.
- The app does not add login, user-generated content, online multiplayer, or cloud game saves in v1.
- Interstitials are frequency capped and only attempted after match end or safe breaks.
