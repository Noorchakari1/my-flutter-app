import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'is_dark_mode';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> isDarkMode() async {
    return _prefs?.getBool(_themeKey) ?? false;
  }

  static Future<void> setDarkMode(bool isDark) async {
    await _prefs?.setBool(_themeKey, isDark);
  }

  static ThemeData getTheme(bool isDarkMode, String language) {
    // final isRTL = language == 'persian' || language == 'pashto';
    
    return ThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: const Color(0xff1B047C),
      scaffoldBackgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xff1B047C),
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Vazirmatn',
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'Vazirmatn',
        ),
        displayMedium: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'Vazirmatn',
        ),
        displaySmall: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'Vazirmatn',
        ),
        headlineLarge: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'Vazirmatn',
        ),
        headlineMedium: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'Vazirmatn',
        ),
        headlineSmall: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'Vazirmatn',
        ),
        titleLarge: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'Vazirmatn',
        ),
        titleMedium: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'Vazirmatn',
        ),
        titleSmall: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'Vazirmatn',
        ),
        bodyLarge: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'Vazirmatn',
        ),
        bodyMedium: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'Vazirmatn',
        ),
        bodySmall: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'Vazirmatn',
        ),
        labelLarge: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'Vazirmatn',
        ),
        labelMedium: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'Vazirmatn',
        ),
        labelSmall: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'Vazirmatn',
        ),
      ),
      iconTheme: IconThemeData(
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: isDarkMode ? Colors.white : Colors.black87,
        textColor: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }
} 