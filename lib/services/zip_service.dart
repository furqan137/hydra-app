import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

class ZipService {
  /// ================= CREATE ZIP =================
  static Future<File> createZip({
    required List<Directory> sourceDirs,
    required File outputFile,
  }) async {
    final archive = Archive();

    for (final dir in sourceDirs) {
      if (!dir.existsSync()) continue;

      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File) continue;

        final relativePath =
        p.relative(entity.path, from: dir.path);

        final data = await entity.readAsBytes();

        archive.addFile(
          ArchiveFile(
            p.join(p.basename(dir.path), relativePath),
            data.length,
            data,
          ),
        );
      }
    }

    final zipData = ZipEncoder().encode(archive);
    if (zipData == null) {
      throw Exception('Failed to create ZIP');
    }

    await outputFile.writeAsBytes(zipData, flush: true);
    return outputFile;
  }

  /// ================= EXTRACT ZIP =================
  static Future<void> extractZip({
    required File zipFile,
    required Directory targetDir,
  }) async {
    if (!zipFile.existsSync()) {
      throw Exception('ZIP file not found');
    }

    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    final bytes = zipFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filePath = p.join(targetDir.path, file.name);

      if (file.isFile) {
        final outFile = File(filePath);
        outFile.createSync(recursive: true);
        outFile.writeAsBytesSync(file.content as List<int>);
      } else {
        Directory(filePath).createSync(recursive: true);
      }
    }
  }
}
