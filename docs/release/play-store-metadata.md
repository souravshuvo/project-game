# Play Store Metadata Package

Last updated: 2026-08-14

## App Identity

- Approved display name: Larder Labels
- ASO position: Brandable puzzle name with search terms handled in the short
  and full descriptions instead of keyword-stuffing the title.
- Package name: `com.childhood.larderlabels`
- Game slug: `larderlabels`
- Category: Game / Puzzle
- Default language: English (United States)
- Current version: `1.0.0+1`
- Developer name: Childhood
- Target audience draft: General puzzle-game audience. Do not mark as
  child-directed unless the full Families and children policy review is
  completed.

## Store Title

Larder Labels

Rejected title directions:

- Do not use competitor names.
- Do not use fake award, ranking, download, or review claims.
- Do not stuff generic terms into the title, such as "Triple Tile Match Puzzle
  Master".

## Short Description

Recommended:

Match pantry labels in calm triple-tile puzzles.

Alternates:

- Clear label tiles by matching three in the tray.
- Tidy triple-match puzzles with 50 offline levels.
- Choose free labels, fill the tray, and clear triples.

## Full Description Draft

Larder Labels is an original triple tile match puzzle about clearing tidy
pantry-label boards.

Choose free labels from the board and place them into the 7-slot tray. Three
matching labels clear automatically, but covered labels have to wait until the
tiles above them are removed. Plan the order carefully before the tray fills.

Play through 50 deterministic levels with simple one-touch controls, readable
tile states, restart, next-level flow, and local progress restoration. Levels
are available without login, cloud sync, shops, maps, story events, or extra
game modes.

Current v1 features:

- One simple triple-match puzzle mode
- 50 deterministic pantry-label levels
- Original text-label tile set: Jar, Note, Tin, Flour, Tea, Seed, Honey,
  Ribbon, Oat, and Cocoa
- Layered tiles with clear covered and selectable states
- 7-slot tray with automatic triple clearing
- Win, fail, restart, pause, help, settings, and progress restoration
- Ads only at capped level-end transitions when enabled, never during active
  puzzle play

## Keywords To Use Carefully

- triple tile match
- tile match puzzle
- matching game
- offline levels
- casual puzzle

Avoid copying competitor names or repeating keywords unnaturally.

## Screenshot Storyboard

Use only real screens captured from the current app. Do not show unavailable
boosters, maps, shops, events, rewards, rankings, fake reviews, fake ratings,
fake downloads, or removed legacy-game assets.

1. Home screen: `Larder Labels`, Play or Continue button, Help and Settings,
   and visible 50-level/progress messaging.
2. Fresh gameplay: Level 1 board with HUD, message bar, selectable label tiles,
   and empty 7-slot tray.
3. Tray action: a real mid-level moment with two or three labels in the tray
   and the next tap about to make a triple.
4. Layering clarity: a real layered level with covered tiles dimmed and the
   layer indicator visible.
5. Tray pressure: a real near-full tray state showing the Careful warning, only
   if the level still looks fair and readable.
6. Result state: a real win panel with moves and Next or Restart visible.
7. Optional fail state: a real tray-full state with Restart visible, only if the
   screenshot teaches the rule clearly.

Screenshot production rules:

- Capture actual gameplay from the release candidate build only.
- Keep captions truthful and short if text overlays are added externally.
- Do not place store marketing text over UI that needs to be read.
- Do not include debug banners, emulator artifacts, device controls, or
  development-only UI.
- Do not include ads in screenshots unless intentionally documenting a real,
  policy-compliant level-end transition.

## Feature Graphic Brief

Create an original static graphic using the Larder Labels title and the actual
v1 label-tile visual language. Recommended composition:

- Clean pantry-board background using the app palette: soft green canvas,
  white tile surfaces, teal ink, coral warning accent, and amber highlight.
- A small cluster of readable label tiles using real tile text such as `JAR`,
  `TEA`, `OAT`, `TIN`, and `HNY`.
- One subtle tray strip with three matching labels clearing, represented as a
  still composition rather than fake gameplay.
- No boosters, coins, shop, map, story characters, fake prizes, fake rankings,
  fake reviews, or competitor-like tile symbols.

## App Icon Brief

Use a simple original icon that remains readable at small sizes:

- Background: soft green or white label-card surface.
- Foreground: three small overlapping pantry labels or one bold label tile.
- Text marks may use short in-game labels such as `JAR`, `TEA`, or `OAT`.
- Optional tiny teal/coral accent to echo the app palette.
- Avoid screenshots, dense board layouts, mahjong-like symbols, copied icons,
  characters, store badges, fake notification dots, or competitor-style marks.

## Preview Video Script

Use real gameplay capture only. Do not render fake levels, fake boosters, fake
rewards, fake ratings, fake progression, or unavailable modes.

1. 0-3s: Open on the real home screen with the Larder Labels title and Play
   button.
2. 3-8s: Show Level 1. Tap three matching free labels and let the tray clear.
3. 8-13s: Show a layered level. Tap a top label, then reveal a covered label
   becoming selectable.
4. 13-18s: Show tray pressure with several occupied slots and the Careful
   warning, then make a valid triple.
5. 18-23s: Show a real win state with moves and the Next action.
6. 23-27s: End on the current title/home or win screen. Optional caption:
   "Match three labels. Clear the shelf."

Audio guidance:

- Use actual app feedback if captured clearly.
- Do not imply music, characters, rewards, modes, or effects that are not in
  the current app.

## Play Console Upload Checklist

- Confirm package name `com.childhood.larderlabels` is final before first
  upload.
- Upload only screenshots captured from the current release candidate.
- Replace any legacy app screenshots, icons, splash art, or store copy.
- Regenerate launcher icons from the final Larder Labels icon artwork.
- Add the feature graphic created from current v1 visuals only.
- Complete app category, tags, content rating, target audience, app access,
  ads declaration, and Data safety forms.
- Host and link a privacy policy that matches the actual AdMob/Firebase
  Analytics behavior.
- Confirm production ad IDs and test/prod separation before any production
  rollout.
- Confirm release signing, version code, target API level, tests, analysis, and
  at least one physical-device smoke test before closed testing.
- Do not publish from this checklist alone; use internal testing first.

## Review Notes Draft

No login is required. The current version does not include account creation,
purchases, cloud sync, live events, shop, map progression, story, or extra game
modes. Ads, when enabled, are capped to level-end transitions and must not be
shown during active puzzle play. All current puzzle content is available
through the single local play flow.

## Remaining Store Risks

- Final screenshots have not been captured from a release candidate.
- Final launcher icon and feature graphic assets are still pending.
- Build, analyze, tests, signing, and Play Console upload checks were skipped
  during this P5 pass.
- Data safety and ads declarations must match the final SDK configuration.
