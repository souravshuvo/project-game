# Monetization Plan

Last updated: 2026-08-10

## Current Decision

Do not add monetization SDKs in current v1.

Reason: the first testing goal is to validate whether the puzzle loop is fun,
readable, fair, and replayable. Monetization should not distort early tester
feedback.

## Options

| Option | Pros | Risks | V1 Decision |
| --- | --- | --- | --- |
| No ads in v1 | Best user trust and simplest privacy story | No revenue test | Recommended |
| Rewarded undo | Easy to understand and player-friendly | Needs undo stack and ad SDK | Later |
| Rewarded shuffle | Good recovery option | Can make level design less meaningful | Later |
| Rewarded hint | Helps stuck players | Needs good hint logic | Later |
| Rewarded extra tray slot | Strong rescue moment | Balance risk if overused | Later |
| Rewarded continue after fail | Clear value at fail state | Must not feel coercive | Later |
| Interstitials between levels | Simple revenue path | Can hurt retention and reviews | Defer |
| In-app purchases | Cleaner than forced ads | Needs store products and economy | Defer |

## Rewarded Ad Direction Later

If testers like the core loop, test one optional rewarded feature first:

- Start with rewarded continue after tray full or rewarded undo.
- Never show ads during active puzzle solving.
- Never reward ad clicks.
- Never encourage clicking ads.
- Keep all ad choices optional.
- Add frequency caps before live ads.

## Interstitial Direction Later

Interstitials are not appropriate for current v1. If added much later, show only
at natural level-end transitions, never on app launch, never mid-puzzle, and
never after every level.

## Frequency Caps Later

- Rewarded ads: player-initiated only.
- Interstitials: no more than one per 3 completed levels and no more than one
  every 4 minutes.
- No interstitial before Level 4.
- No ad immediately after a failed level.

## Ad SDK Gate

Only add an ad SDK after:

- Core loop and first levels test well.
- Monetization choice is final for the next update.
- Real app IDs and test ad units exist.
- Test ads are verified before any live ad unit is used.
- Privacy policy, Data safety, Ads declaration, and target-audience status are
  updated.
- Child-directed status is confirmed before serving ads.
