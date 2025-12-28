import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'zip_service.dart';

class LocalBackupService {
  static const String _magic = 'HIDRA_BACKUP_v1::';

  // ================= CREATE BACKUP =================
  static Future<File> createBackup({
    required String password,
  }) async {
    // 1️⃣ User selects destination folder
    final selectedDir = await FilePicker.platform.getDirectoryPath();
    if (selectedDir == null) {
      throw Exception('Folder selection cancelled');
    }

    // 2️⃣ Temp directory
    final tempDir = await getTemporaryDirectory();
    final baseName = 'hidra_backup_${DateTime.now().millisecondsSinceEpoch}';

    final zipFile = File(p.join(tempDir.path, '$baseName.zip'));

    // 3️⃣ REAL app data directories
    final appDir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory(p.join(appDir.path, 'Vault'));
    final albumsDir = Directory(p.join(appDir.path, 'Albums'));

    // 4️⃣ Create ZIP
    await ZipService.createZip(
      sourceDirs: [vaultDir, albumsDir],
      outputFile: zipFile,
    );

    // 5️⃣ Encrypt ZIP → .hidra
    final hidraFile = await _encryptZip(zipFile, password, baseName);
    zipFile.deleteSync();

    // 6️⃣ Move to selected folder
    final finalPath = p.join(selectedDir, '$baseName.hidra');
    final finalBackup = await hidraFile.copy(finalPath);
    hidraFile.deleteSync();

    return finalBackup;
  }

  // ================= RESTORE BACKUP =================
  static Future<void> restoreBackup({
    required File backupFile,
    required String password,
  }) async {
    // 1️⃣ Decrypt backup
    final zipFile = await _decryptBackup(backupFile, password);

    // 2️⃣ Restore into app directory
    final appDir = await getApplicationDocumentsDirectory();

    await ZipService.extractZip(
      zipFile: zipFile,
      targetDir: appDir,
    );

    zipFile.deleteSync();
  }

  // ================= ENCRYPT =================

  static Future<File> _encryptZip(
      File zipFile,
      String password,
      String baseName,
      ) async {
    final zipBytes = await zipFile.readAsBytes();
    final key = sha256.convert(utf8.encode(password)).bytes;

    final header = utf8.encode(_magic);
    final data = [...header, ...zipBytes];

    final encrypted = List<int>.generate(
      data.length,
          (i) => data[i] ^ key[i % key.length],
    );

    final outFile = File(p.join(zipFile.parent.path, '$baseName.hidra'));
    await outFile.writeAsBytes(encrypted, flush: true);
    return outFile;
  }

  // ================= DECRYPT =================

  static Future<File> _decryptBackup(
      File encryptedFile,
      String password,
      ) async {
    final bytes = await encryptedFile.readAsBytes();
    final key = sha256.convert(utf8.encode(password)).bytes;

    final decrypted = List<int>.generate(
      bytes.length,
          (i) => bytes[i] ^ key[i % key.length],
    );

    final magicBytes = utf8.encode(_magic);

    // 🔐 Password validation
    for (int i = 0; i < magicBytes.length; i++) {
      if (decrypted[i] != magicBytes[i]) {
        throw Exception('Invalid password');
      }
    }

    final zipBytes = decrypted.sublist(magicBytes.length);

    final tempDir = await getTemporaryDirectory();
    final zipFile = File(
      p.join(tempDir.path, 'restore_${DateTime.now().millisecondsSinceEpoch}.zip'),
    );

    await zipFile.writeAsBytes(zipBytes, flush: true);
    return zipFile;
  }
}
