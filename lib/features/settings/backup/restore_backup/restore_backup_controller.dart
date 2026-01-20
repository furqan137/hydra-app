import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import 'restore_backup_state.dart';
import '../../../../../services/local_backup_service.dart';
import '../../../vault/vault_controller.dart';
import '../../../albums/albums_state.dart';

class RestoreBackupController extends ChangeNotifier {
  RestoreBackupState _state = const RestoreBackupState();
  RestoreBackupState get state => _state;

  final TextEditingController passwordController = TextEditingController();

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
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null) return;

      final path = result.files.single.path;
      if (path == null) return;

      if (!path.toLowerCase().endsWith('.hidra')) return;

      final file = File(path);
      if (!file.existsSync()) return;

      _state = _state.copyWith(selectedBackup: file);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Backup picker error: $e');
    }
  }

  // ================= RESTORE (KEPT AS REQUESTED) =================

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
      // 🔐 RESTORE FILES + METADATA
      await LocalBackupService.restoreBackup(
        password: password,
        backupFile: _state.selectedBackup!,
      );

      if (!context.mounted) return;

      // 🔥 FIX: reload AFTER restore is fully done
      await _reloadAppState(context);

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
        _showError(context, 'Incorrect password or corrupted backup');
      }
    } finally {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  // ================= STATE RELOAD (FIXED & SAFE) =================

  Future<void> _reloadAppState(BuildContext context) async {
    try {
      // IMPORTANT: read providers ONCE
      final vaultController =
      Provider.of<VaultController>(context, listen: false);
      final albumsState =
      Provider.of<AlbumsState>(context, listen: false);

      // Reload vault & albums
      await vaultController.reloadAfterRestore();
      await albumsState.reloadFromStorage();

      debugPrint('✅ App state reloaded after restore');
    } catch (e) {
      debugPrint('❌ State reload error: $e');
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
