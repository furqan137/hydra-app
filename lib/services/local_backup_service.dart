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
      p.join(tempDir.path, 'hidra_backup_${DateTime.now().millisecondsSinceEpoch}'),
    )..createSync(recursive: true);

    await FileHelper.ensureStructure();

    _copyDirectory(await FileHelper.vaultDir, Directory('${backupRoot.path}/Vault'));
    _copyDirectory(await FileHelper.albumsDir, Directory('${backupRoot.path}/Albums'));

    final metadataDir = Directory('${backupRoot.path}/metadata')..createSync();

    // Vault metadata
    final vaultFiles = await VaultRepository.getAllVaultFiles();
    File('${metadataDir.path}/vault_index.json')
        .writeAsStringSync(jsonEncode(vaultFiles.map((e) => e.toJson()).toList()));

    // Albums
    final albums = await AlbumRepository.getAllAlbums();
    File('${metadataDir.path}/albums.json')
        .writeAsStringSync(jsonEncode(albums.map((e) => e.toJson()).toList()));

    // Album media
    final albumMediaMap = await AlbumRepository.getAllAlbumMediaMap();
    for (final e in albumMediaMap.entries) {
      File('${metadataDir.path}/album_media_${e.key}.json')
          .writeAsStringSync(jsonEncode(e.value.map((f) => f.toJson()).toList()));
    }

    final zipFile = File('${backupRoot.path}.zip');
    await ZipService.createZip(sourceDirs: [backupRoot], outputFile: zipFile);

    final encrypted = await _encryptZip(zipFile, password);
    zipFile.deleteSync();

    final result = await encrypted.copy(
      p.join(selectedDir, '${p.basename(backupRoot.path)}.hidra'),
    );

    encrypted.deleteSync();
    backupRoot.deleteSync(recursive: true);

    return result;
  }

  // ================= RESTORE BACKUP (MERGE SAFE) =================

  static Future<void> restoreBackup({
    required File backupFile,
    required String password,
  }) async {
    final zipFile = await _decryptBackup(backupFile, password);

    final tempDir = await getTemporaryDirectory();
    final extractDir = Directory(
      '${tempDir.path}/restore_${DateTime.now().millisecondsSinceEpoch}',
    )..createSync(recursive: true);

    await ZipService.extractZip(zipFile: zipFile, targetDir: extractDir);
    zipFile.deleteSync();

    final backupRoot = extractDir
        .listSync()
        .whereType<Directory>()
        .first;

    await FileHelper.ensureStructure();

    // 🔹 MERGE FILES (NO DELETE)
    _mergeDirectory(
      Directory('${backupRoot.path}/Vault'),
      await FileHelper.vaultDir,
    );

    _mergeDirectory(
      Directory('${backupRoot.path}/Albums'),
      await FileHelper.albumsDir,
    );

    // 🔹 MERGE METADATA
    await _mergeMetadata(Directory('${backupRoot.path}/metadata'));

    extractDir.deleteSync(recursive: true);
  }

  // ================= METADATA MERGE =================

  static Future<void> _mergeMetadata(Directory metadataDir) async {
    if (!metadataDir.existsSync()) return;

    final prefs = await SharedPreferences.getInstance();

    // Vault
    final vaultFile = File('${metadataDir.path}/vault_index.json');
    if (vaultFile.existsSync()) {
      final old = prefs.getString('vault_files');
      final restored = jsonDecode(vaultFile.readAsStringSync()) as List;

      final merged = <Map<String, dynamic>>[];

      if (old != null) {
        merged.addAll(List<Map<String, dynamic>>.from(jsonDecode(old)));
      }

      for (final e in restored) {
        if (!merged.any((m) => m['file'] == e['file'])) {
          merged.add(Map<String, dynamic>.from(e));
        }
      }

      await prefs.setString('vault_files', jsonEncode(merged));
    }

    // Albums
    final albumsFile = File('${metadataDir.path}/albums.json');
    if (albumsFile.existsSync()) {
      final old = prefs.getString('albums');
      final restored = jsonDecode(albumsFile.readAsStringSync()) as List;

      final merged = <Map<String, dynamic>>[];

      if (old != null) {
        merged.addAll(List<Map<String, dynamic>>.from(jsonDecode(old)));
      }

      for (final e in restored) {
        if (!merged.any((m) => m['id'] == e['id'])) {
          merged.add(Map<String, dynamic>.from(e));
        }
      }

      await prefs.setString('albums', jsonEncode(merged));
    }

    // Album media
    for (final file in metadataDir.listSync().whereType<File>()) {
      if (!file.path.contains('album_media_')) continue;

      final key = p.basename(file.path).replaceAll('.json', '');
      final restored = jsonDecode(file.readAsStringSync()) as List;

      final old = prefs.getString(key);
      final merged = <Map<String, dynamic>>[];

      if (old != null) {
        merged.addAll(List<Map<String, dynamic>>.from(jsonDecode(old)));
      }

      for (final e in restored) {
        if (!merged.any((m) => m['file'] == e['file'])) {
          merged.add(Map<String, dynamic>.from(e));
        }
      }

      await prefs.setString(key, jsonEncode(merged));
    }
  }

  // ================= DIRECTORY MERGE =================

  static void _mergeDirectory(Directory source, Directory target) {
    if (!source.existsSync()) return;
    target.createSync(recursive: true);

    for (final entity in source.listSync()) {
      final newPath = '${target.path}/${p.basename(entity.path)}';

      if (entity is File) {
        if (!File(newPath).existsSync()) {
          entity.copySync(newPath);
        }
      } else if (entity is Directory) {
        _mergeDirectory(entity, Directory(newPath));
      }
    }
  }

  // ================= DIRECTORY COPY (FULL COPY) =================
  static void _copyDirectory(Directory source, Directory target) {
    if (!source.existsSync()) return;

    target.createSync(recursive: true);

    for (final entity in source.listSync()) {
      final newPath = p.join(target.path, p.basename(entity.path));

      if (entity is File) {
        entity.copySync(newPath);
      } else if (entity is Directory) {
        _copyDirectory(entity, Directory(newPath));
      }
    }
  }


  // ================= ENCRYPT / DECRYPT =================

  static Future<File> _encryptZip(File zipFile, String password) async {
    final data = [...utf8.encode(_magic), ...await zipFile.readAsBytes()];
    final key = sha256.convert(utf8.encode(password)).bytes;

    final encrypted = List<int>.generate(
      data.length,
          (i) => data[i] ^ key[i % key.length],
    );

    final out = File('${zipFile.path}.hidra');
    await out.writeAsBytes(encrypted, flush: true);
    return out;
  }

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

    final zip = File('${tempDir.path}/restore_${DateTime.now().millisecondsSinceEpoch}.zip');
    await zip.writeAsBytes(zipBytes, flush: true);
    return zip;
  }
}
