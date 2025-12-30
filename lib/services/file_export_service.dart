import 'dart:io';

import '../data/models/vault_file.dart';
import '../data/models/album_media_file.dart';

class FileExportService {
  // ================= INTERNAL =================

  static Future<File?> _exportFile({
    required File source,
    required Directory targetDir,
  }) async {
    try {
      if (!await source.exists()) return null;

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final name = source.uri.pathSegments.last;
      final targetPath = '${targetDir.path}/$name';

      return await source.copy(targetPath);
    } catch (e) {
      print('[ExportService] Export failed: $e');
      return null;
    }
  }

  // ================= VAULT =================

  static Future<void> exportVaultFiles(
      List<VaultFile> files, {
        required Directory targetDir,
      }) async {
    for (final file in files) {
      await _exportFile(
        source: file.file,
        targetDir: targetDir,
      );
    }
  }

  // ================= ALBUM MEDIA =================

  static Future<void> exportAlbumMediaFiles(
      List<AlbumMediaFile> files, {
        required Directory targetDir,
      }) async {
    for (final media in files) {
      await _exportFile(
        source: media.file,
        targetDir: targetDir,
      );
    }
  }
}
