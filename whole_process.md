# AOP Sites: complete run-time process

This is a project-specific guide to what happens from `flutter run` until a person uses each part of the app. It is written from the source as it exists now (September 2026), rather than as an ideal architecture document.

## 1. The project in one picture

```text
flutter run
  -> Flutter tool chooses emulator and runs Gradle
  -> Android launches MainActivity (a FlutterActivity)
  -> Flutter engine starts Dart isolate and calls lib/main.dart:main()
  -> SharedPreferences services initialise
  -> ProviderScope creates Riverpod container
  -> MyApp builds MaterialApp
  -> SplashScreen
  -> LanguageScreen or HomeScreen
  -> feature screen -> Riverpod provider/notifier -> service -> HTTP/device API
  -> model/state update -> ref.watch rebuilds the visible widgets
```

The app is called **AOP Sites** (`aop_sites`). It is a Flutter Android/iOS client with Riverpod state management. Its main content is supplied by remote APIs; only selected language, theme, and saved news are kept on the device.

## 2. What `flutter run` actually does

Run this in the repository root:

```powershell
flutter pub get       # only needed after a fresh clone or pubspec change
flutter devices       # lists physical devices/emulators
flutter run -d <id>   # builds and installs on one selected emulator
```

`flutter run` does not just execute `main.dart` directly. Flutter first reads `pubspec.yaml`, resolves packages from `pubspec.lock`, creates the generated tool/plugin files under `.dart_tool`, then uses the selected platform's build system.

For the Android emulator, Flutter invokes Gradle using the configuration in `android/settings.gradle` and `android/app/build.gradle`. The Flutter Gradle plugin packages the Dart/Flutter assets and native plugin registrations into an Android debug APK, installs it, then attaches the development tool to it. In the normal debug mode it also supports:

- **hot reload** (`r`): injects changed Dart code and asks the widget tree to rebuild while preserving much state;
- **hot restart** (`R`): restarts the Dart isolate, so `main()` runs again and in-memory Riverpod/widget state is lost; and
- full stop/start: Android launches the activity from scratch.

The active Android identity is `com.example.aop_sites`, min SDK is inherited from Flutter's current default, target SDK is 34, and the checked-in release build currently uses the debug signing key. That must be changed before a real Play Store release.

## 3. Android/native launch to Dart

Android reads `android/app/src/main/AndroidManifest.xml`. Its launcher intent starts:

```text
android.app.Activity launcher intent
  -> com.example.aop_sites.MainActivity
  -> FlutterActivity (no custom Kotlin behaviour)
  -> Flutter engine + generated plugin registration
  -> Dart main() in lib/main.dart
```

`MainActivity.kt` deliberately has no methods: `FlutterActivity` provides the standard Flutter embedding. Packages such as `shared_preferences`, `geolocator`, `webview_flutter`, `url_launcher`, `connectivity_plus`, and `flutter_compass` register native Android implementations during startup. The generated registrant in `.dart_tool/flutter_build/` is build output—do not edit it.

The manifest declares internet, coarse/fine location, camera, external-storage permissions, and a required compass sensor. Location and compass are needed for weather/Qibla. Note that a required compass sensor can prevent installation on devices that do not report one.

## 4. Dart startup: exact order

The entry point is [`lib/main.dart`](lib/main.dart).

1. `main()` calls `WidgetsFlutterBinding.ensureInitialized()`. This must occur before plugin code such as `SharedPreferences` is used.
2. It awaits `LanguageService.init()` and `ThemeService.init()`. Both obtain a `SharedPreferences` instance.
3. `runApp(const ProviderScope(child: MyApp()))` creates the root Flutter widget and the Riverpod provider container.
4. `MyApp.build()` watches `connectivityServiceProvider`, which constructs `ConnectivityService` and begins listening to `connectivity_plus` changes.
5. It watches `themeNotifierProvider`. `ThemeNotifier.build()` initially returns light/English state, then asynchronously reads the stored theme and selected language and updates its state. Every watcher rebuilds when that update arrives.
6. `MaterialApp` is built with `home: SplashScreen()`, `Routes.generateRoute`, Material localizations, the Vazirmatn font/theme, RTL or LTR direction, and the global `NetworkErrorOverlay` wrapper.

## 5. First screen and language decision

`SplashScreen` is a `StatefulWidget`. Flutter creates its state, calls `initState()`, then `_checkLanguage()`:

```text
show splash for 2 seconds
  -> LanguageService.getSelectedLanguage()
  -> no saved value: replace splash with LanguageScreen
  -> pashto/persian/english: replace splash with that language's named home route
```

