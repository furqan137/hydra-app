import 'package:flutter/foundation.dart';

@immutable
class CreateBackupState {
  final bool isLoading;
  final bool obscurePassword;

  const CreateBackupState({
    this.isLoading = false,
    this.obscurePassword = true,
  });

  // ================= UI LABEL =================

  /// Fixed label (local backup only)
  String get backupLocationLabel => 'Local storage';

  // ================= COPY =================

  CreateBackupState copyWith({
    bool? isLoading,
    bool? obscurePassword,
  }) {
    return CreateBackupState(
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}
