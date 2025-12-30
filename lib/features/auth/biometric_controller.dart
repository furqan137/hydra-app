import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/biometric_service.dart';

class BiometricController extends ChangeNotifier {
  static final BiometricController _instance = BiometricController._internal();
  factory BiometricController() => _instance;
  BiometricController._internal() {
    loadEnabled();
  }

  static const _prefsKey = 'biometric_enabled';
  bool _enabled = false;
  String? _error;

  bool get isEnabled => _enabled;
  String? get error => _error;

  Future<void> loadEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_prefsKey) ?? false;
    notifyListeners();
  }

  Future<void> _saveEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
  }

  // ================= AVAILABILITY =================

  /// True only if:
  /// - device supports biometrics
  /// - at least one fingerprint / face is enrolled
  Future<bool> canUseBiometrics() async {
    try {
      return await BiometricService.canUseBiometrics();
    } catch (_) {
      return false;
    }
  }

  // ================= ENABLE =================

  /// Authenticate ONCE to enable biometric in app
  Future<bool> enableBiometric() async {
    _error = null;
    notifyListeners();

    final canUse = await BiometricService.canUseBiometrics();
    if (!canUse) {
      _error =
      'No fingerprint or face unlock found.\n'
          'Please add one in phone settings first.';
      notifyListeners();
      return false;
    }

    try {
      await BiometricService.authenticate(
        reason: 'Authenticate to enable biometric unlock',
      );
      _enabled = true;
      await _saveEnabled(true);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ================= DISABLE =================

  void disableBiometric() async {
    _enabled = false;
    _error = null;
    await _saveEnabled(false);
    notifyListeners();
  }
}
