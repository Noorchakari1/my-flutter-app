import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../data/models/weather_model.dart';
import '../../data/providers/weather_provider.dart';

class WeatherCard extends ConsumerWidget {
  final WeatherData weatherData;

  const WeatherCard({
    super.key,
    required this.weatherData,
  });

  // Helper function to get localized text
  String _getText(String key, WidgetRef ref) {
    final language = ref.watch(themeNotifierProvider).currentLanguage;
    Map<String, String> textMap;
    switch (language) {
      case 'pashto':
        textMap = AppConstants.pashtoText;
        break;
      case 'persian':
        textMap = AppConstants.persianText;
        break;
      default:
        textMap = AppConstants.englishText;
    }
    return textMap[key] ?? key;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(weatherFormattingProvider);
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstants.primaryColor.withAlpha(26), // 0.1 opacity
              AppConstants.primaryColor.withAlpha(13), // 0.05 opacity
            ],
          ),
        ),
        child: Column(
          children: [
            // Location and refresh button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weatherData.locationName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      Text(
                        _getText('currentWeather', ref),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await ref.read(weatherDataProvider.notifier).refreshWeatherData();
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: _getText('refreshWeather', ref),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            // Main weather info
            Row(
              children: [
                // Weather icon
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: formatter.getWeatherIconUrl(weatherData.iconCode),
                        width: 80,
                        height: 80,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Text(
                          formatter.getWeatherConditionIcon(weatherData.condition),
                          style: const TextStyle(fontSize: 64),
                        ),
                      ),
                      Text(
                        weatherData.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Temperature and feels like
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatter.formatTemperature(weatherData.temperature),
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      Text(
                        '${_getText('feelsLike', ref)} ${formatter.formatTemperature(weatherData.feelsLike)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            // Quick stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickStat(
                  context,
                  ref,
                  Icons.water_drop,
                  _getText('humidity', ref),
                  formatter.formatHumidity(weatherData.humidity),
                ),
                _buildQuickStat(
                  context,
                  ref,
                  Icons.air,
                  _getText('windSpeed', ref),
                  formatter.formatWindSpeed(weatherData.windSpeed),
                ),
                _buildQuickStat(
                  context,
                  ref,
                  Icons.compress,
                  _getText('pressure', ref),
                  formatter.formatPressure(weatherData.pressure),
                ),
              ],
            ),

            // Air quality if available
            if (weatherData.airQuality != null) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              _buildAirQualitySection(context, ref, weatherData.airQuality!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          color: AppConstants.primaryColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAirQualitySection(
    BuildContext context,
    WidgetRef ref,
    AirQualityData airQuality,
  ) {
    final theme = Theme.of(context);
    final formatter = ref.watch(weatherFormattingProvider);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withAlpha(128), // 0.5 opacity
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.eco,
            color: Color(int.parse(formatter.getAirQualityColor(airQuality.aqi).substring(1), radix: 16) + 0xFF000000),
          ),
          const SizedBox(width: 8),
          Text(
            _getText('airQuality', ref),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            formatter.formatAirQuality(airQuality),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Color(int.parse(formatter.getAirQualityColor(airQuality.aqi).substring(1), radix: 16) + 0xFF000000),
            ),
          ),
        ],
      ),
    );
  }
}
