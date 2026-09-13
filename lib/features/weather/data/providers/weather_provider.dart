import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/providers/theme_provider.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

/// Provider for WeatherService instance
final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

/// Provider for current weather data
final weatherDataProvider =
    StateNotifierProvider<WeatherNotifier, AsyncValue<WeatherData>>((ref) {
  final weatherService = ref.watch(weatherServiceProvider);
  return WeatherNotifier(weatherService, ref);
});

/// Provider for location permission status
final locationPermissionProvider = FutureProvider<bool>((ref) async {
  final weatherService = ref.watch(weatherServiceProvider);
  return await weatherService.hasLocationPermission();
});

/// Weather state notifier
class WeatherNotifier extends StateNotifier<AsyncValue<WeatherData>> {
  final WeatherService _weatherService;
  final Ref _ref;
  bool _loading = false;

  WeatherNotifier(this._weatherService, this._ref)
      : super(const AsyncLoading()) {
    loadWeatherData();
  }

  /// Load weather data
  Future<void> loadWeatherData({
    double? latitude,
    double? longitude,
  }) async {
    if (_loading || !mounted) return;
    _loading = true;
    try {
      state = const AsyncLoading();

      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;

      final weatherData = await _weatherService.getCurrentWeather(
        latitude: latitude,
        longitude: longitude,
        language: currentLanguage,
      );

      if (mounted) state = AsyncData(weatherData);
    } catch (error, stackTrace) {
      if (mounted) state = AsyncError(error, stackTrace);
    } finally {
      _loading = false;
    }
  }

  /// Refresh weather data
  Future<void> refreshWeatherData() async {
    await loadWeatherData();
  }

  /// Load weather data for specific coordinates
  Future<void> loadWeatherForLocation(double latitude, double longitude) async {
    await loadWeatherData(latitude: latitude, longitude: longitude);
  }

  /// Request location permission and reload data
  Future<void> requestLocationAndReload() async {
    try {
      final permission = await _weatherService.requestLocationPermission();
      if (!mounted) return;
      _ref.invalidate(locationPermissionProvider);
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        await loadWeatherData();
      }
    } catch (error, stackTrace) {
      if (mounted) state = AsyncError(error, stackTrace);
    }
  }

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }
}

/// Provider for weather formatting utilities
final weatherFormattingProvider = Provider<WeatherFormattingService>((ref) {
  final weatherService = ref.watch(weatherServiceProvider);
  return WeatherFormattingService(weatherService);
});

/// Service for weather data formatting
class WeatherFormattingService {
  final WeatherService _weatherService;

  WeatherFormattingService(this._weatherService);

  /// Format temperature with unit
  String formatTemperature(double temperature, {bool useFahrenheit = false}) {
    return _weatherService.formatTemperature(temperature,
        useFahrenheit: useFahrenheit);
  }

  /// Format wind speed with unit
  String formatWindSpeed(double speed, {bool useMph = false}) {
    return _weatherService.formatWindSpeed(speed, useMph: useMph);
  }

  /// Format pressure with unit
  String formatPressure(int pressure) {
    return _weatherService.formatPressure(pressure);
  }

  /// Format visibility with unit
  String formatVisibility(int visibility) {
    return _weatherService.formatVisibility(visibility);
  }

  /// Get weather icon URL
  String getWeatherIconUrl(String iconCode) {
    return _weatherService.getWeatherIconUrl(iconCode);
  }

  /// Format humidity as percentage
  String formatHumidity(int humidity) {
    return '$humidity%';
  }

  /// Format air quality index
  String formatAirQuality(AirQualityData airQuality) {
    return '${airQuality.getQualityDescription()} (${airQuality.aqi}/5)';
  }

  /// Format time from DateTime
  String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get weather condition icon based on condition
  String getWeatherConditionIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'fog':
        return '🌫️';
      case 'haze':
        return '🌫️';
      case 'dust':
      case 'sand':
        return '🌪️';
      default:
        return '🌤️';
    }
  }

  /// Get air quality color based on AQI
  String getAirQualityColor(int aqi) {
    switch (aqi) {
      case 1:
        return '#00E400'; // Good - Green
      case 2:
        return '#FFFF00'; // Fair - Yellow
      case 3:
        return '#FF7E00'; // Moderate - Orange
      case 4:
        return '#FF0000'; // Poor - Red
      case 5:
        return '#8F3F97'; // Very Poor - Purple
      default:
        return '#808080'; // Unknown - Gray
    }
  }
}
