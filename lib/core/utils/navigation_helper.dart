import 'package:flutter/material.dart';
import '../services/loading_manager.dart';

/// Helper class for navigation with loading states
class NavigationHelper {
  /// Navigate to a new screen with loading indicator
  static Future<T?> navigateWithLoading<T extends Object?>(
    BuildContext context, {
    required Widget destination,
    String? loadingMessage,
    Duration loadingDuration = const Duration(milliseconds: 300),
    bool showLoadingOverlay = true,
  }) async {
    if (showLoadingOverlay) {
      return LoadingManager.navigateWithGlobalLoading<T>(
        context,
        destination: destination,
        loadingMessage: loadingMessage,
        loadingDuration: loadingDuration,
      );
    }

    // Check if context is still mounted before navigation
    if (!context.mounted) return null;

    // Navigate to the destination
    return Navigator.of(context).push<T>(
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  /// Navigate to a named route with loading indicator
  static Future<T?> navigateToRouteWithLoading<T extends Object?>(
    BuildContext context, {
    required String routeName,
    Object? arguments,
    String? loadingMessage,
    Duration loadingDuration = const Duration(milliseconds: 300),
    bool showLoadingOverlay = true,
  }) async {
    if (showLoadingOverlay) {
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

        // Navigate to the named route
        return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
      } catch (e) {
        // Hide loading on error
        manager.hideGlobalLoading();
        rethrow;
      }
    }

    // Check if context is still mounted before navigation
    if (!context.mounted) return null;

    // Navigate to the named route
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Replace current screen with loading indicator
  static Future<T?> replaceWithLoading<T extends Object?, TO extends Object?>(
    BuildContext context, {
    required Widget destination,
    String? loadingMessage,
    Duration loadingDuration = const Duration(milliseconds: 300),
    bool showLoadingOverlay = true,
    TO? result,
  }) async {
    if (showLoadingOverlay) {
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

        // Replace current screen
        return Navigator.of(context).pushReplacement<T, TO>(
          MaterialPageRoute(builder: (context) => destination),
          result: result,
        );
      } catch (e) {
        // Hide loading on error
        manager.hideGlobalLoading();
        rethrow;
      }
    }

    // Check if context is still mounted before navigation
    if (!context.mounted) return null;

    // Replace current screen
    return Navigator.of(context).pushReplacement<T, TO>(
      MaterialPageRoute(builder: (context) => destination),
      result: result,
    );
  }
}
