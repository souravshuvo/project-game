# Pencil Pitch Play Store Listing Package

Prompt P5 status: listing copy and creative briefs prepared from repository evidence only. Final feature graphic and Play Store app icon exports now exist; screenshot and preview-video production packages now exist; final screenshots and final video capture are not produced yet because real gameplay capture was not explicitly approved at that time.

## Confirmed Identity

- App launcher/display label in the repository: `Pencil Pitch`.
- Recommended Play Store title: `Pencil Pitch: Pen Cricket`.
- Rationale: original, readable, truthful, includes the core search phrase once, and avoids keyword stuffing.
- Final Android package name: `com.childhood.pencilpitch`.
- Final iOS bundle identifier: `com.childhood.pencilpitch`.
- Game slug: `pencilpitch`.
- Category recommendation: Game, Sports or Casual. Sports is the better fit if the store requires a single primary game category.

## Store Listing Copy

### Title

`Pencil Pitch: Pen Cricket`

### Short Description Options

1. `Spin, score, and chase targets in offline pen cricket.`
2. `A quick offline pen cricket spinner with challenges.`
3. `Classic pen cricket feel with fair spinner scoring.`

Recommended short description: `Spin, score, and chase targets in offline pen cricket.`

### Full Description

Pencil Pitch is a quick offline pen cricket game built around a fair tap-to-stop spinner. Play a short practice innings, set a target, chase it, and keep your local progress moving through simple offline challenges.

What you can play:

- Practice innings for quick scoring sessions.
- Target chase where the first innings sets the target.
- Three match presets: Pocket Over, Notebook Classic, and Long Page.
- 24 offline challenge ladder missions.
- Local progress with best scores, chase wins, and recent match history.
- Clear cricket scoring for runs, wickets, wides, no-balls, overs, innings, and match results.
- Sound and haptic toggles for lightweight feedback.

Pencil Pitch is built for short, family-friendly sessions. It does not include online play, betting, real teams, official leagues, player rosters, cloud sync, leaderboards, or live events.

Ads, when enabled, are designed for safe breaks such as menus and match results. Ads are not part of active spinner deliveries.

### Do Not Claim

- No official cricket league, team, tournament, player, or broadcaster affiliation.
- No online multiplayer.
- No real teams or player rosters.
- No tournaments, seasons, or live events.
- No fake rewards, rankings, ratings, awards, download counts, or earnings.
- No betting, gambling, fantasy sports, or prize claims.

## Screenshot Storyboard

Target format: portrait screenshots, 1080 x 1920 or higher, JPEG or 24-bit PNG without alpha. Capture real app screens only. Use short overlay text only if it does not cover the spinner, HUD, score, controls, or result panels.

| Slot | Real app moment to capture | Overlay copy | Alt text |
| --- | --- | --- | --- |
| 1 | Main menu showing title, match presets, practice, chase, challenge preview, progress, and settings toggles. | `Pick a quick match` | `Pencil Pitch main menu with practice, target chase, presets, progress, and challenge ladder.` |
| 2 | Spinner screen before or during a real spin, with the tap target and HUD visible. | `Tap to spin, tap to stop` | `Gameplay spinner screen with score, wickets, overs, and a large tap-to-stop wheel.` |
| 3 | Delivery result feedback after a real run, wide, no-ball, or wicket. | `Every ball is clear` | `Delivery result panel showing the outcome and updated cricket score.` |
| 4 | Target chase innings break or chase start with target visible. | `Set it, then chase it` | `Target chase screen showing the first innings target and chase controls.` |
| 5 | Challenge ladder sheet showing locked, unlocked, and completed offline missions. | `24 offline challenges` | `Challenge ladder with offline mission cards and local completion progress.` |
| 6 | Match result screen with final score, restart, and menu return. | `Finish and retry fast` | `Match complete screen with final score summary, restart, and menu actions.` |
| 7 | Progress panel with best score, chase wins, match count, and recent history. | `Track local progress` | `Local progress section with best practice score, chase wins, matches, and recent history.` |
| 8 | How-to-play or settings sheet showing sound and haptic toggles. | `Simple rules, quick settings` | `Help and settings screen with cricket rules plus sound and haptic controls.` |

Recommended first set: slots 1 through 6. Slots 7 and 8 are backup screenshots if Play Console or device class coverage needs more assets.

### Ready Input For Screenshot Production

Capture the real Flutter app on a phone-sized portrait device. Produce 6 screenshots at 1080 x 1920 or higher. Use slots 1 through 6 above. Do not show unavailable modes, fake scores, fake rankings, fake reviews, or unofficial cricket branding. Keep any overlay copy short and away from active controls. If an ad slot is visible, it must not obscure gameplay or encourage clicks.

## Feature Graphic Brief

Required export: 1024 x 500 JPEG or 24-bit PNG without alpha.

Final asset: `store_assets/pencil_pitch_feature_graphic_1024x500.jpg`.

Reproducible source: `tooling/generate_feature_graphic.ps1`.

Recommended concept: `Notebook Spinner Match Moment`.

Composition:

- Left side: original stylized notebook-paper texture with a pencil-drawn cricket crease and a compact score strip.
- Center: a large original spinner wheel inspired by the in-game wheel, not a copied screenshot and not a fake UI claim.
- Right side: app title `Pencil Pitch` with optional subtitle `Offline Pen Cricket`.
- Add small original marks for runs, wicket, wide, and no-ball as abstract gameplay hints.

