enum AutoLockTimeout {
  immediate,
  oneMinute,
  fiveMinutes,
  tenMinutes,
}

class SecuritySettingsState {
  final bool biometricEnabled;
  final AutoLockTimeout autoLockTimeout;

  const SecuritySettingsState({
    this.biometricEnabled = false, // ✅ safer default
    this.autoLockTimeout = AutoLockTimeout.oneMinute,
  });

  SecuritySettingsState copyWith({
    bool? biometricEnabled,
    AutoLockTimeout? autoLockTimeout,
  }) {
    return SecuritySettingsState(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
    );
  }
}
