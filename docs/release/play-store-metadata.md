# Play Store Listing Package

## Confirmed App Identity

- Approved display name: Trail Arena.
- ASO position: short, readable, original, under the 30-character Play title
  limit, and not keyword-stuffed.
- Package name: `com.childhood.trailarena`.
- Game slug: `trailarena`.
- Category direction: Game, Arcade.

Do not change the package name after first Play upload.

## Store Listing Copy

### Title

Trail Arena

### Short Description

Steer, grow, and survive in a glowing offline trail arena

### Full Description

Trail Arena is an original offline arcade survival game about steering a
glowing trail through a compact arena.

Drag to guide your trail, collect seeds, grow longer, and avoid crashing into
the wall, your own path, or offline rival trails. Runs are quick, readable, and
built for retrying when you want to beat your local score.

Version 1 includes:

- Offline single-player arena.
- Simple drag steering.
- Seed collection, trail growth, score, and local best score.
- Two offline rival trails.
- 24 local Trail Goals for survival, score, collection, bright seeds, rival
  crashes, and trail length.
- Three pace phases: Glide, Chase, and Surge.
- Pause, help, settings, sound toggle, haptic toggle, game over, and retry.
- Ads only outside active gameplay.

Version 1 does not include online multiplayer, login, shop, skins, leaderboard,
cloud sync, purchases, or battle pass systems.

## Screenshot Storyboard

Use only real screenshots captured from the current app. Do not mock gameplay,
add unavailable UI, or show fake scores that were not produced by a real run.
The S2B production package is documented in
`docs/release/play-store-screenshot-production-brief.md`.

Recommended target: portrait phone screenshots, 9:16, minimum 1080 x 1920,
JPEG or 24-bit PNG without alpha.

| Slot | Real screen or moment | Overlay copy | Alt text |
| --- | --- | --- | --- |
| 1 | Ready countdown in the arena | Drag to steer | Ready countdown in Trail Arena with the player trail ready to move |
| 2 | Early movement with touch indicator | Simple touch control | Player trail turning through the arena with a visible drag control indicator |
| 3 | Normal seed pickup | Collect seeds | Player trail collecting seeds while the score increases |
| 4 | Bright seed pickup or glow feedback | Grow your trail | Bright seed pickup glowing near the player trail as the trail grows |
| 5 | Rival trails visible | Dodge rival trails | Player trail weaving around two offline rival trails |
| 6 | Active Trail Goal progress in HUD | Complete local goals | Gameplay HUD showing progress toward a local Trail Goal |
| 7 | Late-run Chase or Surge phase | Survive the surge | Long player trail avoiding walls, seeds, and rival trails in a faster phase |
| 8 | Game-over result screen | Retry quick runs | Game over screen showing score, best score, and retry button |

Capture rules:

- First three screenshots should show real app UI and gameplay clearly.
- Keep any overlay text short and away from HUD, buttons, ads, and gameplay
  hazards.
- Capture at least one screenshot where the player is not blocked by a banner.
- Do not show interstitial ads in screenshots.
- Do not claim multiplayer, rankings, rewards, shops, skins, or cloud features.

## Feature Graphic Brief

Final S3B export: `docs/release/assets/trail-arena-feature-graphic.png`.

Export status: complete. The asset is 1024 x 500, RGB PNG without alpha.

Recommended concept: a clean, high-contrast arena scene based on real gameplay.
Place a glowing green player trail sweeping through the center, a few warm seed
dots, and two smaller rival trails near the sides. Keep the main trail and seed
pickup moment inside the safe central area. Use the app title only if it remains
large and uncluttered; otherwise rely on the visual.

Visual direction:

- Background: deep green-black arena tone from the app.
- Primary trail: bright mint/green glow.
- Secondary accents: warm coral and gold seed highlights.
- Rival trails: lower-emphasis teal or blue-green, clearly separate from the
  player trail.
- Style: polished 2D arcade, matching the real in-game glowing trail language.
- Avoid tiny HUD details, fake UI, rankings, awards, price badges, or Google
  Play badges.

Production prompt, if generating a supporting graphic:

```text
Create a 1024 x 500 Google Play feature graphic for an original offline arcade
trail arena game called Trail Arena. Show a dark green arena with a bright mint
glowing player trail curving through the center, small coral and gold seed
pickups, and two subtle rival trails near the edges. Clean 2D arcade style,
high contrast, readable at phone size, no ranking badges, no app store badges,
no fake UI, no copyrighted characters, no multiplayer cues.
```

Alt text:

Glowing player trail curves through a dark arena while collecting seeds.

