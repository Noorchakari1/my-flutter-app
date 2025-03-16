import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<String?> getSelectedLanguage() async {
    return _prefs?.getString(_languageKey);
  }

  static Future<void> setSelectedLanguage(String language) async {
    await _prefs?.setString(_languageKey, language);
  }

  static Future<bool> isFirstTime() async {
    return _prefs?.getString(_languageKey) == null;
  }
} 