`LanguageScreen` animates the three language buttons. On a selection it:

1. prevents a double tap and shows `LoadingManager`'s overlay;
2. writes `selected_language` to SharedPreferences;
3. calls `ThemeNotifier.setLanguage`, changing Riverpod state;
4. waits briefly for the transition; and
5. uses `Navigator.pushReplacementNamed` to enter `HomeScreen`.

Persian and Pashto cause RTL layout and locale `fa`; English uses LTR and `en`. API services separately map app names to HTTP headers: English `en`, Persian `dr`, Pashto `pa`.

### The precise answer to “why did the language screen show only once?”

The language picker is the app's **first-run/onboarding screen**. It is not Android cache and it is not controlled by Flutter navigation history. Its state is a persistent value in the app's local **SharedPreferences** storage.

| What you want to find | Exact address | Exact name / job |
| --- | --- | --- |
| the initial screen decision | `lib/features/splash/presentation/screens/splash_screen.dart` | `_SplashScreenState.initState()` calls `_checkLanguage()` |
| the two-second wait and branch | same file | `_checkLanguage()` waits, calls `LanguageService.getSelectedLanguage()`, then opens `LanguageScreen` if it gets `null` |
| the picker UI | `lib/features/language/presentation/screens/language_screen.dart` | `LanguageScreen` and `_handleLanguageSelection()` |
| the save operation | `lib/core/services/language_service.dart` | `LanguageService.setSelectedLanguage(language)` |
| the physical saved key | same file | SharedPreferences key: `selected_language` |
| screen routing | `lib/core/config/routes.dart` | `Routes.generateRoute()` |

On the very first app launch, `selected_language` does not exist, so `getSelectedLanguage()` returns `null` and the splash screen replaces itself with `LanguageScreen`. When a person chooses a language, `_handleLanguageSelection()` calls:

```dart
await LanguageService.setSelectedLanguage(language);
```

That writes `selected_language = pashto`, `persian`, or `english`. On later launches splash finds that value and replaces itself with the corresponding home route. Theme selection is stored separately as `theme_variant` (and the older `is_dark_mode`) in `ThemeService`.

### Make the language picker appear again

For an Android emulator, clear this app's **data**. This resets language, theme, saved news, and every other SharedPreferences value for this app; it does not clear data for other applications.

```powershell
flutter devices
adb -s <emulator-id> shell pm clear com.example.aop_sites
flutter run -d <emulator-id>
```

The expected command response is `Success`. The Android Settings alternative is: **Settings → Apps → AOP Sites → Storage → Clear data**. Uninstalling the app from the emulator and running `flutter run` again has the same first-run effect. A hot reload, hot restart, or simply closing the app does **not** remove SharedPreferences, so it will not bring the language picker back.

If you only want to reset the language in code (and keep saved news/theme), add a deliberate development-only method to `LanguageService` that calls `_prefs?.remove(_languageKey)`, then restart the app. Do not manually edit `.dart_tool` or generated plugin files: they do not contain the user's persisted setting.

### A simple explanation to give in a project introduction

> “The application begins in `main.dart`. It shows a splash screen, then checks the local SharedPreferences key named `selected_language`. On a new installation the key is empty, so it opens the first-run language screen. Once the user selects a language, we save that value locally. From then on the splash screen reads it and opens the home screen directly. To demonstrate the first-run flow again, I clear this application's data on the emulator.”

## 5.1 Read the running app in source order

Use this as a searchable route map during a demo. In VS Code, press `Ctrl+P`, paste an address, then use `Ctrl+F` for the class/function name.

```text
1. lib/main.dart
   main() -> WidgetsFlutterBinding.ensureInitialized()
          -> LanguageService.init()
          -> ThemeService.init()
          -> runApp(ProviderScope(child: MyApp()))
   MyApp.build() -> MaterialApp(home: SplashScreen())

2. lib/features/splash/presentation/screens/splash_screen.dart
   SplashScreen -> _SplashScreenState.initState() -> _checkLanguage()
   _checkLanguage() -> LanguageScreen OR Navigator.pushReplacementNamed(...home route)

3. lib/features/language/presentation/screens/language_screen.dart
   LanguageScreen -> _handleLanguageSelection(route, language)
   -> LanguageService.setSelectedLanguage(language)
   -> ThemeNotifier.setLanguage(language)
   -> Navigator.pushReplacementNamed(route)

4. lib/core/config/routes.dart
   Routes.generateRoute() -> HomeScreen / NewsScreen / WeatherScreen / etc.

5. lib/features/home/presentation/screens/home_screen.dart
   HomeScreen -> card onPressed -> NavigationHelper.navigateToRouteWithLoading()
   -> Navigator.pushNamed(routeName)

6. lib/features/<feature>/presentation/screens/<screen>.dart
   screen watches a provider -> provider/notifier calls service -> service calls API/device
```

