/// Weather data model
class WeatherData {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final int visibility;
  final String condition;
  final String description;
  final String iconCode;
  final DateTime sunrise;
  final DateTime sunset;
  final String locationName;
  final double latitude;
  final double longitude;
  final AirQualityData? airQuality;

  const WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
    required this.condition,
    required this.description,
    required this.iconCode,
    required this.sunrise,
    required this.sunset,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    this.airQuality,
  });

  factory WeatherData.fromApiResponse(
    WeatherResponse weatherResponse,
    AirQualityData? airQuality,
  ) {
    final weather = weatherResponse.weather.first;
    return WeatherData(
      temperature: weatherResponse.main.temp,
      feelsLike: weatherResponse.main.feelsLike,
      humidity: weatherResponse.main.humidity,
      windSpeed: weatherResponse.wind.speed,
      pressure: weatherResponse.main.pressure,
      visibility: weatherResponse.visibility,
      condition: weather.main,
      description: weather.description,
      iconCode: weather.icon,
      sunrise: DateTime.fromMillisecondsSinceEpoch(weatherResponse.sys.sunrise * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(weatherResponse.sys.sunset * 1000),
      locationName: weatherResponse.name,
      latitude: weatherResponse.coord.lat,
      longitude: weatherResponse.coord.lon,
      airQuality: airQuality,
    );
  }
}

/// Air quality data model
class AirQualityData {
  final int aqi; // Air Quality Index (1-5)
  final double co;
  final double no;
  final double no2;
  final double o3;
  final double so2;
  final double pm2_5;
  final double pm10;
  final double nh3;

  const AirQualityData({
    required this.aqi,
    required this.co,
    required this.no,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm2_5,
    required this.pm10,
    required this.nh3,
  });

  factory AirQualityData.fromApiResponse(AirQualityResponse response) {
    final data = response.list.first;
    return AirQualityData(
      aqi: data.main.aqi,
      co: data.components.co,
      no: data.components.no,
      no2: data.components.no2,
      o3: data.components.o3,
      so2: data.components.so2,
      pm2_5: data.components.pm2_5,
      pm10: data.components.pm10,
      nh3: data.components.nh3,
    );
  }

  /// Get air quality description based on AQI
  String getQualityDescription() {
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Fair';
      case 3:
        return 'Moderate';
      case 4:
        return 'Poor';
      case 5:
        return 'Very Poor';
      default:
        return 'Unknown';
    }
  }
}

/// Weather response from OpenWeatherMap API
class WeatherResponse {
  final WeatherMain main;
  final List<WeatherCondition> weather;
  final WeatherWind wind;
  final WeatherSys sys;
  final int visibility;
  final String name;
  final WeatherCoord coord;

  const WeatherResponse({
    required this.main,
    required this.weather,
    required this.wind,
    required this.sys,
    required this.visibility,
    required this.name,
    required this.coord,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      main: WeatherMain.fromJson(json['main']),
      weather: (json['weather'] as List)
          .map((e) => WeatherCondition.fromJson(e))
          .toList(),
      wind: WeatherWind.fromJson(json['wind']),
      sys: WeatherSys.fromJson(json['sys']),
      visibility: json['visibility'],
      name: json['name'],
      coord: WeatherCoord.fromJson(json['coord']),
    );
  }
}

/// Main weather data from API
class WeatherMain {
  final double temp;
  final double feelsLike;
  final int humidity;
  final int pressure;

  const WeatherMain({
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
  });

  factory WeatherMain.fromJson(Map<String, dynamic> json) {
    return WeatherMain(
      temp: (json['temp'] as num).toDouble(),
      feelsLike: (json['feels_like'] as num).toDouble(),
      humidity: json['humidity'],
      pressure: json['pressure'],
    );
  }
}

/// Weather condition from API
class WeatherCondition {
  final String main;
  final String description;
  final String icon;

  const WeatherCondition({
    required this.main,
    required this.description,
    required this.icon,
  });

  factory WeatherCondition.fromJson(Map<String, dynamic> json) {
    return WeatherCondition(
      main: json['main'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}

/// Wind data from API
class WeatherWind {
  final double speed;
  final int? deg;

  const WeatherWind({
    required this.speed,
    this.deg,
  });

  factory WeatherWind.fromJson(Map<String, dynamic> json) {
    return WeatherWind(
      speed: (json['speed'] as num).toDouble(),
      deg: json['deg'],
    );
  }
}

/// System data from API
class WeatherSys {
  final int sunrise;
  final int sunset;

  const WeatherSys({
    required this.sunrise,
    required this.sunset,
  });

  factory WeatherSys.fromJson(Map<String, dynamic> json) {
    return WeatherSys(
      sunrise: json['sunrise'],
      sunset: json['sunset'],
    );
  }
}

/// Coordinates from API
class WeatherCoord {
  final double lat;
  final double lon;

  const WeatherCoord({
    required this.lat,
    required this.lon,
  });

  factory WeatherCoord.fromJson(Map<String, dynamic> json) {
    return WeatherCoord(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }
}

/// Air quality response from API
class AirQualityResponse {
  final List<AirQualityList> list;

  const AirQualityResponse({
    required this.list,
  });

  factory AirQualityResponse.fromJson(Map<String, dynamic> json) {
    return AirQualityResponse(
      list: (json['list'] as List)
          .map((e) => AirQualityList.fromJson(e))
          .toList(),
    );
  }
}

/// Air quality list item from API
class AirQualityList {
  final AirQualityMain main;
  final AirQualityComponents components;

  const AirQualityList({
    required this.main,
    required this.components,
  });

  factory AirQualityList.fromJson(Map<String, dynamic> json) {
    return AirQualityList(
      main: AirQualityMain.fromJson(json['main']),
      components: AirQualityComponents.fromJson(json['components']),
    );
  }
}

/// Air quality main data from API
class AirQualityMain {
  final int aqi;

  const AirQualityMain({
    required this.aqi,
  });

  factory AirQualityMain.fromJson(Map<String, dynamic> json) {
    return AirQualityMain(
      aqi: json['aqi'],
    );
  }
}

/// Air quality components from API
class AirQualityComponents {
  final double co;
  final double no;
  final double no2;
  final double o3;
  final double so2;
  final double pm2_5;
  final double pm10;
  final double nh3;

  const AirQualityComponents({
    required this.co,
    required this.no,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm2_5,
    required this.pm10,
    required this.nh3,
  });

  factory AirQualityComponents.fromJson(Map<String, dynamic> json) {
    return AirQualityComponents(
      co: (json['co'] as num).toDouble(),
      no: (json['no'] as num).toDouble(),
      no2: (json['no2'] as num).toDouble(),
      o3: (json['o3'] as num).toDouble(),
      so2: (json['so2'] as num).toDouble(),
      pm2_5: (json['pm2_5'] as num).toDouble(),
      pm10: (json['pm10'] as num).toDouble(),
      nh3: (json['nh3'] as num).toDouble(),
    );
  }
}
