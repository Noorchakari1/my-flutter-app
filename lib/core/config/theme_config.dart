import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Theme configuration for the application
class ThemeConfig {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: AppConstants.backgroundColor,
      fontFamily: 'Vazirmatn',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        titleTextStyle: AppConstants.appBarTitleStyle,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: 'Vazirmatn',
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          fontFamily: 'Vazirmatn',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontFamily: 'Vazirmatn',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontFamily: 'Vazirmatn',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.defaultPadding / 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(AppConstants.defaultPadding / 2),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: Colors.grey[900],
      fontFamily: 'Vazirmatn',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        titleTextStyle: AppConstants.appBarTitleStyle,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Vazirmatn',
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Vazirmatn',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white70,
          fontFamily: 'Vazirmatn',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white70,
          fontFamily: 'Vazirmatn',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.defaultPadding / 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(AppConstants.defaultPadding / 2),
        color: Colors.grey[800],
      ),
    );
  }
} 