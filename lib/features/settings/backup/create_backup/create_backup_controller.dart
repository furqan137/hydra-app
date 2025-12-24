import 'package:flutter/material.dart';
import 'create_backup_state.dart';

class CreateBackupController extends ChangeNotifier {
  CreateBackupState _state = const CreateBackupState();

  CreateBackupState get state => _state;

  final TextEditingController passwordController =
  TextEditingController();

  // ================= UI =================

  void togglePasswordVisibility() {
    _state = _state.copyWith(
      obscurePassword: !_state.obscurePassword,
    );
    notifyListeners();
  }

  // ================= BACKUP LOGIC =================

  Future<void> createBackup(BuildContext context) async {
    if (passwordController.text.isEmpty) {
      _showError(context, 'Backup password required');
      return;
    }

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    // 🔒 TODO: Encrypt vault + save backup
    await Future.delayed(const Duration(seconds: 2));

    _state = _state.copyWith(isLoading: false);
    notifyListeners();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backup created successfully'),
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
