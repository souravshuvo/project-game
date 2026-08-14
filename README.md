# Larder Labels

An original offline Flutter triple tile match puzzle.

## Version 1 Scope

- 50 deterministic offline pantry-label levels.
- The first five levels are handcrafted starters; later levels use simple
  original templates that ramp tile count and layering.
- Tap uncovered label tiles to move them into a 7-slot tray.
- Three matching labels clear automatically.
- Higher-layer tiles block lower tiles in the same board cell.
- Win when every tile is cleared.
- Fail when the tray is full after match resolution.
- Restart resets the current level deterministically.
- Next advances through the local level pack after a win.
- Built-in Flutter restoration keeps current level and completion progress on
  device without adding a storage SDK.
- Production-safe AdMob interstitial integration is limited to capped level-end
  transitions and defaults to Google test ads.
- Firebase Analytics events are logged only when Firebase is configured; missing
  config safely falls back to no-op analytics.

Version 1 does not include boosters, shop, login, cloud sync, map progression,
story, live events, purchases, or rewarded-ad features.

## Originality Notes

The current theme, tile names, layout data, and placeholder visuals are original
to this repository. Do not copy names, art, UI, icons, screenshots, tile sets,
level layouts, boosters, characters, music, or branding from existing triple
match, tile match, mahjong-style, or puzzle apps.

## Manual QA Focus

1. Launch a fresh install.
2. Confirm the first screen clearly offers Play, Help, and Settings.
3. Tap three matching labels and confirm the tray clears that triple.
4. Tap a covered lower-layer tile and confirm it does not move until the top
   tile is cleared.
5. Fill the tray with non-matching labels and confirm fail messaging is clear.
6. Use Restart and confirm board, tray, moves, score, and status reset.
7. Complete the first 10 levels using the in-app Next button after each win.
8. Confirm interstitial test ads can appear only after capped level-end
   transitions, never during active puzzle play.
9. Confirm no login, shop, rewarded ad feature, or unavailable feature appears.
