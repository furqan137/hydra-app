import 'package:flutter/material.dart';
import 'restore_backup_state.dart';

class RestoreBackupController extends ChangeNotifier {
  RestoreBackupState _state = const RestoreBackupState();

  RestoreBackupState get state => _state;

  final TextEditingController passwordController =
  TextEditingController();

  // ================= UI =================

  void togglePasswordVisibility() {
    _state = _state.copyWith(
      obscurePassword: !_state.obscurePassword,
    );
    notifyListeners();
  }

  // ================= RESTORE LOGIC =================

  Future<void> restoreBackup(BuildContext context) async {
    if (passwordController.text.isEmpty) {
      _showError(context, 'Password required to restore backup');
      return;
    }

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    // 🔓 TODO: Decrypt backup + restore vault
    await Future.delayed(const Duration(seconds: 2));

    _state = _state.copyWith(isLoading: false);
    notifyListeners();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backup restored successfully'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }
}
