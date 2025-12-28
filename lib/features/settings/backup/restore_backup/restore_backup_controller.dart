import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'restore_backup_state.dart';
import '../../../../../services/local_backup_service.dart';

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

  // ================= PICK BACKUP FILE =================
  Future<void> pickBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // ✅ REQUIRED for Android
        allowMultiple: false,
        withData: false,
      );

      if (result == null) return;

      final path = result.files.single.path;
      if (path == null) {
        throw Exception('Invalid file path');
      }

      // ✅ MANUAL EXTENSION CHECK
      if (!path.toLowerCase().endsWith('.hidra')) {
        throw Exception('Please select a valid .hidra backup file');
      }

      final file = File(path);
      if (!file.existsSync()) {
        throw Exception('Backup file does not exist');
      }

      _state = _state.copyWith(selectedBackup: file);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ File picker error: $e');
    }
  }


  // ================= RESTORE =================

  Future<void> restoreBackup(BuildContext context) async {
    final password = passwordController.text.trim();

    if (_state.selectedBackup == null) {
      _showError(context, 'Please select a backup file');
      return;
    }

    if (password.isEmpty) {
      _showError(context, 'Password required to restore backup');
      return;
    }

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await LocalBackupService.restoreBackup(
        password: password,
        backupFile: _state.selectedBackup!,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup restored successfully'),
          backgroundColor: Colors.teal,
        ),
      );

      Navigator.pop(context);
    } catch (e, stack) {
      debugPrint('❌ Restore error: $e');
      debugPrintStack(stackTrace: stack);

      if (context.mounted) {
        _showError(context, 'Incorrect password');

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
