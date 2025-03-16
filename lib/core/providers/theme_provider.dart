import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/language_service.dart';
import '../services/theme_service.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeState build() {
    _loadInitialState();
    return const ThemeState(
      isDarkMode: false,
      currentLanguage: 'english',
    );
  }

  Future<void> _loadInitialState() async {
    final isDarkMode = await ThemeService.isDarkMode();
    final language = await LanguageService.getSelectedLanguage() ?? 'english';
    state = ThemeState(
      isDarkMode: isDarkMode,
      currentLanguage: language,
    );
  }

  Future<void> toggleTheme() async {
    final newIsDarkMode = !state.isDarkMode;
    await ThemeService.setDarkMode(newIsDarkMode);
    state = state.copyWith(isDarkMode: newIsDarkMode);
  }

  Future<void> setLanguage(String language) async {
    state = state.copyWith(currentLanguage: language);
  }

  ThemeData get theme => ThemeService.getTheme(state.isDarkMode, state.currentLanguage);
}

@immutable
class ThemeState {
  final bool isDarkMode;
  final String currentLanguage;

  const ThemeState({
    required this.isDarkMode,
    required this.currentLanguage,
  });

  ThemeState copyWith({
    bool? isDarkMode,
    String? currentLanguage,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currentLanguage: currentLanguage ?? this.currentLanguage,
    );
  }
} 