# Closed Testing Plan

Last updated: 2026-08-14

## Goal

Use real players to confirm whether Larder Labels is understandable, satisfying,
stable, and worth expanding before any production release.

## Recommended Track Order

1. Internal testing: small trusted group for install, smoke, crash, and listing
   checks.
2. Closed testing: wider group for gameplay feedback.
3. Production: only after issues from closed testing are resolved.

## Internal Test Tasks

- Install from the Play internal testing link.
- Launch a fresh install.
- Confirm the first screen is playable gameplay.
- Complete Level 1.
- Complete the first 10 current levels if possible.
- Tap a covered tile on a layered level and confirm the message is useful.
- Fill the tray on purpose and confirm the fail state feels fair.
- Use Restart and confirm the level resets.
- Confirm test interstitials appear only at capped completed-level transitions.
- Confirm no ad appears during active puzzle play or immediately after a fail.
- Close and reopen the app and confirm no crash or broken state.

## Closed Test Tasks

- Play at least 10 minutes.
- Try to complete at least 10 v1 levels.
- Report the first moment that felt confusing.
- Report any level that felt unfair, too easy, or boring.
- Confirm whether tile labels, covered tiles, tray state, and result messages
  are readable.
- Confirm whether the game should stay ad-free longer.
- Report whether level-end test ads feel too frequent or disruptive.

## Feedback Questions

- Did you understand the rule within the first minute?
- Which level did you stop at?
- Was any text unclear?
- Were the labels, colors, covered-tile marks, and tray readable?
- Did the tap feedback feel satisfying enough?
- Did the tray fail state feel fair?
- Would you play more levels if they were similar?
- Would optional rewarded undo, shuffle, hint, extra slot, or continue feel
  acceptable later?
- Did any ad appear while you were actively solving a puzzle?
- Did anything crash, freeze, or look broken?
- Device model and Android version?

## Tester Evidence To Save

- Tester count
- Device list
- Crash notes
- Confusing-level notes
- Screenshot/video of any UI issue
- Completion notes for each tested level
- Retention signal: who came back the next day
- Top requested improvement
