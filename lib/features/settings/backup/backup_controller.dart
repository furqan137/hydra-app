import 'package:flutter/material.dart';
import 'backup_state.dart';

class BackupController extends ChangeNotifier {
  BackupState _state = const BackupState();

  BackupState get state => _state;

  void setProcessing(bool value) {
    _state = _state.copyWith(isProcessing: value);
    notifyListeners();
  }

  // ================= CREATE BACKUP =================
  Future<void> createBackup() async {
    setProcessing(true);

    // 🔐 TODO: Encrypt + export vault data
    await Future.delayed(const Duration(seconds: 2));

    setProcessing(false);
  }

  // ================= RESTORE BACKUP =================
  Future<void> restoreBackup() async {
    setProcessing(true);

    // 🔓 TODO: Decrypt + restore vault data
    await Future.delayed(const Duration(seconds: 2));

    setProcessing(false);
  }
}
