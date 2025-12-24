class CreateBackupState {
  final bool isLoading;
  final bool obscurePassword;
  final String backupLocation;

  const CreateBackupState({
    this.isLoading = false,
    this.obscurePassword = true,
    this.backupLocation = 'Google Drive / HidraBackup',
  });

  CreateBackupState copyWith({
    bool? isLoading,
    bool? obscurePassword,
    String? backupLocation,
  }) {
    return CreateBackupState(
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      backupLocation: backupLocation ?? this.backupLocation,
    );
  }
}
