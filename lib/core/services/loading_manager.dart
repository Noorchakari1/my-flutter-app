import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/navigation_loading_overlay.dart';

/// Global loading manager to prevent multiple loading indicators
/// from appearing simultaneously and provide a unified loading experience
class LoadingManager {
  static LoadingManager? _instance;
  static LoadingManager get instance => _instance ??= LoadingManager._();
  LoadingManager._();

  bool _isGlobalLoading = false;
  BuildContext? _currentContext;

  /// Check if global loading is currently active
  bool get isGlobalLoading => _isGlobalLoading;

  /// Show global loading overlay
  /// This will prevent other loading indicators from showing
  void showGlobalLoading(BuildContext context, {String? message}) {
    if (_isGlobalLoading) return; // Prevent multiple overlays

    _isGlobalLoading = true;
    _currentContext = context;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(102), // ~0.4 opacity
      builder: (context) => NavigationLoadingOverlay(
        isVisible: true,
        message: message,
      ),
    );
  }

  /// Hide global loading overlay
  void hideGlobalLoading() {
    if (!_isGlobalLoading || _currentContext == null) return;

    _isGlobalLoading = false;
    Navigator.of(_currentContext!, rootNavigator: true).pop();
    _currentContext = null;
  }

  /// Update loading message without hiding/showing overlay
  void updateLoadingMessage(String message) {
    if (!_isGlobalLoading || _currentContext == null) return;

    // Note: For now, we'll hide and show with new message
    // In a production app, you might want to implement a more sophisticated update mechanism
    hideGlobalLoading();
    if (_currentContext != null) {
      showGlobalLoading(_currentContext!, message: message);
    }
  }

  /// Execute an operation with global loading
  static Future<T> withGlobalLoading<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? loadingMessage,
    Duration minimumLoadingDuration = const Duration(milliseconds: 500),
  }) async {
    final manager = LoadingManager.instance;

    try {
      // Show loading
      manager.showGlobalLoading(context, message: loadingMessage);

      // Execute operation with minimum loading duration
      final results = await Future.wait([
        operation(),
        Future.delayed(minimumLoadingDuration),
      ]);

      return results[0] as T;
    } finally {
      // Always hide loading, even if operation fails
      manager.hideGlobalLoading();
    }
  }

  /// Execute navigation with global loading
  static Future<T?> navigateWithGlobalLoading<T extends Object?>(
    BuildContext context, {
    required Widget destination,
    String? loadingMessage,
    Duration loadingDuration = const Duration(milliseconds: 300),
  }) async {
    final manager = LoadingManager.instance;

    try {
      // Show loading
      manager.showGlobalLoading(context, message: loadingMessage);

      // Wait for the specified duration
      await Future.delayed(loadingDuration);

      // Hide loading before navigation
      manager.hideGlobalLoading();

      // Check if context is still mounted before navigation
      if (!context.mounted) return null;

      // Navigate to the destination
      return Navigator.of(context).push<T>(
        MaterialPageRoute(builder: (context) => destination),
      );
    } catch (e) {
      // Hide loading on error
      manager.hideGlobalLoading();
      rethrow;
    }
  }
}

/// Riverpod provider for loading manager state
final loadingManagerProvider = StateNotifierProvider<LoadingManagerNotifier, LoadingState>((ref) {
  return LoadingManagerNotifier();
});

/// State class for loading manager
class LoadingState {
  final bool isLoading;
  final String? message;
  final LoadingType type;

  const LoadingState({
    this.isLoading = false,
    this.message,
    this.type = LoadingType.global,
  });

  LoadingState copyWith({
    bool? isLoading,
    String? message,
    LoadingType? type,
  }) {
    return LoadingState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      type: type ?? this.type,
    );
  }
}

/// Types of loading states
enum LoadingType {
  global,      // Full screen loading
  navigation,  // Navigation loading
  item,        // Individual item loading
  refresh,     // Pull to refresh
}

/// Notifier for loading manager state
class LoadingManagerNotifier extends StateNotifier<LoadingState> {
  LoadingManagerNotifier() : super(const LoadingState());

  void showLoading({String? message, LoadingType type = LoadingType.global}) {
    state = state.copyWith(
      isLoading: true,
      message: message,
      type: type,
    );
  }

  void hideLoading() {
    state = state.copyWith(
      isLoading: false,
      message: null,
    );
  }

  void updateMessage(String message) {
    if (state.isLoading) {
      state = state.copyWith(message: message);
    }
  }
}
