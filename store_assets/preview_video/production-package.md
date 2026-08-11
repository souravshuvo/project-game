# Arrow Puzzle Preview Video Production Package

Status: production package only. No final video has been rendered or uploaded.

## Approved Concept

Show the real Arrow Puzzle gameplay loop in the first seconds: scan an arrow board, tap arrows with clear paths, watch them slide off, use a hint when needed, then show progression and level completion.

## Output Target

- Duration: 22-24 seconds
- Orientation: portrait 9:16
- Resolution: 1080 x 1920
- Frame rate: 30 fps
- Format: MP4
- Video codec: H.264
- Audio codec: AAC
- Captions: burned in and optionally uploaded as SRT
- Platform handoff: upload to YouTube, then paste the single video URL into Play Console

## Real App Evidence

- App name: Arrow Puzzle
- Play title: Arrow Puzzle: Tap Puzzle Game
- Package name: com.childhood.arrowpuzzle
- Core value: tap arrows with clear paths and clear each board in the right order
- Real content: 60 handcrafted levels, level select, hints, restart/pause, best-move tracking, local progress
- Final screenshots: ../screenshots/phone_final/
- Feature graphic: ../feature_graphic/feature-graphic.png
- Play icon: ../icon/play-store-icon.png

## Capture Rules

- Capture only real app UI and real gameplay.
- Do not show generated fake UI, fake levels, fake ratings, fake awards, fake downloads, leaderboards, or unavailable modes.
- Do not show ads or ad-loading placeholders in the video.
- Use an ads-disabled build/capture configuration:

```powershell
flutter run --dart-define=ARROW_PUZZLE_ADS_ENABLED=false
```

- Hide debug banners, emulator chrome, notifications, mouse cursor, dev tools, and status-bar clutter.
- If later-level footage is used, capture a real level from the shipped level pack using normal progress or a controlled capture profile that unlocks real content without inventing screens.

## Timeline And Shot List

| Time | Shot | Real UI to capture | Action | On-screen text | Purpose |
| --- | --- | --- | --- | --- | --- |
| 0.0-2.5s | Gameplay hook | PuzzlePage, early level | Tap a clear arrow and show slide-off animation | Clear every arrow | Show core interaction immediately. |
| 2.5-6.0s | Rule clarity | PuzzlePage, early level | Tap 2-3 valid arrows with open lanes | Tap clear paths | Explain the rule visually. |
| 6.0-10.5s | Planning moment | PuzzlePage, denser mid/late level | Pause briefly, then tap a correct move | Plan the order | Show the strategy layer without implying new modes. |
| 10.5-14.0s | Hint support | PuzzlePage with a real hint highlight | Use hint, then tap highlighted arrow if valid | Hints when needed | Show the real hint state. |
| 14.0-17.5s | Progression | LevelSelectPage | Scroll or pan over unlocked/locked levels | 60 handcrafted levels | Show real content depth. |
| 17.5-21.5s | Completion | LevelCompletePage | Show clear result, moves, Replay, Next Level | Replay for better moves | Show reward and replay loop. |
| 21.5-24.0s | Brand end card | Feature graphic or app icon over app palette | Hold clean brand frame | Arrow Puzzle | End clearly without a call to action. |

## Voiceover Script

Use either this calm voiceover or omit voiceover and rely on captions/music.

```text
Find the arrows with open paths.
One tap sends them off the board.
Some puzzles need the right order.
Use a hint when the path gets tricky.
Clear the board, then replay for better moves.
```

## Caption Script

Use short burned-in captions. Keep captions below the board or in a safe top band, never covering arrows or completion controls.

```text
Clear every arrow
Tap clear paths
Plan the order
Hints when needed
60 handcrafted levels
Replay for better moves
Arrow Puzzle
```

## Editing Notes

- Start on gameplay, not a logo.
- Keep at least 80% of the video as real app/gameplay footage.
- Use the existing blue, amber, mint, coral, and white visual system.
- Use simple cuts or quick eased crossfades; avoid flashy effects that hide the rules.
- Add subtle tap and slide sound effects only where they match real interactions.
- Use calm, light puzzle music with no copyrighted or monetized tracks.
- Keep all text large and readable during muted autoplay.
- Do not include hands/device footage; the game experience is fully on-device UI.
- Do not include "download now", "install now", "#1", "best", "top", "free", "new", ratings, reviews, awards, or price claims.

## Capture Checklist

- Home screen optional; gameplay must appear first.
- Early gameplay: Level 1 or another simple board before taps.
- Valid tap animation: arrow slides away after a legal move.
- Denser board: use an actual shipped level, ideally around the mid/late pack.
- Hint state: use the real hint button/highlight.
- Level select: show actual 60-level progression state.
- Completion: show actual LevelCompletePage with moves, stats, Next Level, Replay.
- Brand outro: use ../feature_graphic/feature-graphic.png or ../icon/play-store-icon.png.

## YouTube Upload Checklist

- Upload a normal YouTube video, not a Short, playlist, channel URL, or live video.
- Set visibility to public or unlisted.
- Disable monetization/ads on the video.
- Use only music/SFX that will not trigger monetization claims.
- Ensure the video is not age restricted.
- Ensure embedding is allowed.
- Use the plain YouTube video URL with no timecode or extra URL parameters.
- Keep a localized version per language/market if localizing the Play listing.

## Play Console Checklist

- Open Play Console > Grow users > Store presence > Main store listing.
- Paste the single YouTube video URL in the preview video field.
- Confirm the feature graphic remains uploaded because it may be used as the video cover/play-button frame.
- Confirm the preview video appears before screenshots on the listing preview.
- Review muted autoplay readability in the first 30 seconds.
- Confirm no ads, fake UI, unsupported features, or policy-risk claims are visible.

## Final QA Checklist

- [ ] Real gameplay appears within the first 2 seconds.
- [ ] First 10 seconds focus on core gameplay.
- [ ] At least 80% of the video shows actual app/gameplay experience.
- [ ] No ads or ad placeholders are shown.
- [ ] No unavailable features or fake levels are shown.
- [ ] No rankings, awards, reviews, install CTAs, price claims, or download claims are shown.
- [ ] Captions are readable on phone screens and do not cover key controls.
- [ ] Music and sound effects are licensed for ad-free YouTube use.
- [ ] Video is public or unlisted, embeddable, not age restricted, and non-monetized.
- [ ] Final URL is a direct YouTube video URL with no extra parameters.

## Remaining Risks

- A final MP4 still needs real capture or approved rendering before upload.
- If a physical device/emulator is used later, capture must be rechecked for status-bar clutter, debug overlays, ad widgets, and frame pacing.
- If copyrighted music or SFX are used, YouTube may still show ads even if monetization is disabled; use original or properly licensed audio.
