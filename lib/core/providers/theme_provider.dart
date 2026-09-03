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
      themeVariant: 'light',
      currentLanguage: 'english',
    );
  }

  Future<void> _loadInitialState() async {
    final themeVariant = await ThemeService.themeVariant();
    final language = await LanguageService.getSelectedLanguage() ?? 'english';
    state = ThemeState(
      themeVariant: themeVariant,
      currentLanguage: language,
    );
  }

  Future<void> toggleTheme() async {
    await setThemeVariant(state.isDarkMode ? 'light' : 'dark');
  }

  Future<void> setThemeVariant(String variant) async {
    await ThemeService.setThemeVariant(variant);
    state = state.copyWith(themeVariant: variant);
  }

  Future<void> setLanguage(String language) async {
    state = state.copyWith(currentLanguage: language);
  }

  ThemeData get theme => ThemeService.getTheme(state.themeVariant, state.currentLanguage);
}

@immutable
class ThemeState {
  final String themeVariant;
  final String currentLanguage;

  bool get isDarkMode => themeVariant == 'dark' || themeVariant == 'golden';
  bool get isGolden => themeVariant == 'golden';

  const ThemeState({
    required this.themeVariant,
    required this.currentLanguage,
  });

  ThemeState copyWith({
    String? themeVariant,
    String? currentLanguage,
  }) {
    return ThemeState(
      themeVariant: themeVariant ?? this.themeVariant,
      currentLanguage: currentLanguage ?? this.currentLanguage,
    );
  }
}
