import 'dart:convert';
import 'dart:io';

import '../../data/models/vault_file.dart';

class VaultBackupHelper {
  /// File name inside backup
  static const String vaultIndexFileName = 'vault_index.json';

  /// ================= EXPORT VAULT METADATA =================
  ///
  /// [vaultFiles] → all VaultFile models from app
  /// [targetDir]  → directory where JSON will be written
  ///
  /// Returns created JSON file
  ///
  static Future<File> exportVaultIndex({
    required List<VaultFile> vaultFiles,
    required Directory targetDir,
  }) async {
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    final file = File(
      '${targetDir.path}/$vaultIndexFileName',
    );

    final jsonList = vaultFiles.map((v) => v.toJson()).toList();

    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);

    await file.writeAsString(jsonString, flush: true);

    return file;
  }

  /// ================= IMPORT VAULT METADATA =================
  ///
  /// Used during restore (later)
  ///
  static Future<List<VaultFile>> importVaultIndex(File jsonFile) async {
    if (!jsonFile.existsSync()) return [];

    final jsonStr = await jsonFile.readAsString();
    final List decoded = jsonDecode(jsonStr);

    return decoded
        .map((e) => VaultFile.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
