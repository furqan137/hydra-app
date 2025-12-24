enum StartPage { vault, albums }
enum AppTheme { system, light, dark }

class PreferencesState {
  final StartPage startPage;
  final AppTheme theme;
  final double storageUsed; // GB
  final double storageTotal; // GB

  const PreferencesState({
    this.startPage = StartPage.vault,
    this.theme = AppTheme.dark,
    this.storageUsed = 18.5,
    this.storageTotal = 128,
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
