import 'package:flutter/material.dart';
import '../../../../core/security/secure_storage.dart';
import 'change_password_state.dart';

class ChangePasswordController extends ChangeNotifier {
  ChangePasswordState _state = const ChangePasswordState();
  ChangePasswordState get state => _state;

  void toggleOld() {
    _state = _state.copyWith(obscureOld: !_state.obscureOld);
    notifyListeners();
  }

  void toggleNew() {
    _state = _state.copyWith(obscureNew: !_state.obscureNew);
    notifyListeners();
  }

  void toggleConfirm() {
    _state = _state.copyWith(obscureConfirm: !_state.obscureConfirm);
    notifyListeners();
  }

  Future<String?> changePin({
    required String oldPin,
    required String newPin,
    required String confirmPin,
  }) async {
    if (oldPin.isEmpty || newPin.isEmpty || confirmPin.isEmpty) {
      return 'Please fill all fields';
    }

    if (newPin.length != 6 || confirmPin.length != 6) {
      return 'PIN must be exactly 6 digits';
    }

    if (newPin != confirmPin) {
      return 'New PINs do not match';
    }

    final savedPin = await SecureStorage.readPin();
    if (savedPin != oldPin) {
      return 'Current PIN is incorrect';
    }

    await SecureStorage.savePin(newPin);
    return null; // success
  }
}
