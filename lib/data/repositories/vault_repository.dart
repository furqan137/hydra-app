import 'dart:io';

import '../models/vault_file.dart';
import '../../core/utils/file_helper.dart';

class VaultRepository {
  /// ================= LOAD ALL VAULT FILES =================
  ///
  /// Reads:
  /// /AppDir/Hidra/Vault/*
  ///
  static Future<List<VaultFile>> getAllVaultFiles() async {
    await FileHelper.ensureStructure();

    final vaultDir = await FileHelper.vaultDir;

    if (!vaultDir.existsSync()) {
      return [];
    }

    final files = vaultDir
        .listSync(recursive: false)
        .whereType<File>();

    final List<VaultFile> result = [];

    for (final file in files) {
      final ext = file.path.toLowerCase();

      final type = ext.endsWith('.mp4') ||
          ext.endsWith('.mkv') ||
          ext.endsWith('.avi')
          ? VaultFileType.video
          : VaultFileType.image;

      result.add(
        VaultFile(
          file: file,
          type: type,
          importedAt: file.lastModifiedSync(),
          thumbnailPath: null,
          isEncrypted: false,
        ),
      );
    }

    return result;
  }
}
