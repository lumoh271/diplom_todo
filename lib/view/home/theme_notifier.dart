import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  bool _isDarkMode = false;
  static const String _themeKey = 'isDarkMode';

  ThemeNotifier() {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  Color get backgroundColor => _isDarkMode ? const Color(0xFF121212) : Colors.white;
  Color get textColor => _isDarkMode ? Colors.white : Colors.black;
  Color get primaryColor => const Color(0xff4568dc);

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
}