# Play Store Metadata And Creative Package

Last updated: 2026-08-11

## App Identity

- Approved Play Store title: `Arrow Puzzle: Tap Puzzle Game`
- In-app display name: `Arrow Puzzle`
- Package name: `com.childhood.arrowpuzzle`
- Category: Game / Puzzle
- Default language: English (United States)
- Current version: `1.0.0+1`
- Developer name: Childhood
- Target audience draft: General puzzle-game audience. Do not mark as child-directed unless the full Families/children policy review is completed.

Package-name check: PASS. Android application ID, Android namespace, and iOS bundle ID use the approved `com.childhood.<game_slug>` convention with slug `arrowpuzzle`.

## Short Description

Tap arrows in order across 60 handcrafted logic puzzle levels.

Character count: 62 / 80

## Full Description

Arrow Puzzle is a calm tap puzzle game where every arrow needs a clear path off the board.

Study each row and column, find the arrows that can escape, and clear the board in the right order. Early levels teach the basics, while later boards add wider grids, chained dependencies, and trickier paths.

Features:

- Simple one-touch arrow-clearing rules
- 60 original, solvable puzzle levels
- Gradual difficulty from quick 4x4 boards to denser late-game layouts
- Daily level and daily hint loop
- Hint, restart, pause, level select, sound, and haptic controls
- Best-move tracking and local progress
- No account required

Arrow Puzzle is designed for quick puzzle sessions, careful scanning, and satisfying board-clearing moments.

## Keywords To Use Carefully

- arrow puzzle
- tap puzzle
- logic puzzle
- board puzzle
- casual puzzle

Avoid keyword stuffing or repeating phrases unnaturally in the title, short description, or full description.

## Screenshot Plan

Existing files in `store_assets/screenshots/phone/` are not approved for upload yet. They were captured from the older 20-level build and are 1080 x 2400, which is taller than the current Google Play screenshot side-ratio rule allows. Recapture final screenshots from the current 60-level build at 1080 x 1920 portrait or another Play-compatible 9:16 size.

| Slot | Real app moment | Overlay copy | Alt text |
| --- | --- | --- | --- |
| 1 | Home screen with title, Continue, Level Select, daily level, and hint card | Clear arrows in order | Home screen for Arrow Puzzle with continue, level select, daily level, and hint options. |
| 2 | Level select from current 60-level build | 60 handcrafted levels | Level select screen showing puzzle progression and locked upcoming levels. |
| 3 | Early gameplay board before the first tap | Find clear paths | Gameplay board with arrows waiting to slide off open rows and columns. |
| 4 | A mid or late-game denser board | Plan each move | Larger arrow puzzle board with multiple directions and chained dependencies. |
| 5 | Hint highlight or pause/restart controls | Hints when you need them | Gameplay screen showing a highlighted hint and simple move tracking. |
| 6 | Level-complete screen with best moves, streak, Replay, and Next Level | Replay for better moves | Level-complete screen showing best moves, streak, replay, and next-level controls. |

Capture rules:

- Use real app UI only.
- Do not show fake progress, fake ratings, or unavailable modes.
- Do not show ads in screenshots.
- If showing later levels, capture real unlocked gameplay state or a reviewer-safe seeded local progress state that represents content available through normal progression.
- Clean the status bar before upload; no notifications, debug banners, or emulator clutter.

## Feature Graphic Brief

Current asset: `store_assets/feature_graphic/feature-graphic.png`

Status: Approved as a v1 concept, pending final visual QA before upload.

- Size: 1024 x 500
- Format: PNG generated as 24-bit RGB without alpha
- Direction: clean blue brand field, app mark, title, short value line, and a board-style arrow motif
- Copy: `Arrow Puzzle` and `Tap arrows. Clear the board.`
- Policy check: no fake rankings, awards, reviews, pricing, store badges, or unavailable features
- Alt text: Arrow Puzzle feature graphic with colorful arrow tiles and the text Tap arrows. Clear the board.

