import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../data/models/weather_model.dart';
import '../../data/providers/weather_provider.dart';

class WeatherDetails extends ConsumerWidget {
  final WeatherData weatherData;

  const WeatherDetails({
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
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getText('weatherCondition', ref),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            // Weather details grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildDetailItem(
                  context,
                  ref,
                  Icons.thermostat,
                  _getText('temperature', ref),
                  formatter.formatTemperature(weatherData.temperature),
                ),
                _buildDetailItem(
                  context,
                  ref,
                  Icons.thermostat_outlined,
                  _getText('feelsLike', ref),
                  formatter.formatTemperature(weatherData.feelsLike),
                ),
                _buildDetailItem(
                  context,
                  ref,
                  Icons.water_drop,
                  _getText('humidity', ref),
                  formatter.formatHumidity(weatherData.humidity),
                ),
                _buildDetailItem(
                  context,
                  ref,
                  Icons.air,
                  _getText('windSpeed', ref),
                  formatter.formatWindSpeed(weatherData.windSpeed),
                ),
                _buildDetailItem(
                  context,
                  ref,
                  Icons.compress,
                  _getText('pressure', ref),
                  formatter.formatPressure(weatherData.pressure),
                ),
                _buildDetailItem(
                  context,
                  ref,
                  Icons.visibility,
                  _getText('visibility', ref),
                  formatter.formatVisibility(weatherData.visibility),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            // Sun times
            _buildSunTimesSection(context, ref),

            // Air quality details if available
            if (weatherData.airQuality != null) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              _buildAirQualityDetails(context, ref, weatherData.airQuality!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(128), // 0.5 opacity
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppConstants.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunTimesSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(weatherFormattingProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(128), // 0.5 opacity
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Icon(
                  Icons.wb_sunny,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  _getText('sunrise', ref),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  formatter.formatTime(weatherData.sunrise),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.outline,
          ),
          Expanded(
            child: Column(
              children: [
                const Icon(
                  Icons.wb_twilight,
                  color: Colors.deepOrange,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  _getText('sunset', ref),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  formatter.formatTime(weatherData.sunset),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirQualityDetails(
    BuildContext context,
    WidgetRef ref,
    AirQualityData airQuality,
  ) {
    final theme = Theme.of(context);
    final formatter = ref.watch(weatherFormattingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getText('airQuality', ref),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(128), // 0.5 opacity
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AQI',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    formatter.formatAirQuality(airQuality),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Color(int.parse(formatter.getAirQualityColor(airQuality.aqi).substring(1), radix: 16) + 0xFF000000),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PM2.5', style: theme.textTheme.bodySmall),
                  Text('${airQuality.pm2_5.toStringAsFixed(1)} μg/m³', style: theme.textTheme.bodySmall),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PM10', style: theme.textTheme.bodySmall),
                  Text('${airQuality.pm10.toStringAsFixed(1)} μg/m³', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
