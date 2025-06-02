# Weather Feature

This feature provides current weather information including temperature, weather conditions, and air quality data for the user's location or a default location (Kabul, Afghanistan).

## Features

- **Current Weather**: Displays temperature, feels-like temperature, humidity, wind speed, pressure, and visibility
- **Weather Conditions**: Shows weather description with appropriate icons
- **Air Quality**: Optional air quality index (AQI) with PM2.5 and PM10 data
- **Location Support**: Uses user's current location or falls back to default location
- **Multilingual**: Supports English, Persian, and Pashto languages
- **Responsive UI**: Clean, modern interface with proper loading and error states

## API Integration

The feature integrates with OpenWeatherMap API:
- **Current Weather API**: `https://api.openweathermap.org/data/2.5/weather`
- **Air Quality API**: `https://api.openweathermap.org/data/2.5/air_pollution/current`

## Configuration

### API Key Setup

1. Get an API key from [OpenWeatherMap](https://openweathermap.org/api)
2. Update the API key in `lib/core/config/weather_config.dart`:

```dart
static const String apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
```

**Important**: In production, store the API key securely using environment variables or secure storage.

## Architecture

The weather feature follows the established app architecture:

```
lib/features/weather/
├── data/
│   ├── models/
│   │   └── weather_model.dart          # Data models
│   ├── providers/
│   │   └── weather_provider.dart       # Riverpod providers
│   └── services/
│       └── weather_service.dart        # API service
└── presentation/
    ├── screens/
    │   └── weather_screen.dart         # Main weather screen
    └── widgets/
        ├── weather_card.dart           # Weather display card
        └── weather_details.dart        # Detailed weather info
```

## Dependencies

- `weather: ^3.1.1` - Weather data models and utilities
- `intl: ^0.19.0` - Internationalization support
- `geolocator: ^14.0.1` - Location services (already in project)
- `cached_network_image: ^3.3.0` - Weather icon caching (already in project)

## Permissions

The feature requires location permissions to get the user's current location:

### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to show weather for your current location.</string>
```

## Usage

The weather feature is accessible from the home screen via the weather button. Users can:

1. View current weather conditions
2. See detailed weather information
3. Check air quality (if available)
4. Refresh weather data
5. Grant location permission for accurate location-based weather

## Error Handling

The feature handles various error scenarios:
- No internet connection
- Invalid API key
- Location permission denied
- API rate limits
- Service unavailable

## Localization

Weather data and UI text are localized for:
- **English**: Default language
- **Persian**: Right-to-left layout support
- **Pashto**: Right-to-left layout support

## Future Enhancements

Potential improvements:
- Weather forecast (5-day/hourly)
- Weather alerts and notifications
- Multiple location support
- Weather maps integration
- Historical weather data
- Weather widgets for home screen