Optional improvement before upload: keep the graphic text as `Arrow Puzzle` even if the Play title is `Arrow Puzzle: Tap Puzzle Game`; the shorter text is easier to read at small sizes.

## App Icon Brief

Current launcher icon direction: rounded white puzzle board on a blue background with yellow arrow tiles and navy arrows.

Status: Approved as a v1 concept, pending a dedicated Google Play 512 x 512 export.

Strengths:

- Recognizable arrow-puzzle motif
- No text, badges, rankings, or price claims
- Matches the feature graphic and in-app color palette

Risks:

- The multi-arrow board may lose some detail at very small sizes.
- The repo has launcher icons, but a dedicated 512 x 512 Google Play store icon export should be prepared and checked for file size.

Preferred final icon concept: a simplified 2x2 board with one dominant yellow arrow tile and two supporting arrows on the same blue/white brand system.

Export requirements:

- 512 x 512 PNG
- 32-bit PNG with alpha
- Max 1024 KB
- No ranking, price, category, or promotional badges

## Preview Video Script

Recommendation: Create a short portrait gameplay video after final screenshots are recaptured. Keep ads disabled for capture with `--dart-define=ARROW_PUZZLE_ADS_ENABLED=false`.

Target length: 24 seconds

Orientation: Portrait 9:16, matching the phone gameplay experience

| Time | Real footage | On-screen text | Optional voiceover |
| --- | --- | --- | --- |
| 0-3s | Home screen, then tap Continue | Arrow Puzzle | A calm tap puzzle about clearing every arrow. |
| 3-8s | Early board, tap a valid arrow and watch it exit | Find clear paths | Look across rows and columns before you move. |
| 8-13s | A blocked arrow attempt or scan, then correct move | Plan the order | Some arrows open only after others escape. |
| 13-17s | Hint highlight on the board | Use hints when needed | Hints help without changing the puzzle goal. |
| 17-21s | Level select scrolling through real levels | 60 levels | Progress through a compact handcrafted level pack. |
| 21-24s | Level-complete screen with Next Level and Replay | Clear the board | Replay for better moves or continue the next puzzle. |

Video rules:

- Use only real gameplay capture.
- Do not show ads, fake ratings, fake reviews, fake leaderboard positions, or unavailable modes.
- Do not include "download now", "install now", "#1", "best", "top", or time-sensitive claims.
- Upload to YouTube with ads disabled and use the single video URL in Play Console.

## Review Notes Draft

No login is required. All current game content is available through normal gameplay progression. The app stores progress locally on-device.

The submitted production build may include AdMob, Firebase Analytics, and Crashlytics. Ads are not shown during active puzzle play. Rewarded hints are optional and grant a hint only after rewarded-ad completion. Complete Play Console Data safety, Ads, and privacy-policy declarations before upload.

## Final Play Console Upload Checklist

- [ ] Confirm Play title `Arrow Puzzle: Tap Puzzle Game` fits the 30-character title limit.
- [ ] Confirm package name `com.childhood.arrowpuzzle` is final before first upload.
- [ ] Host privacy policy and add support email.
- [ ] Complete Data safety, Ads, Target audience, Content rating, and App access declarations.
- [ ] Export dedicated 512 x 512 Google Play app icon.
- [ ] Recapture 4-6 phone screenshots from the current 60-level build at Play-compatible dimensions.
- [ ] Review screenshots for real UI, readable text, clean status bar, and no ads/debug banners.
- [ ] Upload feature graphic after final QA.
- [ ] Produce preview video only from real gameplay capture, with ads disabled.
- [ ] Verify all listing copy avoids unsupported claims, keyword stuffing, fake rankings, and calls to action.

## Official References

- Google Play store listing best practices: https://support.google.com/googleplay/android-developer/answer/13393723
- Google Play preview asset requirements: https://support.google.com/googleplay/android-developer/answer/9866151
