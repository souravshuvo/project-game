# Emoji Chor Police Preview Video Production Package

## Status

Final video rendering was not performed. Real gameplay capture is required before this package can become a Play-ready preview video.

## Chosen Concept

**One Secret Round**

Show the real loop quickly: choose a short solo match, reveal one private role, watch the Police step forward, accuse one suspect, reveal the result, and end on local progress.

This concept is product-focused rather than human-footage focused because Google Play preview videos must show the real app experience. No people tapping a device are required for this game.

## Render Target

- Duration: 26 seconds
- Aspect ratio: 9:16 portrait
- Resolution: 1080 x 1920
- Frame rate: 30 FPS
- Format: MP4
- Video codec: H.264
- Audio codec: AAC
- Captions: burned in for the final video
- Safe margins: keep captions and overlay text away from role cards, suspect buttons, scores, and result text

## Timeline

| Time | Real capture | On-screen caption | Voiceover option |
| --- | --- | --- | --- |
| 0.0-3.0 | Main menu with match setup, Quick preset, bot style, and Start match button. | Choose a quick match | Pick a short match and bot style. |
| 3.0-6.0 | Tap Start match, then show shuffling/loading state. | Secret roles are dealt | Every round starts with hidden roles. |
| 6.0-10.0 | Secret role screen, tap Reveal my card, show only the human role. | Reveal only your card | Reveal only your own card. |
| 10.0-14.0 | Police reveal screen with one Police card visible and other roles hidden. | Police steps forward | The Police must find the hidden Thief. |
| 14.0-18.0 | Accusation screen with a suspect selected in a real human-Police round. | Pick one suspect | Choose carefully. One guess decides the round. |
| 18.0-23.0 | Round reveal or round summary showing caught/escaped result and point update. | Caught or escaped? | Scores update after every reveal. |
| 23.0-26.0 | Progress or match summary showing local goals/history. | Track local goals | Finish matches and track local goals. |

## Real App Capture List

Capture these states from the current app only:

1. Main menu: `Emoji Chor-Police`, `One phone. One player. Three bots.`, match setup, bot style, `Start match`.
2. Shuffling screen: `Shuffling cards` state.
3. Secret role screen: `Your secret card`, hidden card, `Reveal my card`, then revealed role.
4. Police reveal: one Police card visible, other player cards hidden.
5. Accusation: `Find the Thief`, suspect buttons visible, one real suspect selected.
6. Round reveal or round summary: `Thief caught` or `Thief escaped`, revealed roles, points.
7. Progress or match summary: local score history, challenge goals, or final ranking.

## Exact Capture Steps

1. Use a real device or emulator only after capture is approved.
2. Use portrait orientation.
3. Use the current app UI, not mockups or generated UI.
4. Start from a controlled local state if possible.
5. Use Quick match and Fair Random bot style unless deliberately showing another current in-app option.
6. Record multiple rounds if needed until the human player becomes Police for the accusation shot.
7. Capture the accusation and reveal from the same real round when possible.
8. Do not include banner or interstitial ads in the recording.
9. Do not show notifications, debug panels, browser chrome, emulator controls, or recording overlays.
10. Do not crop out meaningful UI in a way that misrepresents gameplay.

## Editing Notes

- Use quick straight cuts or very short crossfades.
- Keep the first 10 seconds focused on actual UI interaction.
- Avoid slow decorative animation that delays gameplay.
- Use subtle zoom only if it does not blur UI text.
- Keep all captions short and high contrast.
- Do not add device hands/fingers unless the final app usage requires off-device interaction, which it does not.
- Do not include "download now", "best", "#1", rankings, awards, review stars, or download counts.

## Audio Plan

- Preferred: light upbeat royalty-free music with license documented by the editor.
- Optional voiceover: use `voiceover-script.md`.
- UI sounds: captured app sound may be used only if clean and not distracting.
- Mix: voiceover should stay clearly above music.
- Do not use copyrighted music, trending sounds, or unlicensed audio.

## Supporting Assets

Included brand assets:

- `assets/brand/feature_graphic_1024x500.png`
- `assets/brand/app_icon_512x512.png`

Use these only for a brief end card, thumbnail reference, or internal editing reference. The main video must remain real app footage.

## Must Not Show

- Pass-and-play
- Online multiplayer
- Chat
- Login or accounts
- Cloud sync
- Shop
- Tournaments
- Betting-like mechanics
- Fake rewards
- Fake rankings, reviews, downloads, or awards
- Generated gameplay UI
- Test ads or production ads

## Final QA Checklist

- Video is 20-30 seconds, preferably 26 seconds.
- Video is portrait 9:16 with no black bars.
- At least 80 percent of the video is real in-app gameplay.
- First 10 seconds show actual app experience.
- No fake UI, fake results, or unsupported claims.
- No unavailable features are shown or mentioned.
- Captions are readable and do not cover controls or scores.
- Audio is licensed, clean, and not clipped.
- Final YouTube video is public or unlisted, not private.
- YouTube monetization is disabled for the preview video.
- YouTube video is embeddable.
- Play Console preview URL is a video URL, not a playlist or channel URL.

## Remaining Risks

- Real gameplay footage has not been captured yet.
- Final video cannot be Play-ready until capture and render QA are complete.
- Human-as-Police accusation shot may require repeated real rounds because roles are shuffled.
- Build/install state was not verified during this pass.
