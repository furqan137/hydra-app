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

  bool _initialized = false;
  bool get isInitialized => _initialized;

  // ================= INIT =================
  PreferencesController() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    // 🔹 START PAGE
    StartPage startPage = _state.startPage;
    final startIndex = prefs.getInt(_startPageKey);
    if (startIndex != null &&
        startIndex >= 0 &&
        startIndex < StartPage.values.length) {
      startPage = StartPage.values[startIndex];
    }

    // 🔹 THEME
    AppTheme theme = _state.theme;
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null &&
        themeIndex >= 0 &&
        themeIndex < AppTheme.values.length) {
      theme = AppTheme.values[themeIndex];
    }

    _state = _state.copyWith(
      startPage: startPage,
      theme: theme,
    );

    _initialized = true;
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

  // ================= RESTORE SUPPORT =================
  /// 🔥 Call this after backup restore
  Future<void> reloadFromStorage() async {
    _initialized = false;
    notifyListeners();
    await _init();
  }
}
