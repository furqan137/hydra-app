enum StartPage {
  vault,
  albums,
}

enum AppTheme {
  system,
  light,
  dark,
}

class PreferencesState {
  /// Which page app opens on launch
  final StartPage startPage;

  /// App theme preference
  final AppTheme theme;

  /// Storage info (display only)
  final double storageUsed;   // in GB
  final double storageTotal;  // in GB

  const PreferencesState({
    this.startPage = StartPage.vault, // ✅ default
    this.theme = AppTheme.system,     // ✅ system theme (best practice)
    this.storageUsed = 0.0,           // ✅ safe default
    this.storageTotal = 0.0,          // ✅ safe default
  });

  PreferencesState copyWith({
    StartPage? startPage,
    AppTheme? theme,
    double? storageUsed,
    double? storageTotal,
  }) {
    return PreferencesState(
      startPage: startPage ?? this.startPage,
      theme: theme ?? this.theme,
      storageUsed: storageUsed ?? this.storageUsed,
      storageTotal: storageTotal ?? this.storageTotal,
    );
  }
}
