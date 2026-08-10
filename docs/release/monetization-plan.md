# Monetization Plan

Last updated: 2026-08-10

## Current Decision

Do not add monetization SDKs or ads in v1.

Reason: tic tac toe sessions are short, and user trust matters more than early revenue. The first testing goal is to validate whether the game feels polished, readable, stable, and replayable.

## V1 Policy

- No banner ads.
- No interstitial ads.
- No rewarded ads.
- No in-app purchases.
- No shop or skins.

## Later Options

| Option | Pros | Risks | Decision |
| --- | --- | --- | --- |
| Stay ad-free | Best user trust and simplest privacy story | No revenue test | Recommended through first closed test |
| Supporter upgrade | Friendly, optional | Requires billing setup | Consider later |
| Rewarded cosmetic preview | User-initiated | Needs AdMob and clear reward design | Defer |
| Interstitial between completed rounds | Easy revenue path | High annoyance risk in short sessions | Defer |

## Ad Gate For Later

Only add ads after:

- Gameplay polish issues are resolved.
- Closed test feedback supports monetization.
- AdMob account and app IDs exist.
- Test ads are verified.
- Frequency caps are implemented before launch.
- Privacy policy, Data safety, and Ads declaration are updated.
- Child-directed status is confirmed before serving ads.

Ads must never appear during an active round, immediately after a move, during AI thinking, during win/draw animation, on app launch, or on app exit.
