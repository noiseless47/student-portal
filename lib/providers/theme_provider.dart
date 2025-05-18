import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoading = true;
  
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  ThemeProvider() {
    loadThemeMode();
  }
  
  Future<void> loadThemeMode() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeMode = prefs.getInt(_themeKey);
      
      if (savedThemeMode != null) {
        _themeMode = ThemeMode.values[savedThemeMode];
      }
    } catch (error) {
      debugPrint('Error loading theme mode: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    
    _themeMode = themeMode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
    } catch (error) {
      debugPrint('Error saving theme mode: $error');
    }
  }
  
  Future<void> toggleTheme() async {
    final newThemeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newThemeMode);
  }
} 