## App Icon Brief

Current launcher icon direction: a dark circular icon with a mint-green glowing
trail loop and central seed. It is simple, readable, and has no text, badges,
rank claims, price claims, or misleading symbols.

Current risk: existing launcher PNGs are platform launcher sizes. A final Play
store icon still needs a 512 x 512, 32-bit PNG with alpha, maximum 1024 KB.

Recommended icon concept: keep the current brand direction and refine it into a
high-resolution glowing trail loop around a central seed.

Alternative concepts:

- Trail Loop: one mint trail curling around a bright seed on a dark arena disc.
- Seed Chase: player trail bending toward a gold seed with a faint motion glow.
- Arena Ring: circular boundary ring with a short trail segment cutting through
  the center.

Use Trail Loop for version 1 because it is readable at small sizes and matches
the actual gameplay.

Icon production prompt, if generating a high-resolution source:

```text
Create a 512 x 512 app icon for an original offline arcade game called Trail
Arena. Use a dark green circular arena background, one bright mint glowing trail
loop, and a small central seed glow. Simple, high contrast, readable at small
size, no text, no badges, no ranking symbols, no price symbols, no app store
symbols, no copyrighted characters.
```

Export requirements:

- 512 x 512.
- 32-bit PNG with alpha.
- Maximum 1024 KB.
- Keep the main loop inside the safe center so launcher masks do not crop it.

## Preview Video Script

Recommendation: useful after real gameplay capture is approved. Use portrait
9:16 footage for the phone-focused listing. Keep it 20-30 seconds and disable
YouTube ads on the video.

Do not include fake gameplay, unavailable features, interstitial ads, fake
reviews, fake rankings, or fake rewards.

| Time | Real capture | On-screen text | Optional voiceover |
| --- | --- | --- | --- |
| 0-3s | Main menu, Play button, goal progress | Offline trail arena | Enter a quick offline arena run. |
| 3-7s | Ready countdown into first movement | Drag to steer | Guide the glowing trail with simple drag controls. |
| 7-12s | Collecting seeds and growing | Grow with every seed | Collect seeds, score points, and get longer. |
| 12-17s | Rival trails nearby | Watch every turn | Dodge walls, yourself, and offline rivals. |
| 17-22s | Active Trail Goal progress | Complete Trail Goals | Chase local goals across quick sessions. |
| 22-27s | Game over, score, retry button | Retry and improve | Crash, learn, and jump back in. |

Caption-only version:

1. Offline trail arena.
2. Drag to steer.
3. Collect seeds and grow.
4. Dodge rival trails.
5. Complete local goals.
6. Retry quick runs.

Production notes:

- Capture real app footage from a current build.
- Use app audio only if it is clean and does not include ads.
- Use quick cuts or gentle zooms; do not hide gameplay with heavy effects.
- Keep text large enough for phones.
- Upload as one YouTube video URL, not a playlist or channel URL.

## Policy And Misleading-Claim Review

- No existing game names, brands, screenshots, maps, characters, music, or UI
  are referenced.
- No multiplayer claim is made.
- No fake ranking, award, review, download, or earnings claim is made.
- No unavailable skins, shops, battle passes, cloud sync, purchases, or
  leaderboards are shown.
- Ads are disclosed as outside active gameplay.
- Screenshots and video must come from real gameplay before upload.

## Play Console Upload Checklist

- [ ] Title is `Trail Arena` and remains 30 characters or fewer.
- [ ] Short description remains 80 characters or fewer.
- [ ] Full description matches current shipped features.
- [ ] App icon exported as 512 x 512, 32-bit PNG with alpha, max 1024 KB.
- [x] Feature graphic exported as 1024 x 500 JPEG or 24-bit PNG without alpha.
- [ ] At least two screenshots are uploaded; for game promotion eligibility,
  prepare at least three portrait 9:16 screenshots at 1080 x 1920 or higher.
- [ ] Screenshots are real app captures and do not show unavailable features.
- [ ] Preview video, if used, is a single YouTube URL with ads disabled.
- [ ] Privacy policy URL is live.
- [ ] Ads declaration is set to Yes.
- [ ] Data safety matches AdMob, Firebase Analytics, local storage, and consent
  behavior.
- [ ] Content rating and target audience answers match the real game.

## Remaining Asset Risks

- Final screenshots have not been captured because device/emulator capture was
  not approved.
- Final 512 x 512 Play icon has not been exported.
- Preview video is a script and shot list only until real gameplay capture and
  editing are approved.
- Store copy should be rechecked after any gameplay, ad, or progression change.
