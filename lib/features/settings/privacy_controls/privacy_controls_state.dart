class PrivacyControlsState {
  final bool blockScreenshots;
  final bool clearCacheOnExit;
  final bool secureDelete;

  const PrivacyControlsState({
    this.blockScreenshots = true,
    this.clearCacheOnExit = true,
    this.secureDelete = true,
  });

  PrivacyControlsState copyWith({
    bool? blockScreenshots,
    bool? clearCacheOnExit,
    bool? secureDelete,
  }) {
    return PrivacyControlsState(
      blockScreenshots: blockScreenshots ?? this.blockScreenshots,
      clearCacheOnExit: clearCacheOnExit ?? this.clearCacheOnExit,
      secureDelete: secureDelete ?? this.secureDelete,
    );
  }
}
