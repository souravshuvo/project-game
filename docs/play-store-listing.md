# Play Store Listing Package: Dew Bubble Garden

P5 output for the current repository. Listing copy, feature graphic, app icon source assets, screenshot storyboard, and preview-video production files are prepared. Final screenshots and final preview video still require real running-game capture before upload.

## Confirmed Identity

| Item | Confirmation | Status |
| --- | --- | --- |
| Recommended Play Store title | Dew Bubble Garden | Approved for v1 |
| Installed app label in repo | Dew Bubble | Acceptable shorter launcher label |
| Android application ID | com.childhood.dewbubble | Matches `com.childhood.<game_slug>` |
| iOS bundle ID | com.childhood.dewbubble | Matches Android package |
| Current content claim | 40 garden levels: 5 authored starter levels plus 35 generated production levels | Safe to claim as "40 levels" |
| Core gameplay shown | Aim, wall bounce, match 3, pop, drop floating bubbles, stars, score, Garden Route progression, saved progress, pause/help/settings | Safe to show |

## Store Listing Copy

### Title

Dew Bubble Garden

### Short Description

Recommended:

Aim, bounce, and match dew bubbles through calm garden levels.

Alternates:

- Clear colorful dew bubbles in short, relaxing garden puzzles.
- Match 3 dew bubbles, plan smart bounces, and clear the garden.
- A gentle bubble puzzle with quick stages and satisfying pops.

### Full Description

Dew Bubble Garden is a gentle bubble shooter puzzle game about clearing colorful dew drops from a quiet garden board. Aim carefully, use wall bounces, match three or more bubbles, and drop loose clusters before the shots run out.

Play through 40 compact garden stages with saved progress and stars. Each stage is built for short sessions, readable moves, and quick restarts.

Features:

- 40 stage progression with unlocks and saved stars
- Tap or drag aiming with wall bounce previews
- Match 3 popping and floating bubble drops
- Score and star goals that reward cleaner clears
- Pause, restart, help, sound, and haptic controls
- No login required

Good for players who want a calm, quick puzzle game with clear rules and no complicated menus.

## Screenshot Storyboard

Use portrait phone screenshots captured from actual gameplay. Recommended export size: 1080x1920 PNG or JPEG with no alpha. Do not add fake boards, unavailable boosters, fake rewards, fake ratings, or fake rankings.

| # | Screen | Real Capture Requirement | Optional Overlay Copy |
| --- | --- | --- | --- |
| 1 | Home screen | Show the real Dew Bubble home card, progress summary, and primary play action. | Start in the garden |
| 2 | Garden Route | Show unlocked stages, locked future stages, saved stars, and a readable selected stage. | Pick your next puzzle |
| 3 | Gameplay aiming | Show the real shooter, HUD, aim guide, and a wall-bounce line. | Line up the bounce |
| 4 | Pop/drop moment | Capture an actual match and floating bubble drop effect. | Match 3 and drop clusters |
| 5 | Result screen | Show a real win result with stars, score, Next Stage, Replay Stage, Route, and Home actions. | Win stars and keep going |
| 6 | Pause/help/settings | Show sound and haptic toggles plus help/restart access. | Simple controls, quick retries |

Notes:

- First three screenshots should communicate the first-time flow: start, choose level, aim and shoot.
- Keep overlays short and outside the active bubble grid/HUD.
- Do not show ads in screenshots unless Play review or business needs explicitly require it later.
- Do not show rewarded ads, boosters, shop, map progression, characters, or live events because they are not v1 gameplay.

## Feature Graphic Brief

Required size: 1024x500 JPEG or 24-bit PNG with no alpha.

Concept: a bright garden scene built around the real Dew Bubble Garden board language: blue, pink, yellow, and green dew bubbles near leafy shapes, with one clean aiming line implying a bounce shot. If a gameplay board is shown, it must be based on a real captured board from the current game. Do not invent unavailable mechanics, boosters, characters, maps, currencies, or rewards.

Recommended layout:

- Left side: large readable title, "Dew Bubble Garden".
- Right side: real or faithfully matching gameplay composition with bubbles and a shooter.
- Background: light garden color field with soft leaf/dew motifs.
- No fake badges, awards, rankings, download claims, or sale language.

## App Icon Brief

Required size: 512x512 32-bit PNG with alpha, max 1024 KB.

Concept: one glossy dew bubble nestled against a small garden leaf, using the game's blue/green palette with one warm accent. The icon should read clearly at small size and avoid text.

Do:

- Use one simple hero shape.
- Keep the silhouette strong on light and dark launchers.
- Match the in-game bubble colors.
- Export adaptive icon layers separately later if Android production icons are generated.

Do not:

- Add the app name as text.
- Use awards, rankings, "free", fake shine badges, or competitor-like marks.
- Show a character or mechanic that does not exist in the game.

## Preview Video Script

Use a 20-30 second portrait gameplay video from a real device or emulator capture. Upload to YouTube as public or unlisted, with embedding enabled, ads disabled, and no age restriction. Do not use playlist/channel URLs or URL parameters.

| Time | Visual | Caption |
| --- | --- | --- |
| 0-3s | Real home screen opening into Dew Bubble Garden. | A calm bubble puzzle |
| 3-6s | Garden Route with unlocked stages and stars. | Choose a garden stage |
| 6-12s | Drag/tap aim with wall-bounce preview. | Aim the perfect bounce |
| 12-18s | Shot attaches, match pops, floating bubbles drop. | Match 3 and clear clusters |
| 18-23s | Win result with stars and score. | Earn stars and move on |
| 23-28s | Quick glimpse of pause/settings/help. | Quick retries, simple controls |

