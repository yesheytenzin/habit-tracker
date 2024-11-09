import 'package:flutter/material.dart';
import 'package:habit_tracker/theme/light_mode.dart';
import 'package:habit_tracker/theme/dark_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  late SharedPreferences prefs;
  late ThemeData _themeData;

  ThemeProvider() {
    _themeData = lightmode; // Default to light mode
    _loadThemeFromPrefs(); // Load saved theme
  }

  // Initialize SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final bool isDark = prefs.getBool('isDarkMode') ?? false;
    _themeData = isDark ? darkmode : lightmode;
    notifyListeners();
  }

  // Get theme
  ThemeData get themedata => _themeData;

  // Check if dark mode
  bool get isDarkMode => _themeData == darkmode;

  // Toggle theme
  void toggleTheme() async {
    if (_themeData == lightmode) {
      _themeData = darkmode;
      await prefs.setBool('isDarkMode', true);
    } else {
      _themeData = lightmode;
      await prefs.setBool('isDarkMode', false);
    }
    notifyListeners();
  }
}