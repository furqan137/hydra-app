import 'dart:io';

import '../data/models/vault_file.dart';
import '../data/models/album_media_file.dart';

class FileDeleteService {
  // ================= INTERNAL =================

  static Future<void> _deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('[DeleteService] File delete failed: $e');
    }
  }

  static Future<void> _deleteThumbnail(String? path) async {
    if (path == null) return;

    try {
      final thumb = File(path);
      if (await thumb.exists()) {
        await thumb.delete();
      }
    } catch (e) {
      print('[DeleteService] Thumbnail delete failed: $e');
    }
  }

  // ================= VAULT =================

  /// Delete multiple vault files
  static Future<void> deleteVaultFiles(
      List<VaultFile> files,
      ) async {
    for (final file in files) {
      await _deleteFile(file.file);
      await _deleteThumbnail(file.thumbnailPath);
    }
  }

  // ================= ALBUM MEDIA =================

  /// Delete multiple album media files
  static Future<void> deleteAlbumMediaFiles(
      List<AlbumMediaFile> files,
      ) async {
    for (final media in files) {
      await _deleteFile(media.file);
      await _deleteThumbnail(media.thumbnailPath);
    }
  }
}
