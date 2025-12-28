import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'backup_builder.dart';

class LocalBackupService {
  static Future<File> createLocalBackup() async {
    final zip = await BackupBuilder.buildBackupZip();

    final dir = await getExternalStorageDirectory();
    if (dir == null) {
      throw Exception('Storage not available');
    }

    final target = File(
      '${dir.path}/hidra_backup_${DateTime.now().millisecondsSinceEpoch}.zip',
    );

    return zip.copy(target.path);
  }
}
