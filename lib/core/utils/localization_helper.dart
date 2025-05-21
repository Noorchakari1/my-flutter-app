import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../../shared/constants/app_constants.dart';

/// Helper class for localization-related functionality
class LocalizationHelper {
  /// Get localized text based on the current language
  static String getText(WidgetRef ref, String key) {
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
}
