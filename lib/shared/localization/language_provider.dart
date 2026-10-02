import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_strings.dart';
import 'app_translations.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  /// Alias for [locale]. Kept so screens referencing `currentLocale`
  /// (e.g. BookingDetailsScreen) work without renaming call sites.
  Locale get currentLocale => _locale;

  String translate(String key) {
    return AppStrings.translations[_locale.languageCode]?[key] ?? key;
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final languageCode = prefs.getString('selected_language') ?? 'en';

    _locale = Locale(languageCode);
    AppTranslations.setLanguageCode(languageCode);

    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('selected_language', languageCode);

    _locale = Locale(languageCode);
    AppTranslations.setLanguageCode(languageCode);

    notifyListeners();
  }
}