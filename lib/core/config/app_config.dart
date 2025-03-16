import 'package:flutter/material.dart';

/// Application configuration
class AppConfig {
  static const String appName = 'AOP Sites';
  static const String appVersion = '1.0.0';
  
  // Environment configurations
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  // API configurations
  static const int apiTimeout = 30000; // milliseconds
  static const int maxRetries = 3;
  
  // Cache configurations
  static const Duration cacheValidityDuration = Duration(hours: 24);
  static const int maxCacheSize = 50; // MB
  
  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('fa', 'AF'), // Persian
    Locale('ps', 'AF'), // Pashto
    Locale('en', 'US'), // English
  ];
  
  // Default locale
  static const Locale defaultLocale = Locale('fa', 'AF');
} 