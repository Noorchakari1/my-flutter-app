import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/qibla_model.dart';
import '../services/qibla_service.dart';

/// Provider for QiblaService instance
final qiblaServiceProvider = Provider.autoDispose<QiblaService>((ref) {
  final service = QiblaService();
  ref.onDispose(service.dispose);
  return service;
});

/// Provider for Qibla data stream
final qiblaStreamProvider = StreamProvider.autoDispose<QiblaModel>((ref) {
  final qiblaService = ref.watch(qiblaServiceProvider);
  return qiblaService.qiblaStream;
});

/// Provider for checking compass availability
final compassAvailabilityProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final qiblaService = ref.watch(qiblaServiceProvider);
  return await qiblaService.isCompassAvailable();
});

/// Provider for checking location service status
final locationServiceProvider = FutureProvider.autoDispose<bool>((ref) async {
  final qiblaService = ref.watch(qiblaServiceProvider);
  return await qiblaService.isLocationServiceEnabled();
});

/// Provider for location permission status
final locationPermissionProvider =
    FutureProvider.autoDispose<LocationPermission>((ref) async {
  final qiblaService = ref.watch(qiblaServiceProvider);
  return await qiblaService.getLocationPermission();
});

/// Notifier for managing Qibla state
class QiblaNotifier extends StateNotifier<AsyncValue<QiblaModel?>> {
  QiblaNotifier(this._qiblaService) : super(const AsyncValue.loading()) {
    _initialize();
  }

  final QiblaService _qiblaService;
  StreamSubscription<QiblaModel>? _subscription;
  bool _initializing = false;

  Future<void> _initialize() async {
    _initializing = true;
    try {
      _subscription = _qiblaService.qiblaStream.listen(
        (qiblaModel) {
          if (mounted) state = AsyncValue.data(qiblaModel);
        },
        onError: (error, stackTrace) {
          if (mounted) state = AsyncValue.error(error, stackTrace);
        },
      );
      await _qiblaService.initialize();
    } catch (error, stackTrace) {
      if (mounted) state = AsyncValue.error(error, stackTrace);
    } finally {
      _initializing = false;
    }
  }

  /// Refresh location data
  Future<void> refreshLocation() async {
    if (_initializing || !mounted) return;
    _initializing = true;
    try {
      state = const AsyncValue.loading();
      await _qiblaService.initialize();
    } catch (error, stackTrace) {
      if (mounted) state = AsyncValue.error(error, stackTrace);
    } finally {
      _initializing = false;
    }
  }

  /// Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    final permission = await _qiblaService.requestLocationPermission();
    if (mounted) await refreshLocation();
    return permission;
  }

  /// Get current Qibla data
  Future<QiblaModel?> getCurrentQiblaData() async {
    return await _qiblaService.getCurrentQiblaData();
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }
}

/// Provider for QiblaNotifier
final qiblaNotifierProvider =
    StateNotifierProvider.autoDispose<QiblaNotifier, AsyncValue<QiblaModel?>>(
        (ref) {
  final qiblaService = ref.watch(qiblaServiceProvider);
  return QiblaNotifier(qiblaService);
});

/// Provider for checking if device is pointing to Qibla
final isPointingToQiblaProvider = Provider<bool>((ref) {
  final qiblaState = ref.watch(qiblaNotifierProvider);
  return qiblaState.when(
    data: (qiblaModel) => qiblaModel?.isPointingToQibla() ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for Qibla angle relative to current compass direction
final relativeQiblaAngleProvider = Provider<double>((ref) {
  final qiblaState = ref.watch(qiblaNotifierProvider);
  return qiblaState.when(
    data: (qiblaModel) => qiblaModel?.relativeQiblaAngle ?? 0.0,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Provider for distance to Kaaba
final distanceToKaabaProvider = Provider<double>((ref) {
  final qiblaState = ref.watch(qiblaNotifierProvider);
  return qiblaState.when(
    data: (qiblaModel) => qiblaModel?.distanceToKaaba ?? 0.0,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Provider for user location coordinates
final userLocationProvider = Provider<String>((ref) {
  final qiblaState = ref.watch(qiblaNotifierProvider);
  return qiblaState.when(
    data: (qiblaModel) {
      if (qiblaModel != null) {
        return '${qiblaModel.userLatitude.toStringAsFixed(4)}, ${qiblaModel.userLongitude.toStringAsFixed(4)}';
      }
      return 'Unknown';
    },
    loading: () => 'Loading...',
    error: (_, __) => 'Error',
  );
});
