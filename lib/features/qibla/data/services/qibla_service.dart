import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/qibla_model.dart';

/// Service for handling Qibla compass functionality
class QiblaService {
  static final QiblaService _instance = QiblaService._internal();
  factory QiblaService() => _instance;
  QiblaService._internal();

  StreamController<QiblaModel>? _qiblaController;
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

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
    await _checkPermissions();
    await _getCurrentLocation();
    await _startCompassListening();
    _startAccelerometerListening();
  }

  /// Check and request necessary permissions
  Future<bool> _checkPermissions() async {
    // Check location permission
    final locationPermission = await Permission.location.status;
    if (locationPermission.isDenied) {
      final result = await Permission.location.request();
      if (result.isDenied) {
        return false;
      }
    }

    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    return true;
  }

  /// Get current user location
  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestedPermission = await Geolocator.requestPermission();
        if (requestedPermission == LocationPermission.denied ||
            requestedPermission == LocationPermission.deniedForever) {
          _isLocationAvailable = false;
          return;
        }
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _isLocationAvailable = true;
    } catch (e) {
      _isLocationAvailable = false;
    }
  }

  /// Start listening to compass events
  Future<void> _startCompassListening() async {
    try {
      final compassStream = FlutterCompass.events;
      if (compassStream != null) {
        _compassSubscription = compassStream.listen((CompassEvent event) {
          if (event.heading != null) {
            _currentCompassAngle = event.heading!;
            _isCompassAvailable = true;
            _updateQiblaData();
          }
        });
      } else {
        _isCompassAvailable = false;
      }
    } catch (e) {
      _isCompassAvailable = false;
    }
  }

  /// Start listening to accelerometer for calibration detection
  void _startAccelerometerListening() {
    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      // This can be used for calibration detection if needed
      // For now, we'll just ensure the stream is active
    });
  }

  /// Update Qibla data and emit to stream
  void _updateQiblaData() {
    if (_currentPosition != null) {
      final qiblaModel = QiblaModel.fromLocationAndCompass(
        userLatitude: _currentPosition!.latitude,
        userLongitude: _currentPosition!.longitude,
        compassAngle: _currentCompassAngle,
        isLocationAvailable: _isLocationAvailable,
        isCompassAvailable: _isCompassAvailable,
      );

      _qiblaController?.add(qiblaModel);
    }
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
    _accelerometerSubscription?.cancel();
    _qiblaController?.close();
    _qiblaController = null;
  }

  /// Get current Qibla data (one-time)
  Future<QiblaModel?> getCurrentQiblaData() async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
    }

    if (_currentPosition != null) {
      return QiblaModel.fromLocationAndCompass(
        userLatitude: _currentPosition!.latitude,
        userLongitude: _currentPosition!.longitude,
        compassAngle: _currentCompassAngle,
        isLocationAvailable: _isLocationAvailable,
        isCompassAvailable: _isCompassAvailable,
      );
    }

    return null;
  }
}
