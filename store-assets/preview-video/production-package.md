# Sixteen Breed Preview Video Production Package

## Recommendation

Create a Google Play preview video only after recording real app footage. The app is a board game, so a short preview is useful, but the final video must be built from actual gameplay capture rather than generated or mocked UI.

## Chosen Concept

Every move is clear before you commit.

The video opens on the real app, gets to gameplay quickly, shows legal move and capture feedback, then closes with bot practice, match completion, and recent match history.

## Format

| Item | Target |
| --- | --- |
| Duration | 28 seconds |
| Orientation | Portrait |
| Resolution | 1080 x 1920 preferred |
| Frame rate | 30 FPS |
| Format | MP4 |
| Video codec | H.264 |
| Audio codec | AAC |
| Captions | Burned in, high contrast |
| Ads | None |

## Timeline

| Time | Shot | Real App Capture | On-Screen Text | Optional Voiceover | Edit Notes |
| --- | --- | --- | --- | --- | --- |
| 0:00-0:03 | App opens to Home | Home screen with title and mode buttons | Offline 16 Beads | Play Sholo Guti anywhere. | Start directly on app UI. No logo-only intro. |
| 0:03-0:06 | Local match starts | Tap Local 2 Player, show starting board | Start A Local Match | Start a local match in seconds. | Cut on button tap into board. |
| 0:06-0:10 | Legal move highlight | Select a bead with green targets visible | See Legal Moves | Green points show where you can move. | Hold long enough for highlights to read. |
| 0:10-0:15 | Capture setup | Show amber jump path before committing | Jump To Capture | Amber jumps capture opponent beads. | Use the capture setup sequence below. |
| 0:15-0:18 | Optional chain | After capture, show End Turn and next amber target | Chain Or End Turn | Continue the chain or end the turn. | Do not imply captures are mandatory. |
| 0:18-0:21 | Bot mode | Open Player vs Bot difficulty picker or active bot match | Practice vs Bot | Practice against Easy, Balanced, or Sharp. | Show only real difficulty names. |
| 0:21-0:25 | Match result | Match Complete panel with Rematch/Home | Rematch Fast | Finish, rematch, and play again. | Use a real completed match. |
| 0:25-0:28 | History or brand close | Match History with completed match entry, then quick brand end | Track Recent Matches | Keep your recent matches on device. | Use real saved history. Brand close may use existing icon/feature graphic for the final half second. |

## Exact Capture Steps

Capture with a real device or emulator only after approval. Hide debug banners, notifications, pointer trails, emulator controls, and performance overlays.

1. Open the app and verify the title is `Sixteen Breed`.
2. Record `capture/raw/01-home-to-local.mp4`: start on Home, tap `Local 2 Player`, and hold the new board for one second.
3. Record `capture/raw/02-legal-moves.mp4`: on the starting board, select a Player 1 bead with green legal move targets visible. Recommended first simple state: select node `11` or `14` from the left/right edge area.
4. Record `capture/raw/03-capture-chain.mp4` using this real sequence from a fresh Local 2 Player match:
   - Player 1: move node `11` to node `16`.
   - Player 2: move node `25` to node `20`.
   - Player 1: move node `14` to node `19`.
   - Player 2: move node `23` to node `18`.
   - Player 1: select node `13`; amber capture from `13` to `23` over `18` should be highlighted.
   - Commit the capture. The optional chain state should show `End Turn` with another capture available from node `23` to node `25` over `24`.
5. Record `capture/raw/04-bot-mode.mp4`: return Home, tap `Player vs Bot`, show the difficulty picker, choose `Balanced`, and capture the board or `Bot thinking...` state.
6. Record `capture/raw/05-match-complete.mp4`: finish a real local or bot match and capture the `Match Complete` panel with `Rematch` and `Home`.
7. Record `capture/raw/06-history.mp4`: after at least one real completed match, open `History` and capture the completed match row.

## Editing Notes

- Keep at least 80% of the video as real app/gameplay footage.
- Use short, readable captions because preview videos may autoplay muted.
- Use quick cuts and 150-250 ms crossfades only; avoid slow decorative transitions.
- Do not cover the board, bead counts, turn text, highlighted targets, `End Turn`, `Rematch`, or history rows with text.
- Do not show interstitial ads, test ads, ad loading states, analytics debug logs, or Firebase/AdMob setup screens.
- Do not include fingers tapping a phone. Use clean screen recording without visible touch indicators unless needed for clarity.
- Use only royalty-free or self-owned music. Keep music low under app sounds or voiceover.

## Supporting Visuals

Approved existing assets that may be used for the final half-second close or YouTube thumbnail:

- `store-assets/app-icon/sixteen-breed-play-icon-512.png`
- `store-assets/feature-graphic/sixteen-breed-feature-graphic.png`

Do not use these assets as a substitute for gameplay footage.

## Final QA Checklist

- Video uses real Sixteen Breed UI and gameplay only.
- First 10 seconds show actual gameplay, not branding.
- No unavailable features: online play, shop, rewards, tournaments, rankings, chat, account login, cloud sync, or leaderboard.
- No ads appear in the video.
- Captions are readable on mobile and do not cover gameplay.
- All shown moves and captures are legal app states.
- Optional capture chains are described as optional.
- Bot difficulty names match the app: Easy, Balanced, Sharp.
- Result and history shots come from real completed matches.
- No copyrighted music, claims, reviews, awards, rankings, or download numbers.
- Final upload uses a normal YouTube URL with ads disabled, not a playlist/channel URL.

## Remaining Risk

The final MP4 cannot be produced truthfully until real gameplay clips are captured. The package is ready for capture and editing, but it is not a finished Play preview video.
