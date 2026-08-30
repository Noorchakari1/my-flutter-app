# AOP Sites

The AOP Sites mobile application is developed with Flutter for the Administrative Office of the President of Afghanistan. It provides a unified gateway to news, ministries, independent directorates, provinces, job opportunities, Qibla direction, and weather information.

## Features

- Support for English, Persian, and Pashto
- Right-to-left layout for Persian and Pashto
- News browsing and saved news
- Ministries, independent directorates, and provinces
- Search, detail pages, sharing, and external links
- Job opportunities with smart application-link detection
- Qibla compass using device location and sensors
- Weather and air-quality information based on the user's location
- Light and dark themes, offline-state handling, loading states, and error states

## Technology Stack

- Flutter and Dart
- Riverpod for state management
- Feature-first architecture with separate data, domain, and presentation layers
- REST API integration with `http`
- `geolocator`, `sensors_plus`, and `flutter_compass` for location and Qibla features
- OpenWeatherMap for weather and air-quality data

## Requirements

- Flutter SDK compatible with Dart `>=3.0.0 <4.0.0`
- Android SDK with minimum API level 21
- Xcode and CocoaPods for iOS builds
- Internet access for API requests

## Getting Started

```bash
git clone <repository-url>
cd aop_app
flutter pub get
flutter run
```

Run static analysis and tests with:

```bash
flutter analyze
flutter test
```

## Release Builds

```bash
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
```

Android build outputs are generated under `build/app/outputs/`.

## Configuration

Key project configuration files include:

- `lib/core/config/url_config.dart` — API and storage URLs
- `lib/core/config/routes.dart` — application routes
- `lib/core/config/weather_config.dart` — OpenWeatherMap settings
- `lib/core/config/ssl_config.dart` — SSL connection settings

API keys must not be committed to a public repository or embedded directly in production code. For production deployments, store the OpenWeatherMap key in environment-specific configuration, secure storage, or a secrets-management service.

The weather feature requires location access. Android permissions and the iOS location usage description are configured in the platform projects.

## Project Structure

```text
lib/
├── core/                 # Configuration, services, providers, and utilities
├── features/             # Main application features
│   ├── home/
│   ├── independent_directorates/
│   ├── job_opportunities/
│   ├── language/
│   ├── ministries/
│   ├── news/
│   ├── provinces/
│   ├── qibla/
│   ├── splash/
│   └── weather/
├── shared/               # Shared widgets, screens, and constants
└── main.dart             # Application entry point
```

## Additional Documentation

- [Project Cleanup Report](docs/CLEANUP_REPORT.md)
- [Weather Feature Documentation](docs/WEATHER_FEATURE.md)
- [SSL Handling Guide](docs/SSL_HANDLING.md)
- [Logo Implementation Notes](docs/LOGO_IMPLEMENTATION.md)

## License

This is a private project. Redistribution or reuse requires permission from the project owner.
