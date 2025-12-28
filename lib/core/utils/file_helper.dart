import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileHelper {
  // ================= BASE DIR (SAFE) =================

  static Future<Directory> get baseDir async {
    final dir = await getApplicationDocumentsDirectory();
    return Directory(p.join(dir.path, 'Hidra'));
  }

  static Future<Directory> get vaultDir async {
    final dir = await baseDir;
    return Directory(p.join(dir.path, 'Vault'));
  }

  static Future<Directory> get albumsDir async {
    final dir = await baseDir;
    return Directory(p.join(dir.path, 'Albums'));
  }

  // ================= ENSURE =================

  static Future<void> ensureStructure() async {
    final base = await baseDir;
    final vault = await vaultDir;
    final albums = await albumsDir;

    if (!base.existsSync()) base.createSync(recursive: true);
    if (!vault.existsSync()) vault.createSync(recursive: true);
    if (!albums.existsSync()) albums.createSync(recursive: true);
  }

  // ================= BACKUP NAME =================

  static String generateBackupName() {
    final now = DateTime.now();
    return 'hidra_backup_${now.year}${now.month}${now.day}_${now.millisecondsSinceEpoch}';
  }
}
