import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

import 'app_permissions_state.dart';

class AppPermissionsController extends ChangeNotifier {
  AppPermissionsState _state = const AppPermissionsState();
  AppPermissionsState get state => _state;

  AppPermissionsController() {
    loadPermissions();
  }

  // ================= LOAD CURRENT STATUS =================

  Future<void> loadPermissions() async {
    final storage = await Permission.photos.status;
    final camera = await Permission.camera.status;
    final mic = await Permission.microphone.status;
    final notifications = await Permission.notification.status;

    _state = _state.copyWith(
      storageGranted: storage.isGranted,
      cameraGranted: camera.isGranted,
      microphoneGranted: mic.isGranted,
      notificationsGranted: notifications.isGranted,
    );
    notifyListeners();
  }

  // ================= REQUEST PERMISSIONS =================

  Future<void> requestStorage() async {
    final res = await Permission.photos.request();
    _update(storage: res.isGranted);
  }

  Future<void> requestCamera() async {
    final res = await Permission.camera.request();
    _update(camera: res.isGranted);
  }

  Future<void> requestMicrophone() async {
    final res = await Permission.microphone.request();
    _update(microphone: res.isGranted);
  }

  Future<void> requestNotifications() async {
    final res = await Permission.notification.request();
    _update(notifications: res.isGranted);
  }

  // ================= OPEN SYSTEM SETTINGS =================

  void openSystemSettings() {
    AppSettings.openAppSettings();
  }

  // ================= HELPER =================

  void _update({
    bool? storage,
    bool? camera,
    bool? microphone,
    bool? notifications,
  }) {
    _state = _state.copyWith(
      storageGranted: storage ?? _state.storageGranted,
      cameraGranted: camera ?? _state.cameraGranted,
      microphoneGranted: microphone ?? _state.microphoneGranted,
      notificationsGranted:
      notifications ?? _state.notificationsGranted,
    );
    notifyListeners();
  }
}
