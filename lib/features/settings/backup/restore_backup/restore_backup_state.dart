class RestoreBackupState {
  final bool isLoading;
  final bool obscurePassword;
  final String selectedBackup;

  const RestoreBackupState({
    this.isLoading = false,
    this.obscurePassword = true,
    this.selectedBackup = 'HidraBackup_04-24-24.abk',
  });

  RestoreBackupState copyWith({
    bool? isLoading,
    bool? obscurePassword,
    String? selectedBackup,
  }) {
    return RestoreBackupState(
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      selectedBackup: selectedBackup ?? this.selectedBackup,
    );
  }
}
