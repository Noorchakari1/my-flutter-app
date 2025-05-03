import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service to handle and track network connectivity
class ConnectivityService {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final _connectivityStreamController = StreamController<bool>.broadcast();

  /// Stream of connectivity status (true = connected, false = disconnected)
  Stream<bool> get connectivityStream => _connectivityStreamController.stream;

  /// Current connectivity status
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _initConnectivity();
    _setupConnectivityListener();
  }

  /// Initialize connectivity status
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(results);
    } catch (e) {
      // Default to connected if we can't check
      _isConnected = true;
    }
  }

  /// Set up a listener for connectivity changes
  void _setupConnectivityListener() {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectivityStatus);
  }

  /// Update connectivity status and notify listeners
  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    
    // We're connected if ANY of the connectivity results are not "none"
    _isConnected = results.any((result) => result != ConnectivityResult.none);
    
    // Only notify if status changed
    if (wasConnected != _isConnected) {
      _connectivityStreamController.add(_isConnected);
    }
  }

  /// Check current connectivity
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(results);
      return _isConnected;
    } catch (e) {
      return _isConnected;
    }
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectivityStreamController.close();
  }
}

/// Provider for connectivity service
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// Simple provider to watch connectivity status
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.connectivityStream;
});

/// Provider for current connectivity status
final isConnectedProvider = Provider<bool>((ref) {
  final connectivityStatus = ref.watch(connectivityStatusProvider);
  return connectivityStatus.maybeWhen(
    data: (isConnected) => isConnected,
    orElse: () => true, // Default to true if we're not sure
  );
}); 