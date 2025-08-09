# GEG VPN (Android, Flutter)

Production-ready VPN app with subscriptions, Firebase auth, AdMob monetization, and a daily rewarded free hour.

## Prerequisites
- Flutter (latest stable)
- Firebase project (Android app added) and Google services configured
- Google Play Console app with Active Billing and Subscription products
- Valid OpenVPN servers (store `.ovpn` text, username, password in Firestore `servers` collection)

## Configure
1. Run `flutterfire configure` to generate `firebase_options.dart` and add `google-services.json` to `android/app/`.
2. Replace AdMob IDs using Dart defines when building:
   - `--dart-define=BANNER_AD_UNIT_ID=ca-app-pub-xxx/yyy`
   - `--dart-define=REWARDED_AD_UNIT_ID=ca-app-pub-xxx/zzz`
3. Create Firestore security rules as needed and collections:
   - `users/{uid}`: `isSubscribed: bool`, `subscriptionExpiry: Timestamp`, `lastFreeAccessDate: Timestamp`
   - `servers/{autoId}`: `{ name, country, ovpn, username, password, enabled: true }`
4. Deploy Cloud Functions in `functions/` and set Google Play API access (link service account with Android Publisher role to your Play Console).

## Build
```
flutter build appbundle --dart-define=BANNER_AD_UNIT_ID=... --dart-define=REWARDED_AD_UNIT_ID=...
```

## Notes
- Subscribed users never see ads.
- Free access available once per day, enforced via Firestore `lastFreeAccessDate`.
- One-hour session schedules a background end task; for strict enforcement across process death, consider a native foreground service timer.