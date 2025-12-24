import 'package:flutter/material.dart';
import 'create_password_state.dart';

class CreatePasswordController extends ChangeNotifier {
  CreatePasswordState _state = CreatePasswordState();

  CreatePasswordState get state => _state;

  void togglePasswordVisibility() {
    _state = _state.copyWith(
      obscurePassword: !_state.obscurePassword,
    );
    notifyListeners();
  }

  void toggleConfirmVisibility() {
    _state = _state.copyWith(
      obscureConfirm: !_state.obscureConfirm,
    );
    notifyListeners();
  }

  void updateStrength(String password) {
    double strength = 0;

    if (password.length >= 6) strength += 0.3;
    if (password.length >= 10) strength += 0.3;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;

    _state = _state.copyWith(strength: strength.clamp(0.0, 1.0));
    notifyListeners();
  }
}
