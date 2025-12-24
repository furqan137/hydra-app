class AppPermissionsState {
  final bool storageGranted;
  final bool cameraGranted;
  final bool microphoneGranted;
  final bool notificationsGranted;

  const AppPermissionsState({
    this.storageGranted = false,
    this.cameraGranted = false,
    this.microphoneGranted = false,
    this.notificationsGranted = false,
  });

  AppPermissionsState copyWith({
    bool? storageGranted,
    bool? cameraGranted,
    bool? microphoneGranted,
    bool? notificationsGranted,
  }) {
    return AppPermissionsState(
      storageGranted: storageGranted ?? this.storageGranted,
      cameraGranted: cameraGranted ?? this.cameraGranted,
      microphoneGranted: microphoneGranted ?? this.microphoneGranted,
      notificationsGranted:
      notificationsGranted ?? this.notificationsGranted,
    );
  }
}
