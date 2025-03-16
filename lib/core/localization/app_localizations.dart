import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  String get languageCode => locale.languageCode;

  String translate(String key) {
    String languageKey;
    switch (locale.languageCode) {
      case 'fa':
        languageKey = 'persian';
        break;
      case 'ps':
        languageKey = 'pashto';
        break;
      default:
        languageKey = 'english';
    }

    final translations = AppConstants.localizedText[languageKey];
    return translations?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fa', 'ps'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
} 