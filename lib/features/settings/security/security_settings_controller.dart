import 'package:flutter/material.dart';
import 'security_settings_state.dart';
import '../../auth/biometric_controller.dart';
import 'change_password/change_password_screen.dart';

class SecuritySettingsController extends ChangeNotifier {
  SecuritySettingsState _state = const SecuritySettingsState();
  SecuritySettingsState get state => _state;

  final BiometricController _biometricController = BiometricController();

  SecuritySettingsController() {
    _syncBiometricState();
  }

  Future<void> _syncBiometricState() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _state = _state.copyWith(
      biometricEnabled: _biometricController.isEnabled,
    );
    notifyListeners();
  }

  // ================= BIOMETRIC =================

  Future<void> toggleBiometric(bool enable, BuildContext context) async {
    /// 🔓 Disable biometric immediately
    if (!enable) {
      _biometricController.disableBiometric();
      await _syncBiometricState();
      return;
    }

    /// 🔐 Enable biometric (authenticate once)
    final success = await _biometricController.enableBiometric();

    if (!success) {
      _showBiometricWarning(
        context,
        _biometricController.error,
      );
      await _syncBiometricState();
      return;
    }

    /// ✅ Enabled successfully
    await _syncBiometricState();
  }

  // ================= AUTO LOCK =================

  void setAutoLockTimeout(AutoLockTimeout timeout) {
    _state = _state.copyWith(autoLockTimeout: timeout);
    notifyListeners();
  }

  // ================= NAVIGATION =================
  // ✅ ONLY CHANGE IS HERE

  void openChangePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChangePasswordScreen(),
      ),
    );
  }

  // ================= WARNING DIALOG =================

  void _showBiometricWarning(
      BuildContext context,
      String? message,
      ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF101B2B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'Biometric not available',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          message ??
              'Please add fingerprint or face unlock in your phone settings first.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