Visual style:

- Clean, bright, family-friendly.
- Use the app palette: green `#0F8B63`, paper `#F8F7F1`, charcoal `#17201C`, yellow `#F7C948`, pointer red `#E44835`.
- Avoid official cricket marks, real team colors/logos, tournament references, or stock imagery that implies affiliation.

Text:

- Primary: `Pencil Pitch`.
- Optional secondary: `Offline Pen Cricket`.
- Do not use "best", "#1", "top", "win prizes", "download now", or unavailable feature claims.

## App Icon Brief

Required export: 512 x 512 PNG, 32-bit with alpha, max 1024 KB. Also generate platform launcher icon sizes only after the final icon is approved.

Final Play Store asset: `store_assets/pencil_pitch_app_icon_512.png`.

Reproducible source: `tooling/generate_app_icon.ps1`.

Launcher update note: platform launcher icons under `android/app/src/main/res/mipmap-*` and `ios/Runner/Assets.xcassets/AppIcon.appiconset` have not been replaced in this pass. Use the final 512 icon source to generate platform icon sizes when launcher replacement is explicitly approved.

Recommended concept: `Pencil Spinner Mark`.

Design:

- Rounded-square friendly icon layout with transparent-safe margins.
- Green field background using `#0F8B63`.
- White notebook/pencil mark forming a simple spinner pointer or cricket crease.
- Small accent dot or arc in yellow `#F7C948`.
- Strong silhouette at small sizes.

Avoid:

- Real cricket logos, official team-style crests, player likenesses, batsmen silhouettes copied from stock art, or the default Flutter icon.
- Tiny text inside the icon.
- Fake app badges, rankings, or trophy claims.

Current risk: the final Play Store icon exists, but platform launcher icon files still appear to use generated/default launcher art until replacement is approved.

## Preview Video Script

Length target: 20 to 30 seconds. Use real app capture only. Upload as a YouTube video with ads disabled, no playlist URL, no channel URL, and no extra URL parameters.

Production package: `PLAY_STORE_PREVIEW_VIDEO_PACKAGE.md`.

Shot list:

1. 0:00-0:03: Main menu, title, presets, Practice innings, Target chase. Text: `Quick offline pen cricket`.
2. 0:03-0:07: Start a practice innings and tap the spinner. Text: `Tap to spin`.
3. 0:07-0:10: Stop the spinner and show real delivery feedback. Text: `Runs, wickets, wides, no-balls`.
4. 0:10-0:14: Show the scoreboard updating with overs and legal balls. Text: `Clear cricket scoring`.
5. 0:14-0:18: Target chase transition with target visible. Text: `Set a target, then chase`.
6. 0:18-0:22: Challenge ladder and progress panel. Text: `24 offline challenges`.
7. 0:22-0:27: Match result with restart and menu actions. Text: `Finish fast, retry faster`.
8. 0:27-0:30: Title card using original feature graphic style. Text: `Pencil Pitch`.

Audio direction:

- Light tap and result sounds from actual gameplay capture if available.
- No copyrighted music unless licensed and documented.
- No voiceover claims beyond visible gameplay.

## Play Console Upload Checklist

- Confirm Play Store title: `Pencil Pitch: Pen Cricket`.
- Confirm app label remains acceptable as `Pencil Pitch`, or update launcher label later if the store title must match exactly.
- Confirm package name before first publish: `com.childhood.pencilpitch`.
- Upload the custom Play Store icon and replace default/generated platform launcher icon assets after approval.
- Verify/upload feature graphic at 1024 x 500 with no alpha.
- Capture at least 4 real screenshots, recommended 6, from actual gameplay.
- Keep screenshots free of unavailable modes, fake rankings, fake reviews, real brands, team names, player names, and fake rewards.
- Prepare final preview video only from real app capture, using `PLAY_STORE_PREVIEW_VIDEO_PACKAGE.md`.
- Complete privacy policy because the repo includes AdMob and Firebase Analytics hooks.
- Complete Data safety using final SDK behavior and Play Console disclosures.
- Verify ad screenshots do not encourage ad clicks and ads do not obscure gameplay.
- Verify store copy does not imply official cricket affiliation.
- Run release readiness prompt P6 before upload.

## Skipped Heavy Checks

- Skipped `flutter pub get`: explicitly prohibited by the user.
- Skipped `flutter run`: explicitly prohibited by the user.
- Skipped `flutter build`: explicitly prohibited by the user.
- Skipped emulator/device screenshot capture: explicitly prohibited unless approved or essential.
- Skipped Play Console verification: no connected Play Console data is available in this repository.

## Remaining Risks

- No final screenshots exist yet because real device/emulator capture was not approved.
- Platform launcher icon files still need replacement from the approved icon source.
- Store title `Pencil Pitch: Pen Cricket` should be approved before changing app labels or publishing.
- The Play Store icon exists, but Android/iOS launcher icon files still need replacement before release.
- No final preview video exists yet because real device/emulator capture and upload were not approved.
- Privacy policy and Data safety answers must match the final AdMob/Firebase configuration.
- Full build, install, and release QA were not run in this P5 pass.
