import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'create_backup_state.dart';
import '../../../../../services/local_backup_service.dart';

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

  // ================= BACKUP =================

  Future<void> createBackup(BuildContext context) async {
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      _showError(context, 'Backup password required');
      return;
    }

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await LocalBackupService.createBackup(password: password);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup created successfully'),
          backgroundColor: Colors.teal,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Backup cancelled or failed');
      }
    } finally {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    }
  }


  // ================= HELPERS =================

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
