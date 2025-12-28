import 'dart:io';

import 'backup_builder.dart';

class DriveBackupService {
  /// Returns ZIP file to upload
  static Future<File> createDriveBackup() async {
    return BackupBuilder.buildBackupZip();
  }
}
