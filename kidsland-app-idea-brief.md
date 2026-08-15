# KidsLand App Idea Brief

> P4 status note: this brief preserves the earlier ad-free tracing MVP
> assumptions. The current production v1 repository now contains ten KidsLand
> games plus production-safe AdMob/Firebase Analytics integration. Use
> `README.md` and `docs/admob-analytics-data-safety.md` for the current
> monetization, analytics, and Data safety notes.

Planning date: 2026-08-07  
Blueprint sources: `checklists/new-app-checklist.md` and `templates/app-idea-brief.md`

## Planning Decision

**Recommendation: Reduce scope, then start.**

The original idea contains four independent game engines: guided tracing, drawing/bucket fill, memory matching, and balloon animation/particles. That is too broad for a polished solo-developer MVP. The proposed MVP below validates one strong educational loop—uppercase letter tracing—without Firebase, advertising, accounts, or network access.

Keep **KidsLand** as the umbrella brand. Use **KidsLand: Letter Tracing** as the public working title until the app contains enough polished activities to justify “Toddler Games” or “All-in-One” in the store listing.

## Assumptions to Confirm

The supplied information is sufficient to plan if these assumptions hold:

1. Android/Google Play is the first release platform.
2. The first goal is product validation and a safe child experience, not immediate revenue.
3. Strict offline operation takes priority over AdMob in version 1.
4. The current default Flutter scaffold in `C:\project-game` may be reused after the product direction is accepted.
5. The first test audience may be narrowed from ages 2–6 to ages 3–5, because guided letter tracing is not equally suitable across that whole developmental range.

If assumption 2 or 3 is wrong, monetization and privacy planning must be reopened before implementation.

## Basic Info

- **Project name:** KidsLand
- **Working/public MVP name:** KidsLand: Letter Tracing
- **Long-term product type:** Child-friendly educational mini-game collection
- **MVP product type:** Educational tracing game/activity
- **Owner:** Solo developer (assumption)
- **Date:** 2026-08-07
- **Target first platform:** Android / Google Play
- **Primary goal:** Validate a calm, repeatable, fully offline tracing experience before expanding content or adding monetization

## One-Sentence Idea

KidsLand helps preschool children ages 3–5 practice early uppercase-letter recognition and formation by tracing forgiving guided paths with immediate visual and audio feedback, entirely offline.

## Target User

- **Primary user:** A preschool child aged 3–5 using a parent-owned Android phone or tablet
- **Secondary user:** The parent or guardian who controls settings, privacy actions, and any future purchases
- **User skill level:** Pre-reader or emerging reader with developing fine-motor control
- **Initial market:** English-language Google Play markets (assumption)
- **User problem:** Many child apps are distracting, network-dependent, commercially aggressive, or too text-heavy
- **User motivation:** Immediate sensory feedback, a quick celebration, familiar repetition, and visible letter completion
- **Repeat-use reason:** Practice a new letter, replay a favorite, or continue the locally saved alphabet journey

Provisional alternatives to examine in a separate store review are ABC tracing apps such as **ABC Kids – Tracing & Phonics**, **Writing Wizard**, and printable tracing worksheets. The differentiation hypothesis to test is not “more features”; it is a calmer, account-free, ad-free, truly offline experience with forgiving touch input.

## Problem or Desire

- **Current pain:** A young child needs an activity that works without reading, login, internet, or adult troubleshooting.
- **Current workaround:** Paper worksheets, videos, or broad learning apps with unrelated content.
- **Why alternatives may not be enough:** Some are too busy, require connectivity, interrupt play, or do not provide motor-friendly feedback. This is a hypothesis requiring competitive and family testing.
- **Why the user would care now:** Parents need short, safe activities that work during travel, waiting, or limited-connectivity situations.

## Product Type and Game Loop

- **Classification:** Educational game/activity, not a utility or content catalogue
- **Core loop:** Choose a letter → hear its name/sound → follow ordered, forgiving checkpoints → receive glow/sound feedback → celebrate completion → replay or choose the next letter
- **Player goal:** Complete the guided stroke path in the intended order
- **Scoring:** No numeric score, leaderboard, timer, or punitive star rating; completion earns a simple local checkmark or glow
- **Win condition:** All required stroke checkpoints are completed within the allowed corridor
- **Lose condition:** None; leaving the corridor pauses progress and gives a gentle visual hint
- **Retry:** Clear/restart is always available without penalty
- **Difficulty progression:** Start with visually simple uppercase letters; later letters add more strokes. Reduced hints may be tested only after the forgiving base mode works.
- **Expected session length:** 2–5 minutes
- **First success moment:** The child completes letter A in under about one minute after a short voice/animation demonstration
- **Next action after success:** Replay A or move to the next available letter
- **Replay reason:** Familiar audio/visual feedback and completing more of the alphabet

