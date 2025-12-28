import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  /// ================= STORAGE PERMISSION =================
  ///
  /// Required for:
  /// - Local backup
  /// - Restore
  /// - Vault file access
  ///
  static Future<bool> requestStoragePermission(
      BuildContext context,
      ) async {
    if (!Platform.isAndroid) {
      // iOS / others → handled by sandbox
      return true;
    }

    // Android 11+ requires special permission
    if (await _isAndroid11OrAbove()) {
      return await _requestManageStorage(context);
    }

    // Android 10 and below
    return await _requestLegacyStorage(context);
  }

  // ================= ANDROID VERSION =================

  static Future<bool> _isAndroid11OrAbove() async {
    return Platform.isAndroid && (await Permission.manageExternalStorage.isGranted ||
        await Permission.manageExternalStorage.isDenied ||
        await Permission.manageExternalStorage.isRestricted);
  }

  // ================= ANDROID 11+ =================

  static Future<bool> _requestManageStorage(
      BuildContext context,
      ) async {
    final status = await Permission.manageExternalStorage.status;

    if (status.isGranted) {
      return true;
    }

    final result = await Permission.manageExternalStorage.request();

    if (result.isGranted) {
      return true;
    }

    _showPermissionDialog(
      context,
      title: 'Storage permission required',
      message:
      'Allow storage access to create and restore backups.',
    );

    return false;
  }

  // ================= ANDROID ≤10 =================

  static Future<bool> _requestLegacyStorage(
      BuildContext context,
      ) async {
    final status = await Permission.storage.status;

    if (status.isGranted) {
      return true;
    }

    final result = await Permission.storage.request();

    if (result.isGranted) {
      return true;
    }

    _showPermissionDialog(
      context,
      title: 'Storage permission required',
      message:
      'Storage permission is required to access your files.',
    );

    return false;
  }

  // ================= UI =================

  static void _showPermissionDialog(
      BuildContext context, {
        required String title,
        required String message,
      }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF101B2B),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
