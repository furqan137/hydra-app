import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

import 'app_permissions_state.dart';

class AppPermissionsController extends ChangeNotifier
    with WidgetsBindingObserver {
  AppPermissionsState _state = const AppPermissionsState();
  AppPermissionsState get state => _state;

  AppPermissionsController() {
    WidgetsBinding.instance.addObserver(this);
    loadPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadPermissions();
    }
  }

  // ================= LOAD =================

  Future<void> loadPermissions() async {
    final storageStatus = await _storagePermission.status;
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;
    final notifStatus = await Permission.notification.status;

    _state = _state.copyWith(
      storageGranted: storageStatus.isGranted,
      cameraGranted: cameraStatus.isGranted,
      microphoneGranted: micStatus.isGranted,
      notificationsGranted: notifStatus.isGranted,
      storagePermanentlyDenied:
      storageStatus.isPermanentlyDenied ||
          storageStatus.isRestricted,
      cameraPermanentlyDenied:
      cameraStatus.isPermanentlyDenied ||
          cameraStatus.isRestricted,
      microphonePermanentlyDenied:
      micStatus.isPermanentlyDenied ||
          micStatus.isRestricted,
      notificationsPermanentlyDenied:
      notifStatus.isPermanentlyDenied ||
          notifStatus.isRestricted,
    );
    notifyListeners();
  }

  // ================= REQUESTS =================

  Future<void> requestStorage() async {
    await _handlePermission(_storagePermission,
        onGranted: (v) => _update(storage: v),
        onPermanent: (v) =>
            _update(storagePermanentlyDenied: v));
  }

  Future<void> requestCamera() async {
    await _handlePermission(Permission.camera,
        onGranted: (v) => _update(camera: v),
        onPermanent: (v) =>
            _update(cameraPermanentlyDenied: v));
  }

  Future<void> requestMicrophone() async {
    await _handlePermission(Permission.microphone,
        onGranted: (v) => _update(microphone: v),
        onPermanent: (v) =>
            _update(microphonePermanentlyDenied: v));
  }

  Future<void> requestNotifications() async {
    await _handlePermission(Permission.notification,
        onGranted: (v) => _update(notifications: v),
        onPermanent: (v) =>
            _update(notificationsPermanentlyDenied: v));
  }

  // ================= HELPERS =================

  Permission get _storagePermission {
    if (Platform.isIOS) return Permission.photos;
    return Permission.storage;
  }

  Future<void> _handlePermission(
      Permission permission, {
        required Function(bool) onGranted,
        required Function(bool) onPermanent,
      }) async {
    final status = await permission.request();

    if (status.isGranted) {
      onGranted(true);
      onPermanent(false);
    } else if (status.isPermanentlyDenied ||
        status.isRestricted) {
      onPermanent(true);
      openSystemSettings();
    } else {
      onGranted(false);
    }
  }

  void openSystemSettings() {
    AppSettings.openAppSettings();
  }

  void _update({
    bool? storage,
    bool? camera,
    bool? microphone,
    bool? notifications,
    bool? storagePermanentlyDenied,
    bool? cameraPermanentlyDenied,
    bool? microphonePermanentlyDenied,
    bool? notificationsPermanentlyDenied,
  }) {
    _state = _state.copyWith(
      storageGranted: storage,
      cameraGranted: camera,
      microphoneGranted: microphone,
      notificationsGranted: notifications,
      storagePermanentlyDenied: storagePermanentlyDenied,
      cameraPermanentlyDenied: cameraPermanentlyDenied,
      microphonePermanentlyDenied: microphonePermanentlyDenied,
      notificationsPermanentlyDenied:
      notificationsPermanentlyDenied,
    );
    notifyListeners();
  }
}