## MVP Scope

### Smallest useful public version

A single polished uppercase-letter tracing activity for A–Z, with local progress, bundled audio, and a parent-only area. The engine must first pass usability testing with A–F before the remaining letter assets are produced.

### Delivery gates

1. **Engineering vertical slice:** Letter A only
2. **Supervised usability build:** Letters A–F
3. **Public MVP candidate:** Uppercase A–Z using the validated engine

Advance from A to A–F only if at least four of five parent-supervised children aged 3–5 complete A within 90 seconds after one demonstration, without an adult touching the screen, and no blocking defect occurs. Advance from A–F to A–Z only after the same completion threshold holds across simple and multi-stroke letters and there are no unresolved critical usability issues. This is small enough to build and test quickly because the first iteration contains one path, one audio hook, one persistence key, and one game loop.

### Must-have features

1. A forgiving CustomPainter-based tracing engine with ordered checkpoints, interpolation between touch samples, reset, and completion detection
2. Bundled uppercase letter paths and licensed local letter audio, with immediate visual/audio feedback and a small celebration
3. Hive-backed local progress and preferences, plus a parent-gated area for sound/haptics, privacy information, and reset/delete

### Nice-to-have later

- Numbers 1–10 and lowercase letters after the alphabet loop is validated
- Magic coloring/drawing as a separately scoped engine and asset pack
- Memory match and balloon pop as separate roadmap releases

### Explicitly out of scope for version 1

- AdMob, in-app purchases, subscriptions, or any monetized action
- Firebase, cloud analytics, Crashlytics, login, profiles, sync, or remote configuration
- Coloring/bucket fill, free drawing, memory match, balloon physics, particles, animal/vehicle packs
- Multiple languages, words, handwriting recognition, adaptive difficulty, daily rewards, streaks, leaderboards
- Camera, microphone, location, contacts, notifications, social features, external child-facing links

## First Screens

1. **Child Home**  
   One large Play action, a simple alphabet-progress visual, a discreet adult-area entry, and a parent-readable link to the bundled privacy notice.
2. **Letter Picker**  
   Large letter tiles with clear completed/not-completed states and no reading-dependent instructions.
3. **Tracing Play**  
   Letter path, start cue, finger feedback, replay-audio action, reset action, and home/next navigation.
4. **Parent Corner**  
   Sound/haptics settings, privacy text/link, app information, and reset-all-progress action.

The celebration is an overlay on Tracing Play, not another screen. The parental gate is a dialog before Parent Corner, not a persistent unlocked mode.

## Main User Flow

```text
Open app
→ local bootstrap
→ Child Home
→ tap Play
→ Letter Picker
→ choose A
→ hear A and see the start cue
→ trace ordered strokes
→ celebration + local completion save
→ replay or choose next letter
```

Parent flow:

```text
Child Home
→ adult-area entry
→ randomized adult-readable gate
→ Parent Corner
→ change setting / read privacy information / reset data
→ leave Parent Corner and immediately re-lock
```

### Empty, loading, error, and offline behavior

- **First use:** Show all letters as incomplete; do not require onboarding, a profile, or a child name.
- **Loading:** Only local asset/Hive initialization. Keep it short and disable Play until initialization finishes.
- **Missing audio:** Keep tracing usable, show visual feedback, and record a capped local error counter.
- **Corrupt local state:** Fall back to safe defaults and expose a parent-gated reset; never block the child behind a technical message.
- **Offline:** Every required child and parent feature in version 1 must work in airplane mode after installation. Parent Corner bundles the complete privacy text; its optional browser link to the hosted copy is supplemental and may be unavailable offline.

## Parental Gate

The originally suggested fixed question such as “What is 4 + 3?” is too easy for part of the target audience and must not be treated as verified parental consent.

For version 1, use a randomized adult-readable, multi-step interaction with a hold gesture. Re-lock on exit, app backgrounding, or a short timeout. The gate protects navigation only; it is not proof of parent identity and not a COPPA consent mechanism. Any future purchase must retain this app gate, use Google Play Billing where required, and respect the authentication/approval behavior configured in Google Play or Family Link.

All settings, data reset, external privacy-policy web links, future purchases, and any future ad trigger remain behind this gate. The bundled, read-only privacy notice remains directly accessible from Home. As a stricter KidsLand product rule—not a claim about what Google technically permits—version 1 rejects banners, interstitials, and app-open ads because they do not fit the gated, continuous-touch child experience.

