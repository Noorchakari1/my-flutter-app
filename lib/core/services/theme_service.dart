import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'is_dark_mode';
  static const String _themeVariantKey = 'theme_variant';
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

  static Future<String> themeVariant() async {
    final saved = _prefs?.getString(_themeVariantKey);
    if (saved != null) return saved;
    return await isDarkMode() ? 'dark' : 'light';
  }

  static Future<void> setThemeVariant(String variant) async {
    await _prefs?.setString(_themeVariantKey, variant);
    // Retain the legacy preference so existing installs migrate safely.
    await setDarkMode(variant == 'dark');
  }

  static ThemeData getTheme(String variant, String language) {
    final isGolden = variant == 'golden';
    final isDarkMode = variant == 'dark' || isGolden;
    const primary = Color(0xff1B047C);
    const secondary = Color(0xffE8B64A);
    // Muted antique gold: formal and accessible, not a saturated yellow.
    const gold = Color(0xFFB08D57);
    final themePrimary = isGolden ? gold : primary;
    // The light palette uses a cool porcelain canvas instead of a flat white
    // surface. It gives the indigo brand colour room to breathe and keeps cards
    // visually distinct without relying on heavy shadows.
    final surface = isGolden
        ? const Color(0xFF0B0B0D)
        : isDarkMode ? const Color(0xFF171526) : const Color(0xFFF1F6FF);
    final onSurface = isGolden || isDarkMode ? Colors.white : const Color(0xFF20243A);

    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: themePrimary,
        primary: themePrimary,
        secondary: isGolden ? const Color(0xFFF7F1E3) : secondary,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        surface: surface,
      ),
      primaryColor: themePrimary,
      scaffoldBackgroundColor: surface,
      appBarTheme: AppBarTheme(
        backgroundColor: isGolden ? const Color(0xFF15120E) : themePrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: isGolden ? gold : Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Vazirmatn',
        ),
        iconTheme: IconThemeData(color: isGolden ? gold : Colors.white),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: onSurface,
          fontFamily: 'Vazirmatn',
        ),
        displayMedium: TextStyle(
          color: onSurface,
          fontFamily: 'Vazirmatn',
        ),
        displaySmall: TextStyle(
          color: onSurface,
          fontFamily: 'Vazirmatn',
        ),
        headlineLarge: TextStyle(
          color: onSurface,
          fontFamily: 'Vazirmatn',
        ),
        headlineMedium: TextStyle(
          color: onSurface,
          fontFamily: 'Vazirmatn',
        ),
        headlineSmall: TextStyle(
          color: onSurface,
          fontFamily: 'Vazirmatn',
        ),
        titleLarge: TextStyle(
          color: onSurface,
          fontFamily: 'Vazirmatn',
        ),
        titleMedium: TextStyle(
          color: onSurface,
          fontFamily: 'Vazirmatn',
        ),
        titleSmall: TextStyle(
          color: onSurface,
          fontFamily: 'Vazirmatn',
        ),
        bodyLarge: TextStyle(
          color: onSurface,
          fontFamily: 'Vazirmatn',
        ),
        bodyMedium: TextStyle(
          color: onSurface,
          fontFamily: 'Vazirmatn',
        ),
        bodySmall: TextStyle(
          color: onSurface,
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
      cardTheme: CardThemeData(
        color: isGolden
            ? const Color(0xFF15130F)
            : isDarkMode
                ? const Color(0xFF211E34)
                : const Color(0xFFFFFFFF),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isDarkMode
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFE5E9F4)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isGolden ? gold.withAlpha(80) : isDarkMode ? Colors.white12 : const Color(0xFFE1E6F0),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: isGolden ? gold : Colors.white,
        unselectedLabelColor: isGolden ? const Color(0xFFF7F1E3).withAlpha(170) : Colors.white.withAlpha(170),
        indicatorColor: isGolden ? gold : Colors.white,
        dividerColor: isGolden ? gold.withAlpha(80) : Colors.white24,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isGolden ? gold : primary,
        foregroundColor: isGolden ? Colors.black : Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isGolden ? gold : primary,
          foregroundColor: isGolden ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isGolden ? const Color(0xFF15130F) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isGolden ? gold.withAlpha(130) : const Color(0xFFE5E3EE)),
        ),
      ),
    );
  }
}
