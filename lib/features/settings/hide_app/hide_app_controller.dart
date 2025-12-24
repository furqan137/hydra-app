import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'hide_app_state.dart';

class HideAppController extends ChangeNotifier {
  // ================= STORAGE KEYS =================
  static const String _hiddenKey = 'hide_app_enabled';
  static const String _dialCodeKey = 'hide_app_dial_code';

  // ================= METHOD CHANNEL =================
  /// Android native implementation will live in MainActivity
  static const MethodChannel _channel = MethodChannel('hide_app');

  // ================= STATE =================
  HideAppState _state = HideAppState();
  HideAppState get state => _state;

  bool get isHidden => _state.isHidden;
  String get dialCode => _state.dialCode;

  // ================= INIT =================
  HideAppController() {
    _load();
  }

  // ================= LOAD =================
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    _state = _state.copyWith(
      isHidden: prefs.getBool(_hiddenKey) ?? false,
      dialCode: prefs.getString(_dialCodeKey) ?? '*#*#13710#*#*',
    );

    notifyListeners();
  }

  // ================= TOGGLE HIDE =================
  /// hide = true  → Hidra ❌ | Fake Phone ✅
  /// hide = false → Hidra ✅ | Fake Phone ❌
  Future<bool> toggleHidden(bool hide) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // 🔑 Call native FIRST (prevents launcher desync)
      if (Platform.isAndroid) {
        await _channel.invokeMethod(hide ? 'hide' : 'show');
      }

      // Persist only after native success
      await prefs.setBool(_hiddenKey, hide);

      _state = _state.copyWith(isHidden: hide);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ HideApp toggle failed: $e');
      return false;
    }
  }

  // ================= UPDATE DIAL CODE =================
  /// Dial code is for UX only.
  /// Real detection is handled by Android SECRET_CODE receiver.
  Future<bool> updateDialCode(String code) async {
    final cleaned = code.trim();

    if (cleaned.isEmpty || cleaned.length < 4) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dialCodeKey, cleaned);

    _state = _state.copyWith(dialCode: cleaned);
    notifyListeners();
    return true;
  }
}
