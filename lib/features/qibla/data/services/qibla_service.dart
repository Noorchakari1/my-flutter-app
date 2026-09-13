import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../models/qibla_model.dart';

/// Service for handling Qibla compass functionality
class QiblaService {
  QiblaService();
  bool _disposed = false;

  StreamController<QiblaModel>? _qiblaController;
  StreamSubscription<CompassEvent>? _compassSubscription;

  Position? _currentPosition;
  double _currentCompassAngle = 0.0;
  bool _isLocationAvailable = false;
  bool _isCompassAvailable = false;

  /// Stream of Qibla data updates
  Stream<QiblaModel> get qiblaStream {
    _qiblaController ??= StreamController<QiblaModel>.broadcast();
    return _qiblaController!.stream;
  }

  /// Initialize the Qibla service
  Future<void> initialize() async {
    await _getCurrentLocation();
    if (_disposed) return;
    await _compassSubscription?.cancel();
    final stream = FlutterCompass.events;
    if (stream != null) {
      _compassSubscription = stream.listen((event) {
        if (_disposed) return;
        final heading = event.heading;
        _isCompassAvailable = heading != null && heading.isFinite;
        if (_isCompassAvailable) _currentCompassAngle = heading!;
        _updateQiblaData();
      }, onError: (Object error, StackTrace stack) {
        _isCompassAvailable = false;
        _updateQiblaData();
      });
    }
    // Publish a result even without GPS or a compass event.
    _updateQiblaData();
  }

  Future<void> _getCurrentLocation() async {
    _isLocationAvailable = false;
    try {
      if (!await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 3))) {
        return;
      }
      var permission = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 3));
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      ).timeout(const Duration(seconds: 12));
      if (_disposed) return;
      _currentPosition = position;
      _isLocationAvailable = true;
    } catch (_) {
      _isLocationAvailable = false;
    }
  }

  /// Update Qibla data and emit to stream
  QiblaModel get _currentData => QiblaModel.fromLocationAndCompass(
        userLatitude: _currentPosition?.latitude ?? 0,
        userLongitude: _currentPosition?.longitude ?? 0,
        compassAngle: _currentCompassAngle,
        isLocationAvailable: _isLocationAvailable,
        isCompassAvailable: _isCompassAvailable,
      );

  void _updateQiblaData() {
    if (!_disposed) _qiblaController?.add(_currentData);
  }

  /// Check if compass is available on the device
  Future<bool> isCompassAvailable() async {
    try {
      final compassStream = FlutterCompass.events;
      return compassStream != null;
    } catch (e) {
      return false;
    }
  }

  /// Check if location services are available
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current location permission status
  Future<LocationPermission> getLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Refresh location data
  Future<void> refreshLocation() async {
    await _getCurrentLocation();
    _updateQiblaData();
  }

  /// Calculate Qibla direction for given coordinates
  static double calculateQiblaDirection(double latitude, double longitude) {
    return QiblaModel.calculateQiblaBearing(latitude, longitude);
  }

  /// Calculate distance to Kaaba for given coordinates
  static double calculateDistanceToKaaba(double latitude, double longitude) {
    return QiblaModel.calculateDistanceToKaaba(latitude, longitude);
  }

  /// Dispose of resources
  void dispose() {
    _compassSubscription?.cancel();
    _disposed = true;
    _qiblaController?.close();
    _qiblaController = null;
  }

  /// Get current Qibla data (one-time)
  Future<QiblaModel?> getCurrentQiblaData() async => _currentData;
}