## Data Plan

- **Local data:** Schema version; completed-letter flags; aggregate replay/completion counters; sound/haptic preferences; capped local error counters
- **Cloud data:** None
- **User-generated data:** None in MVP; raw strokes are ephemeral and discarded when the trace ends
- **Sensitive data:** None intended
- **Explicitly prohibited:** Child name, birth date, email, voice, photo, precise/raw stroke history, device identifiers, location, advertising identifier
- **Login required:** No
- **Backup/restore:** Explicitly exclude all app data from Android cloud backup and device-to-device transfer using the manifest plus version-appropriate `dataExtractionRules` and legacy `fullBackupContent` rules; do not rely on Hive or `allowBackup` alone
- **Data deletion:** Parent-gated “Reset all progress and settings” removes all Hive boxes and recreates defaults
- **Retention:** Keep only current progress/preferences and small aggregate counters; do not retain per-session child histories

## Firebase Plan

Firebase is **not needed** for the MVP.

- **Analytics:** No; use local aggregate counters and supervised usability testing
- **Crashlytics:** No; use bounded local error reporting plus Google Play pre-launch reports/Android vitals where available
- **Remote Config:** No
- **Auth:** No
- **Firestore / Realtime Database:** No
- **Storage:** No
- **Cloud Functions:** No
- **Console setup:** None

Adding any Firebase product would contradict strict zero-network operation and create additional child-data review without solving an MVP need.

## Monetization Plan

### Version 1

- **Monetization:** None
- **Banner:** None
- **Interstitial:** None
- **Rewarded:** None
- **App-open:** None
- **Native ad:** None

This fits the user journey because the first release is a product-validation build for very young children. It also preserves the literal offline claim and substantially reduces policy and accidental-click risk.

### Later options, in preferred order

1. **Paid-upfront app:** Cleanest option if strict offline behavior remains non-negotiable; the store transaction happens outside the child play loop.
2. **One-time non-consumable content unlock:** A–F free, A–Z unlocked from Parent Corner. Purchase and restore require network access, so the product must be described as “core play works offline,” not “100% offline.” A Hive entitlement may cache access but should not be treated as the authoritative proof of purchase.
3. **AdMob:** Defer unless revenue testing proves it necessary and a fresh SDK/policy/legal review approves it. Do not use banners in continuous-touch play, launch interstitials, automatic interstitials, or child-triggered rewarded ads.

If AdMob is later approved, the currently documented Flutter configuration is:

```dart
final config = RequestConfiguration(
  tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
  maxAdContentRating: MaxAdContentRating.g,
);

await MobileAds.instance.updateRequestConfiguration(config);
await MobileAds.instance.initialize();
```

The global configuration must be applied before SDK initialization and before any request. This alone does not establish compliance. The exact plugin version, Families self-certification status, mediation sources, permissions, data disclosures, test IDs, format, placement, and then-current API must be rechecked before every release. Google is transitioning age-treatment APIs, while the current Flutter guide still documents `TagForChildDirectedTreatment`; do not invent an unsupported replacement.

## Analytics Plan

- **Key product metric:** `trace_completion_rate = trace_completed / trace_started`
- **Usability gate:** Most supervised children aged 3–5 should complete one simple letter after a demonstration without adult touch assistance
- **Repeat-use signal:** The child voluntarily selects another letter or replays a completed letter

Local, aggregate-only events/counters:

- `app_opened`
- `session_started`
- `letter_selected`
- `trace_started`
- `trace_completed`
- `trace_restarted`
- `trace_abandoned`
- `hint_shown`
- `audio_replayed`
- `parent_gate_attempted`
- `parent_gate_passed`
- `progress_reset`
- `local_error`

Do not attach identifiers, free text, raw touch coordinates, or precise timestamps. Supervised/debug builds may expose a read-only local counter panel so the tester can record results; remove that panel from production. Measure retention separately as a parent-observed return on a later supervised test day rather than storing a child activity calendar. Pair the counters with structured observation notes collected outside the app, and do not add analytics SDKs merely to obtain dashboards.

## Technical Plan

