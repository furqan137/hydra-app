import 'dart:io';
import 'package:flutter/foundation.dart';

@immutable
class RestoreBackupState {
  final bool isLoading;
  final bool obscurePassword;
  final File? selectedBackup;

  const RestoreBackupState({
    this.isLoading = false,
    this.obscurePassword = true,
    this.selectedBackup,
  });

  String get selectedBackupName {
    return selectedBackup?.path.split('/').last ?? 'Tap to select backup';
  }

  RestoreBackupState copyWith({
    bool? isLoading,
    bool? obscurePassword,
    File? selectedBackup,
  }) {
    return RestoreBackupState(
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      selectedBackup: selectedBackup ?? this.selectedBackup,
    );
  }
}