For example, searching `Routes.weather` takes you from the home button to `WeatherScreen`; searching `weatherDataProvider` takes you from that UI to `WeatherNotifier`, then `WeatherService.getCurrentWeather()`. The same pattern works for `newsNotifierProvider`, `jobNotifierProvider`, `ministryNotifierProvider`, `provinceNotifierProvider`, `independentDirectorateNotifierProvider`, and `qiblaNotifierProvider`.

## 6. Navigation and screen map

`MaterialApp.home` always starts at splash. Named routes are handled in [`lib/core/config/routes.dart`](lib/core/config/routes.dart).

| User destination | Named route | Screen / outcome |
| --- | --- | --- |
| language picker | `/language` | `LanguageScreen` |
| any selected-language home | `/english`, `/persian`, `/pashto` | `HomeScreen` |
| News / saved news | `/news`, `/saved_news` | news list / local bookmarks |
| Jobs | `/job-opportunities` | job list and detail |
| Ministries | `/ministries` | list and detail |
| Independent directorates | `/independent-directorates` | list and detail |
| Provinces | `/provinces` | list and detail |
| Qibla | `/qibla` | location and sensor-driven compass |
| Weather | `/weather` | weather / air-quality screen |
| URL / service / feedback | `/web-view`, `/service`, `/feedback` | require route arguments |

Home's cards use `NavigationHelper.navigateToRouteWithLoading`: it displays an overlay for 300 ms, hides it, then calls `Navigator.pushNamed`. The drawer pushes the selected named route directly. `push` adds a page to the navigation stack; `pushReplacement` removes the current page (used after splash/language selection).

`HomeScreen` contains the update carousel, menu cards, an app drawer, bottom navigation, a theme picker, and a draggable assistant widget. The carousel's live-stream and official-orders cards are placeholders; the announcement card is live data.

## 7. How Riverpod changes the UI

This project mostly uses these Riverpod patterns:

- `Provider`: supplies a service object, for example `newsServiceProvider`.
- `StateNotifierProvider`: supplies a mutable `AsyncValue<T>` state plus a notifier, for lists, weather, Qibla, and saved news.
- `FutureProvider` / `.family`: starts a one-time asynchronous request keyed by an argument, for example a detail item ID or announcement language.
- `StreamProvider`: exposes ongoing connectivity/Qibla streams.

In a `ConsumerWidget` or `ConsumerState`, `ref.watch(provider)` subscribes the widget and rebuilds it when the provider changes. `ref.read(provider.notifier)` calls an action without subscribing. Typical lifecycle:

```text
Screen initState/build watches notifier
  -> notifier sets AsyncLoading
  -> service fetches/parses data
  -> notifier sets AsyncData(value), or AsyncError(error, stackTrace)
  -> watched UI renders loading/data/error branch
```

`BaseListScreen` gives ministries, directorates, provinces, and jobs a scroll controller, search controller, pull-to-refresh, scroll-to-top control, and pagination trigger (within 200 px of the bottom). `BaseDetailScreen` provides detail-page directionality and scroll-to-top behavior.

## 8. Network and persistence paths

### Core API pipeline

The generic government list services (`MinistryService`, `IndependentDirectorateService`, `ProvinceService`) extend `BaseApiService`:

```text
screen -> notifier/service -> BaseApiService.getItems/getItemById
  -> ApiClient.get
  -> GET https://aop.gov.af/api/v1/<endpoint>?page=<n>&search=<query>
  -> 30 second timeout + JSON decode
  -> model response -> AsyncValue state -> UI
```

Endpoints are `government/ministries`, `government/independent-directorates`, and `government/provinces`. `ApiClient` sends JSON `Accept`/`Content-Type` and `Accept-Language`; HTTP or parsing failures become `ApiException`.

This codebase currently uses several hosts, so do not assume `UrlConfig` is the single source for every request:

| Feature | Remote source |
| --- | --- |
| jobs | `https://arcsa.aop.gov.af/api/vacancies` and `/vacancies/{uuid}` |
| ministries, directorates, provinces | `https://aop.gov.af/api/v1/...` |
| news | `https://aop.gov.af/api/v1/news` |
| home announcement | `https://it.arg.gov.af/api/announcements?locale=...` |
| weather/air quality | OpenWeatherMap URLs made by `WeatherConfig` |