- **Project base:** Treat the current KidsLand Flutter scaffold as the fresh app base; reuse only after this reduced scope is accepted
- **Tentative Android application ID:** `com.childhood.kidsland` (confirm ownership and uniqueness before the first Play upload; do not change it in task 1)
- **Initial version:** `0.1.0+1` for closed testing
- **Minimum Android:** API 23 (assumption; verify against the final dependency/device matrix)
- **Target Android:** The current Google Play-required target API at release time
- **State management:** Small explicit Dart state machines/controllers with `ValueNotifier` or `ChangeNotifier`; no app-wide state package in the first slice
- **Routing:** Basic Flutter Navigator routes for Home, Picker, Trace, and Parent Corner
- **Folder structure:** Feature-first (`core`, `features/tracing`, `features/parent`, `data`, `assets`)
- **Local storage:** Hive repositories with schema versioning and migration/reset tests
- **Services:** Asset catalogue, local audio, progress repository, local metrics, parental gate, and bounded local error log
- **Environment configuration:** No secrets or production ad IDs. If monetization is added later, IDs must be build-time environment/flavor values and test IDs must be enforced in debug builds.
- **Android backup configuration:** Disable/exclude Hive, preferences, files, databases, and every other app-data domain from cloud backup and device transfer, then inspect the merged release manifest and backup rules
- **Asset governance:** Keep source/license/attribution records for every path, font, sound, and voice recording; do not ship scraped media

## Testing Plan

- **Unit tests:** Segment interpolation; hit-corridor math; checkpoint order; completion threshold; reset/retry; Hive serialization/migration/reset; local counter aggregation; gate challenge generation
- **Widget tests:** Home → picker → trace flow; successful trace; off-path feedback; celebration; app relaunch persistence; inaccessible Parent Corner without gate; reset confirmation
- **Golden/visual checks:** Small phone and 7–10 inch tablet layouts, large targets, landscape/portrait policy, high text scale
- **Manual tests:** Real child-sized touch behavior under parent supervision, multi-touch rejection, audio latency/lifecycle, rapid taps, back navigation, app pause/resume, low-end device frame pacing
- **Offline tests:** Fresh launch after installation in airplane mode, every tracing action, persistence across restart, parent settings/reset
- **Monetization tests:** Not applicable in version 1; if added later, use test IDs only and verify child-directed configuration before SDK initialization
- **Accessibility/developmental checks:** Minimal reading, voice and visual cues, color not used as the only signal, no timer or punishment, large consistent controls
- **Release smoke test:** Clean install → trace A → save → restart → progress visible → enter gate → reset → verify clean state
- **Human review:** A preschool educator/parent reviews letter formation and audio; parents supervise usability tests; a policy/privacy reviewer checks the final dependency and Play Console declarations

## Play Store Plan

- **Category:** Education
- **Target audience for reduced MVP:** Ages 5 & Under; do not select adult groups merely because Parent Corner exists
- **Short description draft:** Trace uppercase letters with gentle audio and rewards—fully offline.
- **Full description draft:** KidsLand: Letter Tracing is a calm preschool activity for ages 3–5. Children choose a letter, follow large guided strokes, hear the letter, and celebrate completion. No account, ads, timer, or internet connection is required. Progress and settings stay on the device, while parent-only controls provide privacy information and a full local reset.
- **Screenshot plan:** Child Home, Letter Picker, tracing in progress, completion celebration, Parent Corner
- **Feature graphic:** One child-safe character plus a large traced letter; do not advertise deferred games
- **Privacy policy:** Required; host a public policy and bundle the full read-only policy so it is directly accessible from Home and Parent Corner, with the external browser link as an optional parent-gated convenience
- **Data safety:** Complete the form even when declaring no collection/sharing; audit every transitive SDK and permission against the final artifact
- **Content rating:** Complete the IARC questionnaire accurately; no violence, social content, gambling, location, or user communication
- **Ads disclosure:** “Contains ads: No” for version 1
- **External links:** Parent-gated only; the bundled read-only privacy notice is not gated
- **Closed testing:** Use parent-supervised family testing, record no child identifiers in the app, and satisfy the then-current Play Console testing requirement for the developer-account type
- **Listing language:** Avoid “All-in-One,” “ASMR,” coloring, memory, or balloon claims until those activities actually ship

## Current Policy Checkpoint

This is a planning review, not legal advice. Recheck the rules immediately before SDK integration and store submission.

- A child-only app must accurately declare its target audience and comply with Google Play Families requirements. It must not request location permission, collect/use/transmit precise location, or transmit AAID, SIM/build serial, BSSID, MAC, SSID, IMEI, or IMSI. On Android API 33+ a solely child-directed app should not request `AD_ID`.
- Any future ads require a current Families self-certified SDK/version, non-personalized treatment, child-appropriate content, compliant formats, and accurate SDK data disclosures. A parental gate does not waive these rules.
- Google Play requires a Data safety form and privacy-policy link even when the app declares that it collects no user data.
- Under COPPA, a fixed arithmetic navigation gate is not verifiable parental consent. The proposed no-network build, including explicit Android backup/transfer exclusions, keeps progress and metrics on-device and avoids the principal online-data collection risk in this MVP.

