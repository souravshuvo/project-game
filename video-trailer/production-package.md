# Magnetic Marbles Preview Video Production Package

## Status

This is a production-ready package, not a rendered final video. Final rendering
requires real gameplay capture from an approved app build or device/emulator
session. No fake gameplay footage should be substituted.

## Approved Script

Voiceover:

```text
Guide a marble crowd through gates. Grow the stream, clear the clusters, and finish quick offline arcade levels.
```

Caption:

```text
Steer marbles. Choose gates. Clear clusters. Finish 30 offline levels.
```

## Format

| Item | Target |
| --- | --- |
| Orientation | Portrait |
| Resolution | 1080 x 1920 |
| Duration | 27 seconds |
| Frame rate | 30 FPS |
| Format | MP4 |
| Video codec | H.264 |
| Audio codec | AAC |
| Audio | Captured app SFX plus optional rights-cleared light arcade bed |
| Subtitles | Burned in |

## Timeline

| Time | Real Capture | Action | On-screen Text | Voiceover | Edit Notes |
| --- | --- | --- | --- | --- | --- |
| 0.0-3.0s | Home screen | Show app title and tap Continue | Magnetic Marbles | Guide a marble crowd | Start on real home screen, quick clean tap, no debug banner. |
| 3.0-7.0s | Level 1 ready state | Hold and drag launcher, then release | Hold and drag | through gates. | Keep finger/cursor hidden if possible; show the in-app hint. |
| 7.0-12.0s | Active gameplay gate moment | Steer toward a readable add or multiply gate | Choose a gate | Grow the stream, | Cut on gate feedback; gate text must be readable. |
| 12.0-17.0s | Enemy collision moment | Crowd hits and clears red clusters | Clear clusters | clear the clusters, | Use real collision feedback, no slow fake overlays. |
| 17.0-22.0s | Level clear overlay | Show score, stars, Retry, Next, Home | Fast level clears | and finish quick | Let result settle long enough to read stars. |
| 22.0-27.0s | Level select sheet | Show the 30-level grid, including locked future levels if progress is fresh | 30 offline levels | offline arcade levels. | Do not imply all levels are unlocked; the claim is content count only. |

## Capture Steps

1. Use a real approved app build when capture is explicitly allowed.
2. Record a portrait phone or emulator session at 1080 x 1920 or higher.
3. Disable notifications, overlays, private data, FPS counters, debug banners,
   and recording cursor indicators.
4. Start from a clean install for the home, first launch, and Level 1 shots.
5. Capture the Home screen and tap Continue.
6. Capture Level 1 ready state with the "Hold and drag to launch" hint visible.
7. Capture a real gate choice where the marble crowd visibly grows or changes.
8. Capture a real enemy collision and clear moment.
9. Capture a real level clear result with stars and the Next button visible.
10. Capture the real Levels sheet with the 30-level grid. Locked levels may be
    visible if they are part of the real fresh-install state.
11. Do not capture or include ads, shops, upgrades, skins, leaderboards, login,
    cloud sync, or unavailable modes.

## Capture File Names

| File | Required Content |
| --- | --- |
| `assets/ui/01_home_continue.mp4` | Home screen, app title, Continue tap |
| `assets/ui/02_hold_drag_launch.mp4` | Level 1 ready state and real launch |
| `assets/ui/03_gate_choice.mp4` | Real gate choice and readable gate labels |
| `assets/ui/04_enemy_clear.mp4` | Real enemy collision and clearing feedback |
| `assets/ui/05_level_clear.mp4` | Real Level clear result with stars and Next |
| `assets/ui/06_level_select_30_levels.mp4` | Real level select sheet with 30 levels |

## Captions

| Time | Burned Caption |
| --- | --- |
| 0.0-3.0s | Magnetic Marbles |
| 3.0-7.0s | Hold and drag |
| 7.0-12.0s | Choose a gate |
| 12.0-17.0s | Clear clusters |
| 17.0-22.0s | Fast level clears |
| 22.0-27.0s | 30 offline levels |

Caption rules:

- Keep captions short and high contrast.
- Place captions in the upper safe area or lower safe area only when they do
  not cover HUD, gate labels, stars, or result buttons.
- Use the same wording as the table unless a captured state makes the wording
  misleading.

## Voiceover Timing

| Time | Voiceover Line |
| --- | --- |
| 0.0-4.5s | Guide a marble crowd through gates. |
| 7.0-14.5s | Grow the stream, clear the clusters, |
| 17.0-24.5s | and finish quick offline arcade levels. |

Voiceover may be omitted if the final mix works better with app SFX and burned
captions only. Do not use robotic temporary narration in the final upload.

## Audio Direction

- Keep captured tap, gate, score, win, and transition feedback if clean.
- Add only rights-cleared or original light arcade music if needed.
- Keep music under voiceover and UI feedback.
- Avoid copyrighted music, monetization claims, and loud stingers.
- Export with AAC audio and no clipping.

## Supporting Visual Assets

No extra generated footage is needed. The final video should be at least 80%
real in-app or in-game experience.

Allowed supporting assets:

- Play icon: `store_assets/app_icon/play_store_icon_512.png`
- Feature graphic: `store_assets/feature_graphic/feature_graphic_1024x500.png`

Use these only for upload packaging, thumbnail/reference, or brand continuity.
Do not replace gameplay shots with them.

## Editing Notes

- Use quick cuts, not slow decorative animation.
- Start gameplay within the first 10 seconds.
- Avoid black bars; crop or scale portrait captures to fill 1080 x 1920.
- Do not zoom so far that gate labels, HUD, or result buttons become blurry.
- Keep overlays outside active touch paths and away from important game objects.
- Use the feature graphic as the Play cover asset separately, not as a fake
  gameplay segment.

## YouTube Upload Checklist

- Upload one regular YouTube video, not a Short, playlist, or channel.
- Set visibility to public or unlisted, not private.
- Disable monetization and avoid copyrighted material that may trigger ads.
- Make the video embeddable.
- Do not age-restrict the video.
- Use a URL without timecode or extra tracking parameters.
- Use a truthful title such as `Magnetic Marbles - Gameplay Preview`.
- Use a truthful description: `Guide marble crowds through gates and clear short offline arcade levels.`
- Do not include fake awards, rankings, reviews, download counts, or claims.

## Play Console Video Checklist

- Add the YouTube URL in the Play Console preview video field.
- Do not use a playlist URL, channel URL, Short URL, or timecoded URL.
- Keep the feature graphic uploaded because Google Play can use it as the video
  cover image.
- Verify the video plays in Play Console preview before release.
- Confirm the video does not show ads, unavailable features, debug UI, or fake
  gameplay.

## Final QA Checklist

- Real app footage only.
- Core gameplay appears within the first 10 seconds.
- At least 80% of the video shows real app or gameplay experience.
- No ads shown.
- No fake UI, fake levels, fake rewards, or edited impossible states.
- No people tapping a device.
- No black bars.
- Captions are readable on a phone screen.
- Captions do not overlap HUD, gates, result buttons, or active gameplay.
- Gate text and result stars are readable.
- Audio is present, balanced, and not clipped.
- Final MP4 is 1080 x 1920, 30 FPS, H.264 video, AAC audio.
- YouTube upload is public or unlisted, embeddable, not age-restricted, and not
  monetized.

## Remaining Risks

- Final video is not created until real app capture is approved.
- YouTube upload URL is not available yet.
- Store-listing preview cannot be fully validated until the uploaded YouTube URL
  is tested in Play Console.
- If captured footage shows performance stutter, weak touch clarity, or cramped
  captions, the edit must be revised before upload.
