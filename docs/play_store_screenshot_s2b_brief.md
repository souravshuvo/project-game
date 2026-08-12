# Play Store Screenshot S2B Production Brief

## Status

Final screenshot image files were not created in this pass.

Reason: the repository does not contain real gameplay screenshots, and emulator/device capture was not approved. Per Prompt S2B, do not fake UI or gameplay. Use this brief to capture and assemble final Play Store screenshots once real app capture is approved.

## Export Target

- Device type: phone
- Orientation: portrait
- Recommended size: 1080 x 1920 or higher
- Format: PNG or JPEG
- Transparency: none
- Count: 6 screenshots
- Real UI requirement: every screenshot must be based on actual captured app UI from the current game.

## Approved Screenshot Set

| Slot | Output filename | Real app moment | Overlay copy | Alt text |
| --- | --- | --- | --- | --- |
| 1 | play-store-phone-01-main-menu.png | Main menu with match setup, presets, bot style, and Start match button. | Choose a quick match | Main menu showing match length, bot style choices, and Start match button. |
| 2 | play-store-phone-02-secret-role.png | Secret role screen before or just after tapping Reveal my card. | Reveal only your card | Secret role screen showing the player's hidden card reveal flow. |
| 3 | play-store-phone-03-police-reveal.png | Police reveal screen with Police shown and other cards hidden. | Police steps forward | Police reveal screen showing one Police card and hidden player cards. |
| 4 | play-store-phone-04-accusation.png | Accusation screen with suspect choices visible. | Pick one suspect | Accusation screen where the Police chooses one hidden player as the Thief. |
| 5 | play-store-phone-05-round-result.png | Round reveal or round summary with caught/escaped result and points. | Caught or escaped? | Round result screen showing revealed roles, accused player, Thief, and score update. |
| 6 | play-store-phone-06-progress.png | Progress screen with history and challenges. | Track local goals | Progress screen showing local match history and challenge progress. |

## Capture Steps

1. Use a real device or emulator only after capture is approved.
2. Capture the current app, not mockups or recreated UI.
3. Use a portrait phone viewport.
4. Start from a fresh or controlled local save state.
5. Use a Quick match and Fair Random bot style unless another current in-app option is deliberately being shown.
6. Capture slot 4 only from a real round where the human player is Police.
7. Capture slot 5 from the same real round when possible, so the accusation and reveal are coherent.
8. Avoid showing ads in the video/screenshot capture. If an ad appears on menu or progress, do not crop it in a misleading way; prefer active gameplay screens first or use an approved clean capture build.
9. Remove notification bar distractions only if the edit does not change the app UI.

## Overlay Rules

- Keep overlay text short and large.
- Use one overlay phrase per screenshot.
- Do not cover role cards, suspect buttons, scores, or result text.
- Use high contrast text over a simple teal or light background area.
- Do not add "download now", "best", "#1", awards, review stars, ratings, download counts, or sale labels.
- Do not add feature claims that are not visible in the current app.

## Supporting Graphics

Optional supporting graphics may be used only around real screenshots:

- Solid teal background matching the app theme.
- Simple safe-area frame.
- Small original role-card accents.

Do not use generated screens as replacements for actual captured app UI.

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
- Non-current gameplay

## QA Checklist

- Each screenshot is from the real current app.
- First three screenshots prioritize real UI over decorative framing.
- Text is readable at phone-store scale.
- No important UI is hidden by overlay text.
- No screenshot shows unavailable features.
- No screenshot shows fake metrics or fake claims.
- All screenshots are portrait and Play-compatible.
- Files are named in slot order.
- Alt text is 140 characters or less.
- Screenshots match the store title `Emoji Chor Police: Solo Game`.
- Screenshots match the Android package `com.childhood.emojichorpolice`.

## Remaining Risks

- Final screenshots still require approved runtime capture.
- Current launcher icon is still default Flutter branding and should be replaced before final store upload.
- Build/install state was not verified during this pass.
- If ads are enabled during capture, the final screenshot set must be reviewed again for ad placement and misleading "ad-free" implications.
