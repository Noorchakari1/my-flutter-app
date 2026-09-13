import 'dart:async';
import 'dart:convert';

import 'package:aop_sites/features/qibla/data/models/qibla_model.dart';
import 'package:aop_sites/features/qibla/data/providers/qibla_provider.dart';
import 'package:aop_sites/features/qibla/data/services/qibla_service.dart';
import 'package:aop_sites/features/weather/data/services/weather_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class ImmediateQiblaService extends QiblaService {
  final controller = StreamController<QiblaModel>.broadcast(sync: true);
  @override
  Stream<QiblaModel> get qiblaStream => controller.stream;
  @override
  Future<void> initialize() async {
    controller.add(QiblaModel.fromLocationAndCompass(
      userLatitude: 0,
      userLongitude: 0,
      compassAngle: 0,
      isLocationAvailable: false,
      isCompassAvailable: false,
    ));
  }

  @override
  void dispose() {
    controller.close();
  }
}

void main() {
  test('Qibla receives initialization result even without GPS or compass',
      () async {
    final service = ImmediateQiblaService();
    final notifier = QiblaNotifier(service);
    await Future<void>.delayed(Duration.zero);
    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.asData!.value!.isLocationAvailable, isFalse);
    await notifier.refreshLocation();
    expect(notifier.state.isLoading, isFalse);
    notifier.dispose();
    service.dispose();
  });

  test('stalled weather request ends with an error', () async {
    final service = WeatherService(
      client: MockClient((_) => Completer<http.Response>().future),
      requestTimeout: const Duration(milliseconds: 10),
    );
    addTearDown(service.dispose);
    await expectLater(
        service.getCurrentWeather(
            latitude: 34.5, longitude: 69.2, language: 'english'),
        throwsException);
  });

  test('stalled optional air quality does not prevent weather display',
      () async {
    final service = WeatherService(
      airQualityTimeout: const Duration(milliseconds: 10),
      client: MockClient((request) async {
        if (request.url.path.contains('air_pollution')) {
          return Completer<http.Response>().future;
        }
        return http.Response(
            jsonEncode({
              'main': {
                'temp': 20,
                'feels_like': 19,
                'humidity': 30,
                'pressure': 1010
              },
              'weather': [
                {
                  'id': 800,
                  'main': 'Clear',
                  'description': 'clear sky',
                  'icon': '01d'
                }
              ],
              'wind': {'speed': 2},
              'sys': {'sunrise': 1000, 'sunset': 2000},
              'visibility': 10000,
              'name': 'Kabul',
              'coord': {'lat': 34.5, 'lon': 69.2},
            }),
            200);
      }),
    );
    addTearDown(service.dispose);
    final weather = await service.getCurrentWeather(
        latitude: 34.5, longitude: 69.2, language: 'english');
    expect(weather.locationName, 'Kabul');
    expect(weather.airQuality, isNull);
  });
}
