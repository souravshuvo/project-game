# Larder Labels

An original offline Flutter triple tile match puzzle prototype.

## Version 1 Scope

- Five small handcrafted pantry-label levels.
- Tap uncovered label tiles to move them into a 7-slot tray.
- Three matching labels clear automatically.
- Higher-layer tiles block lower tiles in the same board cell.
- Win when every tile is cleared.
- Fail when the tray is full after match resolution.
- Restart resets the current level deterministically.
- Next advances through the session-only local level pack after a win.

Version 1 does not include ads, boosters, shop, login, cloud sync, map
progression, story, live events, analytics, Firebase, AdMob, purchases, or
external services.

## Originality Notes

The current theme, tile names, layout data, and placeholder visuals are original
to this repository. Do not copy names, art, UI, icons, screenshots, tile sets,
level layouts, boosters, characters, music, or branding from existing triple
match, tile match, mahjong-style, or puzzle apps.

## Manual QA Focus

1. Launch a fresh install.
2. Confirm the first screen is the playable puzzle, not a landing page.
3. Tap three matching labels and confirm the tray clears that triple.
4. Tap a covered lower-layer tile and confirm it does not move until the top
   tile is cleared.
5. Fill the tray with non-matching labels and confirm fail messaging is clear.
6. Use Restart and confirm board, tray, moves, score, and status reset.
7. Complete all five levels using the in-app Next button after each win.
8. Confirm no ads, network prompts, login, shop, or unavailable features appear.
