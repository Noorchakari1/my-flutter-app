import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/base_screen.dart';
import '../../data/providers/weather_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/weather_details.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  final ScrollController _scrollController = ScrollController();

  // Helper function to get localized text
  String _getText(String key) {
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherDataProvider);
    final locationPermission = ref.watch(locationPermissionProvider);

    return BaseScreen(
      title: _getText('weather'),
      showBackButton: true,
      showScrollToTopButton: true,
      scrollController: _scrollController,
      enablePullToRefresh: true,
      onRefresh: () async {
        await ref.read(weatherDataProvider.notifier).refreshWeatherData();
      },
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Location permission status
            locationPermission.when(
              data: (hasPermission) {
                if (!hasPermission) {
                  return _buildLocationPermissionCard();
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            // Weather data
            weatherState.when(
              data: (weatherData) => Column(
                children: [
                  WeatherCard(weatherData: weatherData),
                  const SizedBox(height: AppConstants.defaultPadding),
                  WeatherDetails(weatherData: weatherData),
                ],
              ),
              loading: () => _buildLoadingWidget(),
              error: (error, stackTrace) => _buildErrorWidget(error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPermissionCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Icon(
              Icons.location_off,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              _getText('locationPermissionDenied'),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getText('defaultLocation'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(weatherDataProvider.notifier).requestLocationAndReload();
              },
              icon: const Icon(Icons.location_on),
              label: Text(_getText('enableLocationServices')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _getText('loading'),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _getText('weatherLoadError'),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(weatherDataProvider.notifier).refreshWeatherData();
              },
              icon: const Icon(Icons.refresh),
              label: Text(_getText('retry')),
            ),
          ],
        ),
      ),
    );
  }
}
