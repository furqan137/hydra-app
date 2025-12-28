import 'dart:io';

import '../data/models/vault_file.dart';

class FileDeleteService {
  /// Delete single file
  static Future<void> _deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('[DeleteService] File delete failed: $e');
    }
  }

  /// Delete thumbnail
  static Future<void> _deleteThumbnail(String? path) async {
    if (path == null) return;

    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('[DeleteService] Thumbnail delete failed: $e');
    }
  }

  /// ✅ FIX: Delete multiple vault files
  static Future<void> deleteVaultFiles(List<VaultFile> files) async {
    for (final file in files) {
      await _deleteFile(file.file);
      await _deleteThumbnail(file.thumbnailPath);
    }
  }
}
