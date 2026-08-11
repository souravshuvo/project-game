# Privacy And Data Safety Notes

Trail Arena v1 is offline and does not include ads, analytics SDKs, login,
cloud sync, purchases, location, camera, microphone, contacts, or multiplayer.

Current data behavior:

- Stores best score and games played locally with `shared_preferences`.
- Does not transmit gameplay data off device.
- Uses debug/profile internet permission only for Flutter development tooling.
- Main release manifest does not declare internet or dangerous permissions.

Play Console guidance:

- Ads declaration: `No`, until an ad SDK is added.
- Data collection: no user data transmitted off device in v1.
- Privacy policy is still required for Play release and should state the above.
- Update this document before adding analytics, ads, crash reporting, cloud sync,
  account features, or purchases.
