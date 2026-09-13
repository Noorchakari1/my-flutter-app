import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/weather_config.dart';
import '../../../../core/services/api_exception.dart';
import '../models/weather_model.dart';

/// Service for handling weather-related API requests
class WeatherService {
  final http.Client _client;

  final Duration requestTimeout;
  final Duration airQualityTimeout;
  WeatherService({
    http.Client? client,
    this.requestTimeout = const Duration(seconds: 12),
    this.airQualityTimeout = const Duration(seconds: 3),
  }) : _client = client ?? http.Client();

  /// Get current weather data
  Future<WeatherData> getCurrentWeather({
    double? latitude,
    double? longitude,
    required String language,
  }) async {
    try {
      // Use provided coordinates or get current location
      double lat, lon;

      if (latitude != null && longitude != null) {
        lat = latitude;
        lon = longitude;
      } else {
        final position = await _getCurrentPosition()
            .timeout(const Duration(seconds: 12), onTimeout: () => null);
        if (position != null) {
          lat = position.latitude;
          lon = position.longitude;
        } else {
          // Use default location (Kabul)
          lat = WeatherConfig.defaultLatitude;
          lon = WeatherConfig.defaultLongitude;
        }
      }

      // Fetch weather data
      final weatherResponse = await _fetchWeatherData(lat, lon, language);

      // Fetch air quality data (optional)
      AirQualityData? airQuality;
      try {
        airQuality = await _fetchAirQualityData(lat, lon);
      } catch (e) {
        // Air quality data is optional, continue without it
        // In production, use a proper logging framework
      }

      return WeatherData.fromApiResponse(weatherResponse, airQuality);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  /// Fetch weather data from OpenWeatherMap API
  Future<WeatherResponse> _fetchWeatherData(
    double latitude,
    double longitude,
    String language,
  ) async {
    final url = WeatherConfig.buildCurrentWeatherUrl(
      latitude: latitude,
      longitude: longitude,
      language: language,
    );

    final response = await _client.get(Uri.parse(url)).timeout(requestTimeout);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return WeatherResponse.fromJson(data);
    } else if (response.statusCode == 401) {
      throw const ApiException(
        message: 'Invalid API key',
        code: 'unauthorized',
        statusCode: 401,
      );
    } else if (response.statusCode == 404) {
      throw const ApiException(
        message: 'Location not found',
        code: 'not_found',
        statusCode: 404,
      );
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Fetch air quality data from OpenWeatherMap API
  Future<AirQualityData> _fetchAirQualityData(
    double latitude,
    double longitude,
  ) async {
    final url = WeatherConfig.buildAirQualityUrl(
      latitude: latitude,
      longitude: longitude,
    );

    final response =
        await _client.get(Uri.parse(url)).timeout(airQualityTimeout);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final airQualityResponse = AirQualityResponse.fromJson(data);
      return AirQualityData.fromApiResponse(airQualityResponse);
    } else if (response.statusCode == 401) {
      throw const ApiException(
        message: 'Invalid API key',
        code: 'unauthorized',
        statusCode: 401,
      );
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Get current position with permission handling
  Future<Position?> _getCurrentPosition() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check location permissions
      final permission = await Geolocator.checkPermission();
      // The permission button requests access explicitly. Kabul can load now.
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return null;
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      // In production, use a proper logging framework
      return null;
    }
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get weather icon URL
  String getWeatherIconUrl(String iconCode) {
    return WeatherConfig.getWeatherIconUrl(iconCode);
  }

  /// Format temperature
  String formatTemperature(double temperature, {bool useFahrenheit = false}) {
    if (useFahrenheit) {
      final fahrenheit = (temperature * 9 / 5) + 32;
      return '${fahrenheit.round()}°F';
    }
    return '${temperature.round()}°C';
  }

  /// Format wind speed
  String formatWindSpeed(double speed, {bool useMph = false}) {
    if (useMph) {
      final mph = speed * 2.237;
      return '${mph.toStringAsFixed(1)} mph';
    }
    return '${speed.toStringAsFixed(1)} km/h';
  }

  /// Format pressure
  String formatPressure(int pressure) {
    return '$pressure hPa';
  }

  /// Format visibility
  String formatVisibility(int visibility) {
    final km = visibility / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}
