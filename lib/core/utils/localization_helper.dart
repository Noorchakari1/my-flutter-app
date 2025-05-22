import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_constants.dart';
import '../providers/theme_provider.dart';

/// Helper class for localization-related functionality
class LocalizationHelper {
  /// Get localized text based on the current language
  static String getText(WidgetRef ref, String key) {
    final language = ref.watch(themeNotifierProvider).currentLanguage;
    return getTextForLanguage(language, key);
  }

  /// Get localized text for a specific language
  static String getTextForLanguage(String language, String key) {
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
    return textMap[key] ?? key; // Return key if translation not found
  }

  /// Check if the current language is RTL
  static bool isRTL(WidgetRef ref) {
    final language = ref.watch(themeNotifierProvider).currentLanguage;
    return language == 'persian' || language == 'pashto';
  }

  /// Get text direction based on the current language
  static TextDirection getTextDirection(WidgetRef ref) {
    return isRTL(ref) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get current language from theme provider
  static String getCurrentLanguage(WidgetRef ref) {
    return ref.watch(themeNotifierProvider).currentLanguage;
  }

  /// Strip HTML tags from content (useful for search and display)
  static String stripHtmlTags(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  /// Format a string by replacing placeholders with values
  /// Example: formatString("Hello {name}", {"name": "World"}) => "Hello World"
  static String formatString(String template, Map<String, String> values) {
    String result = template;
    values.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
