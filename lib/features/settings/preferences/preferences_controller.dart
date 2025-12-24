import 'package:flutter/material.dart';
import 'preferences_state.dart';

class PreferencesController extends ChangeNotifier {
  PreferencesState _state = const PreferencesState();

  PreferencesState get state => _state;

  void setStartPage(StartPage page) {
    _state = _state.copyWith(startPage: page);
    notifyListeners();
  }

  void setTheme(AppTheme theme) {
    _state = _state.copyWith(theme: theme);
    notifyListeners();
  }
}