Audio direction: use the real app's lightweight feedback sounds if capture supports them. Avoid added music or effects that make the video feel unlike the app.

## Policy And Misleading-Claim Review

- Do not show fake gameplay, simulated boards, unavailable levels, unavailable boosters, unavailable rewards, shops, skins, maps, events, characters, or leaderboards.
- Do not claim awards, rankings, downloads, reviews, earnings, or "best" status.
- Do not use competitor names, characters, level layouts, art, or branding.
- Do not place calls to action such as "Download now" inside screenshots.
- Do not imply the game is ad-free if AdMob remains enabled for production.
- Because analytics and ads exist in the codebase, complete Data safety and privacy policy review before Play submission.

## P4 Data Safety Notes

- Ads are disabled unless `ADS_ENABLED=true` is supplied at build time.
- If ads are enabled, the current implementation uses interstitial ads only at level-result transitions, requests non-personalized ads, tags requests as child-directed, and caps interstitials to at least 3 level results and 3 minutes apart.
- Firebase Analytics is optional with `ANALYTICS_ENABLED=false`; when enabled and configured, it logs aggregate gameplay, progress, difficulty, settings, and ad lifecycle events without account IDs, child profiles, free text, location, camera, microphone, contacts, or raw touch coordinates.
- Play Console Data safety and the privacy policy must still disclose SDK-level collection such as device/ad identifiers, diagnostics, approximate app activity, ads, and analytics according to the final Google/Firebase configuration.

## Asset Production Checklist

| Asset | Requirement | P5 Status |
| --- | --- | --- |
| Store title | 30 characters or fewer | Ready: "Dew Bubble Garden" |
| Short description | 80 characters or fewer | Ready: recommended copy is under limit |
| Full description | Truthful current-feature copy | Draft ready |
| Phone screenshots | At least 2; recommended 6 portrait captures from real gameplay | Storyboard ready; capture still needed |
| Feature graphic | 1024x500 JPEG or 24-bit PNG, no alpha | Asset ready: `docs/play-store-assets/feature-graphic-dew-bubble-garden.png` |
| App icon | 512x512 32-bit PNG with alpha, max 1024 KB | Play icon ready: `docs/play-store-assets/app-icon-dew-bubble-garden-play-512.png` |
| Preview video | YouTube URL, real gameplay, public/unlisted, embeddable, no ads, not age restricted | Script and shot list ready; real clips/upload still needed |
| Data safety | Must reflect ads/analytics SDK behavior | Still needs final Play Console review |
| Privacy policy | Needed if ads/analytics remain in release | Still needs final URL/content review |

## Play Console Upload Checklist

| Item | Status | Notes |
| --- | --- | --- |
| Store title | Ready | Use `Dew Bubble Garden`. |
| Package name | Ready | Android application ID is `com.childhood.dewbubble`. |
| Short description | Ready | Use the recommended short description above. |
| Full description | Draft ready | Recheck after final ad/analytics and privacy-policy decisions. |
| App icon | Ready for Play asset upload | `docs/play-store-assets/app-icon-dew-bubble-garden-play-512.png`; 512x512 32-bit PNG with alpha, under 1024 KB. |
| Feature graphic | Ready for Play asset upload | `docs/play-store-assets/feature-graphic-dew-bubble-garden.png`; 1024x500 24-bit PNG, no alpha. |
| Phone screenshots | Blocked on real capture | Use `docs/play-store-assets/screenshots/manifest.csv`; final images must come from a real running app or gameplay recording. |
| Preview video | Blocked on real capture and YouTube upload | Use `docs/play-store-assets/preview-video/production-package.md` and `shot-list.csv`. |
| Data safety | Blocked on final SDK disclosure | Must disclose final Firebase/AdMob configuration and SDK-level data collection. |
| Privacy policy | Blocked on final policy URL/content | Required if ads/analytics remain enabled in the shipped build. |
| Release build validation | Blocked | Requires P6/release checks, production IDs/config, signing, and Play Console review. |

## Screenshot Production Status

Final screenshot image files were not created in this P5 pass. Exact blocker: the repository does not contain real device/emulator screenshots or a real gameplay recording, and this prompt explicitly forbids `flutter run`, install, emulator/device capture, or release packaging unless essential. Widget-test captures from `.dart_tool` are not Play-ready screenshots because they are test-rendered, static, and do not prove real device gameplay/result moments.

Prepared screenshot source materials:

- `docs/play-store-screenshot-production-brief.md`
- `docs/play-store-assets/screenshots/README.md`
- `docs/play-store-assets/screenshots/manifest.csv`

## Skipped Heavy Checks

Per instruction, this P5 pass did not run `flutter pub get`, `flutter run`, `flutter build`, install, emulator, device screenshot capture, or Play Console upload. No final screenshots or preview video files were generated, because production assets must come from real captured gameplay.

## Sources Checked

- Google Play Help: Add preview assets to showcase your app: https://support.google.com/googleplay/android-developer/answer/9866151
- Google Play Help: Manage your app's preview assets on Google Play: https://support.google.com/googleplay/android-developer/answer/16386748
