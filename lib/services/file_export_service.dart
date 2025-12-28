import 'dart:io';

import '../data/models/vault_file.dart';

class FileExportService {
  /// Export single file
  static Future<File?> _exportFile({
    required File source,
    required Directory targetDir,
  }) async {
    try {
      if (!await source.exists()) return null;

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final targetPath =
          '${targetDir.path}/${source.uri.pathSegments.last}';

      return await source.copy(targetPath);
    } catch (e) {
      print('[ExportService] Export failed: $e');
      return null;
    }
  }

  /// ✅ FIX: Export multiple vault files
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
}
