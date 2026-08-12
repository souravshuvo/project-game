# Rooftop Rain Garden Release Checklist

Status: production v1 files are prepared, but release readiness is not verified
until the signed build and manual QA are completed.

This pass intentionally did not run build, run, pub get, emulator, install, or
publish commands.

## App Identity

- App name: Rooftop Rain Garden
- Launcher label: Rain Garden
- Android application id: `com.childhood.rooftopraingarden`
- Version: `1.0.0+1`
- Main v1 promise: plant, water, grow, harvest, sell, upgrade, save,
  and return loop
- Production content: 8 crops, 5 upgrades, 6 garden levels, all 9 plots
- Ads: AdMob banner plus capped interstitials at non-gameplay transitions
- Analytics: gameplay, difficulty, retention, and ad-impact events

## Blocking Checks Before Upload

- Create the upload keystore outside source control.
- Copy `android/key.properties.example` to `android/key.properties` and fill in
  real upload-key values.
- Confirm `android/key.properties` and keystore files remain ignored by git.
- Refresh Flutter package resolution after the production package-name change.
- Produce a signed release artifact.
- Install the release artifact on at least one physical Android phone.
- Verify the app launches cold from the launcher.
- Verify no debug signing is used for release.
- Verify the Play Console package name is final before the first upload.
- Complete the Play Data safety form.
- Add a hosted privacy policy URL in Play Console.
- Confirm the same privacy text is reachable inside the app.
- Add final Firebase Android/iOS config before expecting analytics delivery.
- Keep AdMob test IDs for debug/internal QA, and pass production IDs only for
  release candidates intended to request live ads.
- Confirm `USE_PROD_ADS=true` release builds include every required production
  banner/interstitial ID.
- Confirm interstitials only appear from natural transitions, never during
  active plot interaction.
- Configure app-ads.txt if required by the final AdMob account setup.
- Prepare actual gameplay screenshots only.

## Manual QA

- Fresh install starts with 8 coins, 4 seeds, 4 water, and 4 unlocked plots.
- Plant Sun Sprouts on an empty unlocked plot.
- Watering starts the crop timer and consumes 1 water.
- Dry crops do not grow until watered.
- Sun Sprouts become ready after about 20 seconds.
- Harvest moves the crop into the crate and clears the plot.
- Selling the crate adds coins and clears crate storage.
- Buying seeds costs 8 coins and adds 4 seeds.
- Upgrades progress from level 1 to level 6.
- The first upgrade costs 20 coins, unlocks 6 plots, unlocks Rain Beans and
  Amber Leaf, and raises water cap to 6.
- Later upgrades unlock Moon Mint, Cloud Pepper, Glass Berry, Starfruit Vines,
  Golden Thyme, all 9 plots, and water cap 10.
- Manual save shows a saved confirmation.
- Closing and reopening restores coins, seeds, water, plots, crate, and upgrade.
- Returning after enough time shows offline progress and ready crops.
- Airplane mode does not break core play.
- Ad load failure or no network does not block planting, watering, harvesting,
  saving, or restart.
- Banner space does not overlap the grid, HUD, action panel, sheets, or active
  buttons on small screens.
- Interstitial frequency caps prevent repeated ads during quick menu visits.
- Repeated rapid taps do not duplicate harvests, coins, or upgrades.
- Small-screen portrait layout has no overlapping text.
- The Privacy button opens readable local privacy text.

## Store Listing QA

- Screenshots show real gameplay from this build.
- Store copy does not mention animals, crafting, town, quests, social features,
  cloud sync, events, rewards, rankings, or modes that are not in v1.
- Feature graphic and icon use original Rain Garden visuals only.
- No copied names, branding, crops, characters, UI, maps, screenshots, music, or
  assets from other games.

## Release Recommendation

Use internal testing first. Move to closed testing only after signed release
build, install, save/restore QA, privacy policy URL, Data safety, and real
screenshots are complete.
