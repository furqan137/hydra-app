class SettingsState {
  final bool isLoading;

  const SettingsState({
    this.isLoading = false,
  });

  SettingsState copyWith({
    bool? isLoading,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
