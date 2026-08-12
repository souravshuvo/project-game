# KidsLand Play Store Listing Package - P5

Status: planning and copy package only. No final screenshots, feature graphic,
icon, or video assets were generated in this pass.

## Confirmed App Identity

- ASO-friendly Play Store title: `KidsLand Preschool Games`
- On-device app label: `KidsLand`
- Android package name: `com.childhood.kidsland`
- iOS bundle identifier: `com.childhood.kidsland`
- Package slug: `kidsland`
- Package convention check: passes `com.childhood.<game_slug>` because the slug
  is lowercase ASCII, starts with a letter, and has no spaces, hyphens, or
  punctuation.

## Store Listing Copy

### App Title

KidsLand Preschool Games

### Short Description

Trace letters, count, match shapes, sort colors, and solve playful puzzles

### Full Description

KidsLand Preschool Games is a colorful collection of simple touch games for
preschool children. Kids can trace letters and numbers, count friendly groups,
match shapes, sort colors, find animals, solve patterns, pop balloons, build
memory, and draw with gentle prompts.

Each activity is designed for short play sessions with large controls, bright
feedback, forgiving touch handling, and clear next steps. The first screen lets
children pick from ten mini-games without a long tutorial.

Included games:

- Letter Tracing: follow guided paths from A to Z.
- Number Tracing: draw numbers from 1 to 10.
- Magic Drawing: complete simple drawing missions.
- Memory Match: reveal matching pairs across themed boards.
- Balloon Pop: tap balloons through cheerful waves.
- Shape Match: match shapes to their homes.
- Count & Choose: count objects and choose the number.
- Color Sorting: place pieces into color buckets.
- Animal Finder: find the requested animal.
- Pattern Puzzle: complete the missing pattern.

Parent Corner includes progress reset, sound feedback, haptic feedback, and
privacy information behind a grown-up gate. Progress is stored locally on the
device. Ads are designed to stay away from active gameplay.

KidsLand does not use accounts, child profiles, camera, microphone, or location.

## Screenshot Plan

Target: phone portrait screenshots at 1080 x 1920 or higher, JPEG or 24-bit PNG
without alpha. Use real app captures only. Do not include test ad creatives,
fake device frames, fake ratings, fake awards, or unavailable features.

| Slot | Real Screen Or Moment | Overlay Copy | Alt Text |
| --- | --- | --- | --- |
| 1 | Home grid showing KidsLand and multiple game cards | Ten playful preschool games | KidsLand home screen with colorful cards for tracing, drawing, memory, balloons, shapes, and puzzles. |
| 2 | Letter Tracing menu or active A trace canvas | Trace letters A to Z | Letter tracing screen with a large guided letter path and child-friendly controls. |
| 3 | Number Tracing or Count & Choose gameplay | Practice numbers 1 to 10 | Number game screen showing large touch targets for early counting and number practice. |
| 4 | Color Sorting gameplay | Sort colors with simple moves | Color sorting board with bright buckets and pieces for red, blue, and yellow sorting. |
| 5 | Shape Match gameplay | Match shapes by touch | Shape Match board with large colorful shapes and clear matching homes. |
| 6 | Memory Match gameplay | Build memory with pairs | Memory Match board showing child-friendly cards and a simple matching task. |
| 7 | Magic Drawing gameplay | Draw with gentle prompts | Drawing screen with a prompt, color tools, and a large canvas for creative play. |
| 8 | Parent Corner settings/privacy screen | Parent controls included | Parent Corner screen with progress, sound, haptic, privacy, and reset controls. |

Capture notes:

- Prioritize slots 1-3 for the first Play listing row.
- Keep overlay text under roughly 20 percent of each screenshot.
- Capture active gameplay states, not only menus.
- Avoid showing interstitials or ad banners in screenshots.
- Use clean status bar state with no notifications.
- Re-capture after final icon, Firebase, AdMob, and release config are stable.

## Feature Graphic Brief

Target export: 1024 x 500, JPEG or 24-bit PNG without alpha.

### Concepts

1. Mini-game collage
   - Center: large KidsLand wordmark with a playful pencil stroke.
   - Around it: original letters, numbers, shapes, balloons, animal icons, and
     color buckets inspired by real in-app games.
   - No fake screenshots, ratings, or claims.

2. Tracing path hero
   - Center: a large guided letter path with a glowing start dot.
   - Supporting objects: number 10, shape pieces, color swatches, and a balloon.
   - Strong for clarity, but may underrepresent the full ten-game collection.

3. Game card parade
   - A row of simplified colorful cards based on the Home screen.
   - Each card hints at one game category.
   - Good brand consistency, but could become crowded at small sizes.

### Recommended Concept

Concept 1: Mini-game collage.

It communicates the real app breadth without relying on fake UI. Keep the
composition simple: one central KidsLand mark, one tracing stroke, and only
five or six supporting objects.

### Visual Direction

- Palette: warm cream background, violet, pink, teal, orange, sky blue, and
  sunny yellow from the app UI.
- Typography: rounded, heavy, child-friendly sans serif; minimal text.
- Hierarchy: KidsLand title first, gameplay objects second.
- Safe area: keep the title and key objects centered; place small background
  objects near edges only.
- Avoid: device mockups, Google Play badges, "best", "#1", "free", awards,
  sale wording, or review-style claims.

### Production Prompt

Create a 1024 x 500 feature graphic for a preschool game app called KidsLand.
Use a warm cream background, rounded colorful shapes, a playful purple tracing
stroke with a glowing start dot, simple numbers 1 and 10, color buckets,
balloons, and friendly generic animal silhouettes. Keep the central focus on
the KidsLand wordmark and playful learning objects. Bright, polished,
child-friendly, clean composition, no device mockups, no ratings, no badges, no
copyrighted characters, no "free", no "#1", no sale text.

