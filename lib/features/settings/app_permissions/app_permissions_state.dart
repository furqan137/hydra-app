import 'package:flutter/foundation.dart';

@immutable
class AppPermissionsState {
  final bool storageGranted;
  final bool cameraGranted;
  final bool microphoneGranted;
  final bool notificationsGranted;

  final bool storagePermanentlyDenied;
  final bool cameraPermanentlyDenied;
  final bool microphonePermanentlyDenied;
  final bool notificationsPermanentlyDenied;

  const AppPermissionsState({
    this.storageGranted = false,
    this.cameraGranted = false,
    this.microphoneGranted = false,
    this.notificationsGranted = false,
    this.storagePermanentlyDenied = false,
    this.cameraPermanentlyDenied = false,
    this.microphonePermanentlyDenied = false,
    this.notificationsPermanentlyDenied = false,
  });

  AppPermissionsState copyWith({
    bool? storageGranted,
    bool? cameraGranted,
    bool? microphoneGranted,
    bool? notificationsGranted,
    bool? storagePermanentlyDenied,
    bool? cameraPermanentlyDenied,
    bool? microphonePermanentlyDenied,
    bool? notificationsPermanentlyDenied,
  }) {
    return AppPermissionsState(
      storageGranted: storageGranted ?? this.storageGranted,
      cameraGranted: cameraGranted ?? this.cameraGranted,
      microphoneGranted: microphoneGranted ?? this.microphoneGranted,
      notificationsGranted:
      notificationsGranted ?? this.notificationsGranted,
      storagePermanentlyDenied:
      storagePermanentlyDenied ?? this.storagePermanentlyDenied,
      cameraPermanentlyDenied:
      cameraPermanentlyDenied ?? this.cameraPermanentlyDenied,
      microphonePermanentlyDenied:
      microphonePermanentlyDenied ?? this.microphonePermanentlyDenied,
      notificationsPermanentlyDenied:
      notificationsPermanentlyDenied ??
          this.notificationsPermanentlyDenied,
    );
  }
}
