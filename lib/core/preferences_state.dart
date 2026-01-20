enum AppTheme {
  light,
  dark,
  system;

  /// Convert enum → String (for storage)
  String get value => name;

  /// Convert String → enum (safe)
  static AppTheme fromString(String? value) {
    switch (value) {
      case 'light':
        return AppTheme.light;
      case 'dark':
        return AppTheme.dark;
      case 'system':
      default:
        return AppTheme.system;
    }
  }
}
