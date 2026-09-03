# AOP Sites — Development Handover Report

## 1. What this app is

**AOP Sites** is a Flutter mobile application for Afghanistan's Administrative Office of the President. It is an information and service gateway, not an authenticated citizen-account app. Its primary content comes from government web APIs; it also contains device utilities for Qibla direction and local weather.

Supported interface languages are English, Persian/Dari, and Pashto. Persian and Pashto are rendered right-to-left. The app has light/dark mode, a splash screen, connection-state messaging, loading/error states, and a persistent bottom navigation bar.

**Current Android package ID:** `com.example.aop_sites`.

## 2. User journey and navigation

1. The splash screen displays for about two seconds.
2. On first launch, the user chooses Pashto, Persian, or English. The choice is stored locally.
3. Later launches go directly to the language-specific home screen.
4. Home has three persistent tabs:
   - **Home:** feature grid.
   - **Website:** the matching AOP public website, loaded inside an in-app web view.
   - **Contact:** WhatsApp, email, and web-form contact options.
5. The home grid links to news, vacancies, ministries, directorates, provinces, public services, Qibla, and weather.

Named route definitions live in `lib/core/config/routes.dart`. The entry point is `lib/main.dart`.

## 3. Feature inventory

| Area | What the user can do | How it works |
|---|---|---|
| Language | Select English, Persian/Dari, or Pashto | Choice is saved with `SharedPreferences`; the Riverpod theme state controls language and RTL direction. |
| Theme | Toggle light/dark mode | Boolean preference saved locally; theme is rebuilt through `ThemeNotifier`. |
| AOP website | Browse AOP's language-specific website | `webview_flutter` loads the selected AOP URL in the app. |
| News | Browse, paginate, search, open details, share, and save news | Reads `https://aop.gov.af/api/v1/news`; language is supplied through `Accept-Language`; saved articles are JSON stored locally. |
| Saved news | Review/remove locally bookmarked news | Uses `SharedPreferences` only; it works offline after an item was saved. |
| Ministries | Browse, search, paginate, and view ministry details | Reads `government/ministries` through the AOP API. |
| Independent directorates | Browse, search, paginate, and view details | Reads `government/independent-directorates` through the AOP API. |
| Provinces | Browse, search, paginate, and view details | Reads `government/provinces` through the AOP API. |
| Job opportunities | Browse vacancies, view detail, search/filter/sort, share, and apply | Reads `https://arcsa.aop.gov.af/api/vacancies`; applying opens a web URL or email client externally. |
| Public services | Open government service links, including passport services | Opens selected government pages in the app's web view. |
| Contact / feedback | Open WhatsApp, compose an email, or open a feedback form | Uses `url_launcher`; the configured email is `info@aop.gov.af`; WhatsApp target is `+93744724357`. |
| Qibla compass | Find Kaaba bearing, relative compass angle, and distance | Requests location, obtains GPS position, listens to compass heading, then calculates bearing and distance to Kaaba. |
| Weather and air quality | Show present weather and optional AQI for device location | Requests location; calls OpenWeatherMap. If location is unavailable it falls back to Kabul coordinates. |
| Connectivity UI | Show offline/network-error presentation | Uses `connectivity_plus` to react to transport availability. It does not prove the internet/API itself is reachable. |

## 4. Architecture and data flow

The project uses a feature-first structure:

```text
lib/
  core/       shared configuration, networking, preferences, theme/connectivity
  features/   independent business areas; usually data/models, services, providers, UI
  shared/     reusable screens and widgets
```

- **UI:** Flutter Material widgets.
- **State management:** Riverpod (`Provider`, `StateNotifierProvider`, `FutureProvider`, `StreamProvider`).
- **Networking:** `http`, `ApiClient`, `BaseApiService`, plus some direct HTTP services.
- **Models:** manually decoded JSON classes in each feature's `data/models` folder.
- **Local persistence:** `SharedPreferences` stores language, theme, and saved-news data.
- **No sign-in, user profile, remote database write, push notification, analytics, or crash reporting** was found in the codebase.

## 5. External systems

| System | Purpose | Endpoint/domain |
|---|---|---|
| AOP content API | News, ministries, directorates, provinces | `https://aop.gov.af/api/v1` |
| ARCSA content API | Vacancies and vacancy detail | `https://arcsa.aop.gov.af/api` |
| AOP web sites/forms | Website, public-service pages, feedback forms | `aop.gov.af` |
| Ministry of Interior passport site | Passport-service link | `passport.moi.gov.af` |
| OpenWeatherMap | Current weather and air pollution | `api.openweathermap.org` |
| Device location/sensors | Weather location and Qibla computation | Android/iOS platform APIs via Flutter plugins |

## 6. Permissions and platform behavior

### Android

