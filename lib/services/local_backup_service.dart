import 'dart:io';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/repositories/vault_repository.dart';
import '../data/repositories/album_repository.dart';
import '../core/utils/file_helper.dart';
import 'zip_service.dart';

class LocalBackupService {
  static const String _magic = 'HIDRA_BACKUP_v1::';

  // ================= CREATE BACKUP =================

  static Future<File> createBackup({
    required String password,
  }) async {
    final selectedDir = await FilePicker.platform.getDirectoryPath();
    if (selectedDir == null) {
      throw Exception('Folder selection cancelled');
    }

    final tempDir = await getTemporaryDirectory();
    final backupRoot = Directory(
      p.join(
        tempDir.path,
        'hidra_backup_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
    backupRoot.createSync(recursive: true);

    await FileHelper.ensureStructure();
    final vaultDir = await FileHelper.vaultDir;
    final albumsDir = await FileHelper.albumsDir;

    _copyDirectory(vaultDir, Directory(p.join(backupRoot.path, 'Vault')));
    _copyDirectory(albumsDir, Directory(p.join(backupRoot.path, 'Albums')));

    // ================= METADATA =================

    final metadataDir = Directory(p.join(backupRoot.path, 'metadata'));
    metadataDir.createSync();

    // Vault metadata (USED for restore)
    final vaultFiles = await VaultRepository.getAllVaultFiles();
    File(p.join(metadataDir.path, 'vault_index.json')).writeAsStringSync(
      jsonEncode(vaultFiles.map((e) => e.toJson()).toList()),
    );

    // Albums list
    final albums = await AlbumRepository.getAllAlbums();
    File(p.join(metadataDir.path, 'albums.json')).writeAsStringSync(
      jsonEncode(albums.map((e) => e.toJson()).toList()),
    );

    // Album media
    final albumMediaMap = await AlbumRepository.getAllAlbumMediaMap();
    for (final entry in albumMediaMap.entries) {
      File(
        p.join(metadataDir.path, 'album_media_${entry.key}.json'),
      ).writeAsStringSync(
        jsonEncode(entry.value.map((e) => e.toJson()).toList()),
      );
    }

    // ================= ZIP =================

    final zipFile = File('${backupRoot.path}.zip');
    await ZipService.createZip(
      sourceDirs: [backupRoot],
      outputFile: zipFile,
    );

    // ================= ENCRYPT =================

    final encrypted = await _encryptZip(zipFile, password);
    zipFile.deleteSync();

    final finalPath = p.join(
      selectedDir,
      '${p.basename(backupRoot.path)}.hidra',
    );

    final result = await encrypted.copy(finalPath);

    encrypted.deleteSync();
    backupRoot.deleteSync(recursive: true);

    return result;
  }

  // ================= RESTORE BACKUP =================

  static Future<void> restoreBackup({
    required File backupFile,
    required String password,
  }) async {
    // 1️⃣ DECRYPT (DO NOT TOUCH)
    final zipFile = await _decryptBackup(backupFile, password);

    // 2️⃣ EXTRACT
    final tempDir = await getTemporaryDirectory();
    final extractDir = Directory(
      p.join(
        tempDir.path,
        'restore_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
    extractDir.createSync(recursive: true);

    await ZipService.extractZip(
      zipFile: zipFile,
      targetDir: extractDir,
    );
    zipFile.deleteSync();

    // 3️⃣ RESTORE FILES
    await FileHelper.ensureStructure();

    _copyDirectory(
      Directory(p.join(extractDir.path, 'Vault')),
      await FileHelper.vaultDir,
      overwrite: true,
    );

    _copyDirectory(
      Directory(p.join(extractDir.path, 'Albums')),
      await FileHelper.albumsDir,
      overwrite: true,
    );

    // 4️⃣ RESTORE METADATA (🔥 FIXED)
    final metadataDir = Directory(p.join(extractDir.path, 'metadata'));
    if (metadataDir.existsSync()) {
      final prefs = await SharedPreferences.getInstance();

      for (final file in metadataDir.listSync().whereType<File>()) {
        final name = p.basename(file.path);
        final json = file.readAsStringSync();

        if (name == 'vault_index.json') {
          // 🔥 THIS FIXES VAULT RESTORE
          await prefs.setString('vault_files', json);
        } else if (name == 'albums.json') {
          await prefs.setString('albums', json);
        } else if (name.startsWith('album_media_')) {
          final key = name.replaceAll('.json', '');
          await prefs.setString(key, json);
        }
      }
    }

    extractDir.deleteSync(recursive: true);
  }

  // ================= HELPERS =================

  static void _copyDirectory(
      Directory source,
      Directory target, {
        bool overwrite = false,
      }) {
    if (!source.existsSync()) return;

    if (overwrite && target.existsSync()) {
      target.deleteSync(recursive: true);
    }

    target.createSync(recursive: true);

    for (final entity in source.listSync()) {
      if (entity is File) {
        entity.copySync(p.join(target.path, p.basename(entity.path)));
      } else if (entity is Directory) {
        _copyDirectory(
          entity,
          Directory(p.join(target.path, p.basename(entity.path))),
        );
      }
    }
  }

  // ================= ENCRYPT =================

  static Future<File> _encryptZip(File zipFile, String password) async {
    final zipBytes = await zipFile.readAsBytes();
    final key = sha256.convert(utf8.encode(password)).bytes;

    final data = [...utf8.encode(_magic), ...zipBytes];

    final encrypted = List<int>.generate(
      data.length,
          (i) => data[i] ^ key[i % key.length],
    );

    final outFile = File('${zipFile.path}.hidra');
    await outFile.writeAsBytes(encrypted, flush: true);
    return outFile;
  }

  // ================= DECRYPT =================

  static Future<File> _decryptBackup(File encrypted, String password) async {
    final bytes = await encrypted.readAsBytes();
    final key = sha256.convert(utf8.encode(password)).bytes;

    final decrypted = List<int>.generate(
      bytes.length,
          (i) => bytes[i] ^ key[i % key.length],
    );

    final magic = utf8.encode(_magic);
    for (int i = 0; i < magic.length; i++) {
      if (decrypted[i] != magic[i]) {
        throw Exception('Invalid password');
      }
    }

    final zipBytes = decrypted.sublist(magic.length);
    final tempDir = await getTemporaryDirectory();

    final zipFile = File(
      p.join(
        tempDir.path,
        'restore_${DateTime.now().millisecondsSinceEpoch}.zip',
      ),
    );

    await zipFile.writeAsBytes(zipBytes, flush: true);
    return zipFile;
  }
}
