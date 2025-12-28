import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_manifest.dart';

class BackupBuilder {
  static const String _vaultKey = 'vault_files';
  static const String _albumsKey = 'albums';

  /// Creates backup ZIP and returns file
  static Future<File> buildBackupZip() async {
    final tempDir = await getTemporaryDirectory();
    final backupDir = Directory(
      '${tempDir.path}/hidra_backup_${DateTime.now().millisecondsSinceEpoch}',
    );

    await backupDir.create(recursive: true);

    // ================= METADATA =================
    final prefs = await SharedPreferences.getInstance();
    final vaultRaw = prefs.getString(_vaultKey);
    final albumRaw = prefs.getString(_albumsKey);

    final manifest = BackupManifest(
      appName: 'Hidra',
      appVersion: '1.0.0',
      createdAt: DateTime.now(),
      vaultCount: vaultRaw == null ? 0 : jsonDecode(vaultRaw).length,
      albumCount: albumRaw == null ? 0 : jsonDecode(albumRaw).length,
    );

    await File('${backupDir.path}/manifest.json')
        .writeAsString(jsonEncode(manifest.toJson()));

    // ================= PREFS =================
    await File('${backupDir.path}/prefs.json').writeAsString(
      jsonEncode({
        'vault_files': vaultRaw,
        'albums': albumRaw,
      }),
    );

    // ================= FILES =================
    final vaultDir = Directory('${backupDir.path}/vault');
    await vaultDir.create();

    if (vaultRaw != null) {
      final List decoded = jsonDecode(vaultRaw);
      for (final item in decoded) {
        final path = item['file'];
        final file = File(path);
        if (file.existsSync()) {
          await file.copy('${vaultDir.path}/${file.uri.pathSegments.last}');
        }
      }
    }

    // ================= ZIP =================
    final zipPath = '${backupDir.path}.zip';
    final encoder = ZipFileEncoder();
    encoder.create(zipPath);
    encoder.addDirectory(backupDir);
    encoder.close();

    return File(zipPath);
  }
}
