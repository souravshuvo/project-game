# Trail Arena

An original offline Flutter snake arena game.

Version 1 focuses on the core loop: steer, collect food, grow, avoid your own
trail and simple offline bots, then retry for a better local score.

## Current Scope

- Offline play only.
- One arena.
- One controllable glowing trail.
- Two simple bots.
- Food, growth, score, best score, pause, help, settings, game over, and retry.
- 24 local Trail Goals for survival, score, seed collection, bright seeds, bot
  crashes, and trail length.
- Three in-run pace phases: Glide, Chase, and Surge.
- Built-in sound and haptic feedback can be toggled locally.
- AdMob banners appear only on menu/result surfaces; capped interstitials may
  appear only after game-over transitions.
- No login, shop, skins, cloud sync, or online multiplayer.

## Manual QA

- Fresh install opens to the main menu.
- Play starts with a short ready countdown.
- Open Help from the menu and confirm the rules are readable.
- Open Settings from the menu and confirm sound/haptic toggles persist.
- Confirm the menu shows Trail Goals progress and the next goals.
- Drag inside the arena to steer; the touch indicator should appear immediately.
- Food increases score and trail length.
- Food pickup shows a score cue and lightweight feedback when enabled.
- The HUD shows the active goal with progress during a run.
- Longer runs progress from Glide to Chase to Surge pace.
- Boundary, self-trail, bot-trail, and bot-head collisions end the run.
- Game over shows the death reason, newly completed goals, retry, and menu
  actions.
- Ads must never appear while the run is active.
- Pause/resume works, including app backgrounding.
- Pause exposes resume, restart, menu, settings, and help.
- Retry starts a clean run.
- Best score and completed Trail Goals persist between app launches.

Use AdMob test IDs until production IDs, consent, Data safety, and privacy
policy are complete.
