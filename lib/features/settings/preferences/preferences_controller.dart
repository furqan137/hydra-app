import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'preferences_state.dart';

class PreferencesController extends ChangeNotifier {
  // ================= STORAGE KEYS =================
  static const String _startPageKey = 'start_page';
  static const String _themeKey = 'app_theme';

  // ================= STATE =================
  PreferencesState _state = const PreferencesState();
  PreferencesState get state => _state;

  // ================= INIT =================
  PreferencesController() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load start page
    final startIndex = prefs.getInt(_startPageKey);
    final startPage = (startIndex != null &&
        startIndex < StartPage.values.length)
        ? StartPage.values[startIndex]
        : _state.startPage;

    // Load theme
    final themeIndex = prefs.getInt(_themeKey);
    final theme = (themeIndex != null &&
        themeIndex < AppTheme.values.length)
        ? AppTheme.values[themeIndex]
        : _state.theme;

    _state = _state.copyWith(
      startPage: startPage,
      theme: theme,
    );

    notifyListeners();
  }

  // ================= START PAGE =================

  Future<void> setStartPage(StartPage page) async {
    if (_state.startPage == page) return;

    _state = _state.copyWith(startPage: page);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_startPageKey, page.index);
  }

  // ================= THEME =================

  Future<void> setTheme(AppTheme theme) async {
    if (_state.theme == theme) return;

    _state = _state.copyWith(theme: theme);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
  }
}
