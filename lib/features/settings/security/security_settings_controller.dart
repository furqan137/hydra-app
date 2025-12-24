import 'package:flutter/material.dart';
import 'security_settings_state.dart';
import '../../auth/biometric_controller.dart';

class SecuritySettingsController extends ChangeNotifier {
  SecuritySettingsState _state = const SecuritySettingsState();
  SecuritySettingsState get state => _state;

  final BiometricController _biometricController = BiometricController();

  // ================= BIOMETRIC =================

  Future<void> toggleBiometric(bool enable, BuildContext context) async {
    /// 🔓 Disable biometric immediately
    if (!enable) {
      _state = _state.copyWith(biometricEnabled: false);
      notifyListeners();
      return;
    }

    /// 🔐 Enable biometric (authenticate once)
    final success = await _biometricController.enableBiometric();

    if (!success) {
      _showBiometricWarning(
        context,
        _biometricController.error,
      );
      return;
    }

    /// ✅ Enabled successfully
    _state = _state.copyWith(biometricEnabled: true);
    notifyListeners();
  }

  // ================= AUTO LOCK =================

  void setAutoLockTimeout(AutoLockTimeout timeout) {
    _state = _state.copyWith(autoLockTimeout: timeout);
    notifyListeners();
  }

  // ================= NAVIGATION =================

  void openChangePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _PlaceholderScreen(
          title: 'Change Password',
        ),
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

/// TEMP PLACEHOLDER
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF050B18),
        title: Text(title),
      ),
      body: const Center(
        child: Text(
          'Coming Soon',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