News has remote paging/search/detail endpoints. Jobs load the remote list, then search and filters happen locally in `JobService`; a detail uses a UUID, with an ID/list fallback. Job application links are handed to `url_launcher` by `JobApplyService`. Detail pages can also open sites, call telephone links, and use the platform share sheet.

`SavedNewsNotifier` serializes selected news as JSON in the SharedPreferences `saved_news` string-list key. This is the feature's offline persistence; fetched news, jobs, and government lists are primarily in-memory state.

`ConnectivityService` reports transport availability (Wi-Fi/mobile/none) to `NetworkErrorOverlay` and screens. It is not a proof that an API host is reachable.

## 9. Device-service flows

### Weather

Opening Weather creates/watches `weatherDataProvider`; `WeatherNotifier` immediately calls `loadWeatherData()`.

```text
Geolocator checks service + permission
  -> permission granted: current high-accuracy location (10 s limit)
  -> unavailable/denied/error: Kabul fallback coordinates
  -> current weather request
  -> optional air-quality request (failure does not fail weather)
  -> WeatherData -> WeatherScreen widgets
```

The Weather screen can request permission and refresh. The OpenWeatherMap key/configuration is in `lib/core/config/weather_config.dart`; treat it as a secret in a production setup.

### Qibla

Opening Qibla creates `QiblaNotifier`. It initializes the singleton `QiblaService`, requests/checks location, gets a position, subscribes to `FlutterCompass.events`, and starts an accelerometer stream. Each compass heading calculates a Qibla bearing/distance from the Kaaba plus the relative angle, emits `QiblaModel` through a broadcast stream, and the notifier puts that into `AsyncValue`. The compass UI rebuilds as headings arrive. Permission denial, disabled location, or absent compass produces the relevant unavailable/error state.

### Web views and external actions

`WebViewScreen` hosts URLs in `webview_flutter`; file download/external actions use platform plugins. Android manifest permissions and the native plugin registrations are therefore part of these flows, even though their Dart calls look ordinary.

## 10. Important implementation notes for a maintainer

- `ThemeNotifier.build()` returns light/English before its asynchronous preference read completes. A launch can briefly render the default theme/language, then rebuild with the stored values.
- `BaseListScreenState.initState()` already calls `loadInitialData()`. The ministry, directorate, province, and job subclasses also call it in their own `initState()`, so those screens appear to make two initial load requests. Confirm with logs/network inspector before changing it, then retain only one call.
- `BaseApiService` and the News service use `https://aop.gov.af/api/v1`, while `UrlConfig` points to `https://arcsa.aop.gov.af`. Consolidate configuration before an environment migration.
- The Android manifest duplicates some permissions and has visibly mis-encoded comments/label text. Clean this carefully without removing permissions still required by Qibla, weather, or WebView/download behavior.
- `allowSelfSignedCertificates` is controlled by `SslConfig`. Certificate-bypass logic should stay restricted to explicitly trusted development hosts.
- `shared_preferences` is appropriate for language/theme/bookmarks, not credentials or API secrets.

## 11. Where to start when changing something

| Change wanted | First files to inspect |
| --- | --- |
| startup, theme, RTL, language | `lib/main.dart`, `core/providers/theme_provider.dart`, `core/services/language_service.dart` |
| route or new page | `core/config/routes.dart`, `home_screen.dart`, `shared/widgets/app_drawer.dart` |
| normal government list/detail | relevant `features/<feature>/data/{service,provider,model}` and `presentation/screens` |
| news/bookmarks | `features/news/data/services/news_service.dart`, `saved_news_provider.dart` |
| backend domain/endpoints | `core/config/url_config.dart`, `core/services/base_api_service.dart`, feature services |
| weather | `core/config/weather_config.dart`, `features/weather/` |
| Qibla/device permissions | `features/qibla/`, `android/app/src/main/AndroidManifest.xml` |
| Android package/build/release | `android/app/build.gradle`, manifest, `MainActivity.kt` |

## 12. Useful validation commands

```powershell
flutter analyze
flutter test
flutter run -d <emulator-id>
flutter build apk --release
flutter build appbundle --release
```

When testing end-to-end, test a fresh install (language picker), a returning install (saved language), no network, denied location, disabled location, unavailable compass/emulator sensors, each language/RTL layout, list search/paging/detail, saved-news persistence after restart, and the external URL/job-application paths.