The manifest requests internet, coarse/fine location, camera, and legacy external-storage permissions. Location is used for Qibla and weather. The code reviewed does not show an active camera or file-download feature, so those permissions should be confirmed as genuinely required.

The compass hardware feature is declared as **required**. Devices without a compass may therefore be filtered from installation even though the code already contains a “compass unavailable” path.

### iOS

`Info.plist` includes location-use messages for Qibla. It does not currently show a camera-use description, even though Android declares camera permission.

## 7. Security and production risks

These should be addressed before a public production release.

1. **High — SSL certificate validation is bypassed for listed government domains.** `SslConfig.allowSelfSignedCertificates` is `true`; the custom client accepts an invalid certificate when the host matches a trusted domain. This reduces transport security and should be disabled in production unless certificate pinning or a formally approved trust model is implemented.
2. **High — the OpenWeatherMap API key is committed in `weather_config.dart`.** A mobile-app key can be extracted from the APK. Restrict/rotate it and move weather calls behind your own backend or a secure configuration process.
3. **Medium — `usesCleartextTraffic="true"` allows HTTP traffic.** The app should require HTTPS unless there is a documented dependency that cannot use TLS.
4. **Medium — requested Android permissions are broader than verified usage.** Camera and read/write external storage should be removed if unused. Duplicate location/camera declarations should also be cleaned up.
5. **Medium — release signing is not configured.** The release build currently uses the debug signing key. A client release needs a separate keystore, protected credentials, and a proper signing configuration.
6. **Medium — the package ID remains an example ID.** `com.example.aop_sites` should be changed to a client-owned unique ID before Play Store publishing.
7. **Medium — remote web pages run inside the app web view.** Define navigation, download, JavaScript, external-link, and error-page policies; use a domain allow-list where appropriate.

## 8. Maintainability findings

- Two different API bases are intentional but easy to confuse: most government directory/news APIs use `aop.gov.af/api/v1`; vacancies use `arcsa.aop.gov.af/api`.
- News uses a direct `http` service, while other directory features inherit `BaseApiService`; moving all API access behind one service pattern would simplify retries, caching, logging, and testing.
- Detail lookups for ministries, directorates, and provinces fall back to loading every API page if the direct detail request fails. This can become slow and expensive with more content.
- Job search is local only after the full vacancy list is downloaded.
- `SharedPreferences` is appropriate for language/theme and a small bookmark list, but not for larger offline content or user data. SQLite/Drift/Hive would be a better future cache if offline browsing is required.
- The code is already warning that Kotlin/Gradle settings and several plugins need future migration. The current build succeeds, but dependencies should be upgraded deliberately before a Flutter/Android toolchain upgrade.
- No `test/` or `integration_test/` directory was found. There is no automated regression suite in the repository.

## 9. Current build status

Verified during this handover:

- Android debug build completed successfully.
- APK was installed on the Android emulator.
- The application process started and `MainActivity` was the resumed foreground activity.

Build changes that enabled this machine:

- Project uses installed Android NDK `30.0.16138531`.
- Gradle uses the Windows certificate store to reach dependency repositories.
- `share_plus` was updated to `12.0.2` and the three calls were migrated to `SharePlus.instance.share(ShareParams(...))`.

`flutter analyze` was not completed in this audit because the local Codex execution quota blocked the command. Run it locally before a release.

## 10. Recommended development roadmap

### First: stabilise and secure

1. Replace example application ID and configure a client-owned release keystore.
2. Remove SSL bypass in production; fix server certificate chains or use certificate pinning if required.
3. Rotate the exposed weather key and remove it from source control.
4. Remove unused/duplicate permissions and disable cleartext traffic.
5. Correct visibly garbled Persian/Pashto strings and Android/iOS display-name encoding, if they appear that way in the source editor and device.

### Next: make changes safer

1. Add unit tests for JSON models, language mapping, Qibla calculations, URL formatting, and API error conversion.
2. Add integration tests for first launch, language selection, news save/remove, navigation, offline UI, denied location permission, and job application links.
3. Use one API client abstraction, centralized environment configuration, structured logging, and user-safe error telemetry.
4. Add an API contract document for the client: endpoint, request parameters, response model, supported languages, pagination, errors, and owner.

### Then: product enhancements

1. Offline cache with expiry for news/directories/jobs.
2. News categories, notifications, and deep links.
3. Better job filters and saved job opportunities.
4. Weather forecast, location chooser, and refresh/cache timestamp.
5. Map view for provinces/directorates if the API supplies coordinates.
6. An accessibility pass: semantic labels, text scaling, contrast, RTL visual testing, and keyboard navigation.

## 11. Useful commands

```powershell
flutter run -d emulator-5554
flutter analyze
flutter test
flutter build appbundle --release
```

Use Hot Reload (`r`) in the `flutter run` terminal while editing Dart files. For Android or package/plugin configuration changes, stop and run the app again.
