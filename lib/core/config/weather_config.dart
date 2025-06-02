/// Weather API Configuration
class WeatherConfig {
  const WeatherConfig._();

  /// OpenWeatherMap API key
  /// Note: In production, this should be stored securely (e.g., environment variables)
  static const String apiKey = '99e456697b4a239aa2ae096e05e31a04';
  
  /// OpenWeatherMap base URL
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  /// Air Quality API base URL
  static const String airQualityBaseUrl = 'https://api.openweathermap.org/data/2.5/air_pollution';
  
  /// Default location coordinates (Kabul, Afghanistan)
  static const double defaultLatitude = 34.5553;
  static const double defaultLongitude = 69.2075;
  
  /// Default location name
  static const String defaultLocationName = 'Kabul';
  
  /// API endpoints
  static const String currentWeatherEndpoint = '/weather';
  static const String forecastEndpoint = '/forecast';
  static const String airQualityEndpoint = '/current';
  
  /// Units
  static const String units = 'metric'; // metric, imperial, standard
  
  /// Language codes for OpenWeatherMap API
  static const Map<String, String> languageCodes = {
    'english': 'en',
    'persian': 'fa',
    'pashto': 'ps',
  };
  
  /// Get language code for API
  static String getLanguageCode(String appLanguage) {
    return languageCodes[appLanguage.toLowerCase()] ?? 'en';
  }
  
  /// Build current weather URL
  static String buildCurrentWeatherUrl({
    required double latitude,
    required double longitude,
    required String language,
  }) {
    return '$baseUrl$currentWeatherEndpoint'
        '?lat=$latitude'
        '&lon=$longitude'
        '&appid=$apiKey'
        '&units=$units'
        '&lang=${getLanguageCode(language)}';
  }
  
  /// Build air quality URL
  static String buildAirQualityUrl({
    required double latitude,
    required double longitude,
  }) {
    return '$airQualityBaseUrl$airQualityEndpoint'
        '?lat=$latitude'
        '&lon=$longitude'
        '&appid=$apiKey';
  }
  
  /// Weather icon URL
  static String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }
}
