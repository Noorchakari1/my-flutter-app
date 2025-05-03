import 'package:flutter/material.dart';

import '../../core/services/api_exception.dart';
import '../constants/app_constants.dart';

/// A standardized widget to display API errors
class ErrorDisplay extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;
  final bool showHomeButton;
  final bool compact;

  const ErrorDisplay({
    super.key,
    required this.error,
    this.onRetry,
    this.showHomeButton = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final String errorMessage = _getErrorMessage(context);
    final IconData errorIcon = _getErrorIcon();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              errorIcon,
              size: compact ? 48 : 64,
              color: AppConstants.primaryColor.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 14 : 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 24),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(_getRetryText(context)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            if (showHomeButton)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                  child: Text(_getHomeButtonText(context)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Get appropriate error message
  String _getErrorMessage(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    if (error is ApiException) {
      final apiError = error as ApiException;
      return apiError.message;
    } else if (error is String) {
      return error;
    } else {
      // Use localized message based on user's language
      return _getLocalizedErrorMessage(language);
    }
  }

  /// Get localized error message
  String _getLocalizedErrorMessage(String language) {
    switch (language) {
      case 'fa': // Persian
        return AppConstants.persianText['cannotLoadData'] ?? 'خطا در بارگیری اطلاعات';
      case 'ps': // Pashto
        return AppConstants.pashtoText['cannotLoadData'] ?? 'د معلوماتو په بارولو کې ستونزه';
      case 'en': // English
      default:
        return AppConstants.englishText['cannotLoadData'] ?? 'Failed to load data';
    }
  }

  /// Get appropriate error icon based on error type
  IconData _getErrorIcon() {
    if (error is ApiException) {
      final apiError = error as ApiException;
      final errorCode = apiError.code;
      
      if (errorCode == 'no_connection') {
        return Icons.signal_wifi_off;
      } else if (errorCode == 'timeout') {
        return Icons.timer_off;
      } else if (apiError.statusCode == 404) {
        return Icons.search_off;
      } else if (apiError.statusCode == 401 || apiError.statusCode == 403) {
        return Icons.lock;
      }
    }
    
    // Default error icon
    return Icons.error_outline;
  }

  /// Get localized retry button text
  String _getRetryText(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    
    switch (language) {
      case 'fa': // Persian
        return AppConstants.persianText['tryAgain'] ?? 'تلاش مجدد';
      case 'ps': // Pashto
        return AppConstants.pashtoText['tryAgain'] ?? 'بیا هڅه وکړئ';
      case 'en': // English
      default:
        return AppConstants.englishText['tryAgain'] ?? 'Try Again';
    }
  }

  /// Get localized home button text
  String _getHomeButtonText(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    
    switch (language) {
      case 'fa': // Persian
        return AppConstants.persianText['backToHome'] ?? 'بازگشت به صفحه اصلی';
      case 'ps': // Pashto
        return AppConstants.pashtoText['backToHome'] ?? 'اصلي پاڼې ته ستنېدل';
      case 'en': // English
      default:
        return AppConstants.englishText['backToHome'] ?? 'Back to Home';
    }
  }
}

/// A version of ErrorDisplay specifically for displaying in list items
class ListItemErrorDisplay extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;

  const ListItemErrorDisplay({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplay(
      error: error,
      onRetry: onRetry,
      compact: true,
    );
  }
} 