Alt text: KidsLand title surrounded by colorful tracing, counting, shape,
balloon, drawing, and puzzle objects.

## App Icon Brief

Current icon review: the Android launcher icon is still the default Flutter
logo. It does not communicate KidsLand, preschool games, tracing, or the
current brand. This is a store asset blocker before upload.

Target Play icon export: 512 x 512, 32-bit PNG with alpha, max 1024 KB.

### Concepts

1. Star pencil path
   - Rounded square/circle-safe icon with a violet-pink background.
   - A white/yellow star and a small curved pencil tracing line.
   - Recognizable at small size and matches tracing plus play.

2. Letter K play tile
   - Large friendly `K` made from a tracing stroke with a small sparkle.
   - Strong brand recall, but text in icons can be less readable at tiny sizes.

3. Shape stack
   - Three simple shapes: star, circle, triangle with a small pencil dot trail.
   - Good for multi-game breadth, but less brand-specific.

### Recommended Concept

Concept 1: Star pencil path.

It avoids text, reads clearly at small sizes, and matches the app's creative
learning tone without pretending to be one specific mini-game.

### Icon Production Prompt

Create a 512 x 512 app icon for KidsLand, a preschool mini-games app. Use a
rounded, child-friendly style with a violet-to-pink background, a bright yellow
star, and a simple white pencil tracing path with a glowing dot. High contrast,
simple shapes, soft depth, no text, no badges, no ratings, no Google Play
symbols, no copyrighted characters.

Launcher update notes:

- Replace Android mipmap launcher icons only after final icon approval.
- Update iOS app icon assets in the matching asset catalog when iOS release is
  in scope.
- Re-check icon at 48 px, 96 px, and 512 px before upload.

## Preview Video Script

Recommendation: useful for this game because Google Play recommends preview
videos for games and the app has multiple quick visual activities.

Orientation: portrait, matching the app's primary phone experience.

Length: 25 seconds.

Do not include ads, fake UI, children on camera, ratings, awards, device
mockups, or unavailable features. Use captured app footage only.

| Time | Shot | On-Screen Text | Voiceover Or Caption |
| --- | --- | --- | --- |
| 0-3s | Home screen scroll showing game cards | KidsLand Preschool Games | Pick a playful activity in one tap. |
| 3-7s | Letter tracing A or B with visible path feedback | Trace letters | Follow big guided paths from A to Z. |
| 7-10s | Number tracing or Count & Choose | Practice numbers | Count, choose, and draw numbers 1 to 10. |
| 10-14s | Color Sorting and Shape Match quick cuts | Sort and match | Use simple touch moves with bright feedback. |
| 14-18s | Memory Match pair reveal | Build memory | Match pairs across cheerful boards. |
| 18-21s | Balloon Pop wave | Tap and celebrate | Pop balloons through short, happy waves. |
| 21-24s | Magic Drawing canvas | Draw little prompts | Create simple drawings with colorful tools. |
| 24-25s | Parent Corner or Home progress | Parent controls | Sound, haptics, privacy, and reset controls. |

Music and pacing:

- Light, gentle, royalty-cleared instrumental music only.
- Keep cuts fast but not frantic.
- Use simple cross-dissolves or short pop transitions.
- Keep app sound effects low under narration/captions.

Capture checklist:

- Capture real app gameplay after final release config is stable.
- Disable test/prod ads during capture so no third-party ad creatives appear.
- Keep the first 10 seconds focused on real gameplay.
- Use a YouTube URL, not a playlist/channel URL.
- Upload public or unlisted, embeddable, not age-restricted, with monetization
  disabled.

## Play Console Upload Checklist

- Confirm final title: `KidsLand Preschool Games`.
- Confirm package: `com.childhood.kidsland`.
- Select appropriate app/game category and target audience settings.
- Mark Contains ads if production AdMob remains enabled.
- Upload final 512 x 512 icon after replacing default Flutter icon.
- Upload final 1024 x 500 feature graphic.
- Upload at least 4 portrait phone screenshots; 6-8 recommended.
- Add alt text for screenshots and feature graphic.
- Add preview video YouTube URL only after real gameplay video is produced.
- Add privacy policy URL.
- Complete Data safety form for AdMob, Firebase Analytics, network
  permissions, local progress, and diagnostics.
- Verify no screenshots or videos show fake gameplay, test ads, notification
  clutter, or unsupported features.
- Run release readiness P6 before uploading.

## Missing External Inputs

- Final privacy policy URL.
- Play developer contact and support email.
- Final production AdMob app IDs and ad unit IDs.
- Firebase project configuration files.
- Approved final app icon asset.
- Approved feature graphic asset.
- Real screenshots from final build or approved device/emulator capture.
- Real preview video footage from final build.
- Target locale list for translated listing copy and overlay text.

## Skipped Heavy Checks

- `flutter pub get`: skipped by instruction.
- `flutter run`: skipped by instruction.
- `flutter build`: skipped by instruction.
- Emulator/device screenshot capture: skipped by instruction.
- Install/release packaging: skipped by instruction.

## Remaining Risks

- Store assets are planned, not generated.
- The current launcher icon is still the default Flutter icon.
- Listing cannot be considered upload-ready until real screenshots and preview
  video are captured from the final app.
- Final Play policy, Families, AdMob, Firebase, privacy policy, and Data safety
  checks still need P6 release readiness review.
