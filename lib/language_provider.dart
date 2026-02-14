import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'hi'; // Default: Hindi

  String get currentLanguage => _currentLanguage;
  bool get isHindi => _currentLanguage == 'hi';
  bool get isEnglish => _currentLanguage == 'en';

  LanguageProvider() {
    _loadLanguagePreference();
  }

  // Load saved language preference
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('app_language') ?? 'hi'; // Default: Hindi
    notifyListeners();
  }

  // Change language
  Future<void> setLanguage(String languageCode) async {
    if (languageCode != _currentLanguage) {
      _currentLanguage = languageCode;

      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', languageCode);

      notifyListeners();
    }
  }

  // Toggle between Hindi and English
  Future<void> toggleLanguage() async {
    final newLanguage = _currentLanguage == 'hi' ? 'en' : 'hi';
    await setLanguage(newLanguage);
  }
}