Official references checked on 2026-08-07:

- [Google Play Families Policy](https://support.google.com/googleplay/android-developer/answer/9893335?hl=en)
- [Google Play target audience guidance](https://support.google.com/googleplay/android-developer/answer/9867159?hl=en)
- [Families self-certified ads SDK program/list](https://support.google.com/googleplay/android-developer/answer/12955712?hl=en)
- [Google Play Data safety guidance](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en)
- [Official Flutter Mobile Ads targeting guide](https://developers.google.com/admob/flutter/targeting)
- [Android Auto Backup and transfer controls](https://developer.android.com/identity/data/autobackup)
- [FTC COPPA FAQ](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions)
- [Current COPPA Rule, 16 CFR Part 312](https://www.ecfr.gov/current/title-16/chapter-I/subchapter-C/part-312)

## Risks

- **Product risk:** Ages 2–6 span very different motor and cognitive abilities, and “all-in-one” is not a differentiator without several polished modes.
- **Technical risk:** Forgiving path validation must tolerate sparse touch events and varied finger sizes without accepting random scribbling.
- **Content risk:** Correct letter formation, pronunciation, audio quality, and asset licensing require human review.
- **Monetization risk:** Child-directed ads have low UX tolerance, strict format/data rules, and conflict with literal offline operation.
- **Policy risk:** A single unreviewed SDK, permission, identifier, ad creative, link, or inaccurate Play Console answer can invalidate the child-safe claim.
- **Scope risk:** Each deferred activity is a separate engine and must not be smuggled into the tracing MVP.
- **Performance risk:** Audio and CustomPainter feedback must remain smooth on low-end family devices.

### Cut order if tracing still grows too large

1. Release the supervised build with A–F only; do not create all remaining assets before the engine is validated.
2. Remove the progress visualization and keep only completion checkmarks.
3. Remove haptics and nonessential celebration particles; retain tracing, audio, and a simple success state.

## First Codex Implementation Task

The reduced plan is clear enough for one implementation task, but the original four-game plan is not.

### Goal

Build an ad-free, offline vertical slice for tracing uppercase **A** in the current Flutter scaffold, proving the input model, completion feedback, and local persistence before producing more letter assets.

### Inspect first

- `pubspec.yaml`
- `lib/`
- `test/`
- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`
- Existing asset folders and licenses, if any
- Current dirty Git state; preserve unrelated `.idea` changes

### Expected output

- A minimal KidsLand child Home → Letter A Trace flow
- An immutable, explicitly test-only letter-A stroke definition and testable geometry/controller layer separate from CustomPainter; obtain educator/parent approval before reusing its conventions for A–F
- Forgiving ordered checkpoints with interpolation between pointer samples
- Visual start cue, on-path glow, gentle off-path hint, reset, and completion overlay
- A bundled test-safe local audio hook; do not claim final pronunciation until the licensed recording is reviewed
- Hive persistence for letter-A completion and sound preference, with schema/reset handling
- Explicit Android backup and device-transfer exclusions for all local app data, verified in the merged release manifest
- Focused unit/widget tests and a short asset-license note

### Do not change or add

- No Firebase, AdMob, billing, analytics SDK, network permissions, login, profiles, or cloud code
- No numbers, coloring, drawing, memory match, balloon mode, reward economy, or elaborate animation system
- Do not change the Android application ID or iOS bundle ID until the tentative identifier is approved
- Do not overwrite or clean unrelated user/IDE changes

### Verification

```text
flutter pub get
flutter analyze
flutter test
```

Human verification after the automated checks: test touch tolerance and airplane-mode restart on one physical phone and one tablet or tablet emulator.

### Human review required

- Approve the reduced tracing-only direction and ages 3–5 focus
- Approve product/application identifiers before store setup
- Validate letter-A stroke order, tolerance, pronunciation, child usability, and asset licensing before expanding A–F

## Start Decision

**Choose: Reduce scope.**

The original four-game version fails the checklist’s small-MVP gate and conflicts with its own “100% offline” requirement if AdMob is included. The reduced ad-free tracing plan passes the clarity, flow, storage, Firebase, monetization, analytics, policy-risk, and first-task gates under the five stated assumptions.

Implementation may start with the letter-A vertical slice only after those assumptions are accepted. Expansion to A–F depends on touch usability; expansion to A–Z depends on A–F validation. The other three games remain roadmap items with separate planning gates.
