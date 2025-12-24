import 'package:flutter/material.dart';
import '../../services/biometric_service.dart';

class BiometricController extends ChangeNotifier {
  bool _enabled = false;
  String? _error;

  bool get isEnabled => _enabled;
  String? get error => _error;

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

    final authenticated = await BiometricService.authenticate(
      reason: 'Authenticate to enable biometric unlock',
    );

    if (!authenticated) {
      _error = 'Biometric authentication failed';
      notifyListeners();
      return false;
    }

    _enabled = true;
    notifyListeners();
    return true;
  }

  // ================= DISABLE =================

  void disableBiometric() {
    _enabled = false;
    _error = null;
    notifyListeners();
  }
}
