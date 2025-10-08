import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _gradientKey = 'gradient_index';

  int _gradientIndex = 0;
  bool _isInitialized = false;
  bool _isDarkMode = true;

  int get gradientIndex => _gradientIndex;
  bool get isInitialized => _isInitialized;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadGradientIndex();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadGradientIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getInt(_gradientKey);
      if (index != null) {
        _gradientIndex = index;
      }
    } catch (e) {
      debugPrint('Error loading gradient index: $e');
    }
  }

  Future<void> setGradientIndex(int index) async {
    if (_gradientIndex == index) return;
    _gradientIndex = index;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_gradientKey, index);
    } catch (e) {
      debugPrint('Error saving gradient index: $e');
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
