# Closed Testing Plan

Last updated: 2026-08-10

## Goal

Use real players to confirm whether Tik Tak Toe is understandable, satisfying, stable, accessible, and worth expanding before production release.

## Recommended Track Order

1. Internal testing: small trusted group for smoke, install, crash, and listing checks.
2. Closed testing: wider group for gameplay feedback.
3. Production: only after issues from closed testing are resolved.

## Internal Test Tasks

- Install from Play internal testing link.
- Launch fresh install.
- Start local two-player mode.
- Complete one X win.
- Complete one draw.
- Restart an active round.
- Rematch after a completed round.
- Reset score.
- Start Vs AI mode.
- Confirm AI makes a move.
- Toggle sound and vibration.
- Close and reopen app to confirm settings persist.

## Closed Test Tasks

- Play at least 10 minutes.
- Try both local two-player and Vs AI.
- Report the first moment that felt confusing.
- Report whether the board and score were readable.
- Report whether invalid taps, wins, draws, and rematches felt clear.
- Confirm whether the game should stay ad-free longer.

## Feedback Questions

- Did you understand the game within the first minute?
- Was the board readable on your phone?
- Were X and O easy to tell apart?
- Did the turn indicator make sense?
- Did the AI feel too easy, too hard, or right?
- Did any text overlap or clip?
- Did animations feel fast, slow, or right?
- Would you play another match?
- Did anything crash, freeze, or look broken?
- Device model and Android version?

## Tester Evidence To Save

- Tester count
- Device list
- Crash notes
- Confusing-flow notes
- Screenshot/video of any UI issue
- Replay signal: who played more than one round
- Return signal: who came back the next day
- Top requested improvement
