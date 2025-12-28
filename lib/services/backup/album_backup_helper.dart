import 'dart:convert';
import 'dart:io';

import '../../data/models/album_model.dart';
import '../../data/models/album_media_file.dart';

class AlbumBackupHelper {
  /// ================= FILE NAMES =================

  static const String albumsIndexFile = 'albums_index.json';

  static String albumMediaFileName(String albumId) =>
      'album_media_$albumId.json';

  /// ================= EXPORT ALBUMS METADATA =================
  ///
  /// Exports list of Album models
  ///
  static Future<File> exportAlbumsIndex({
    required List<Album> albums,
    required Directory targetDir,
  }) async {
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    final file = File('${targetDir.path}/$albumsIndexFile');

    final jsonList = albums.map((a) => a.toJson()).toList();

    final jsonString =
    const JsonEncoder.withIndent('  ').convert(jsonList);

    await file.writeAsString(jsonString, flush: true);

    return file;
  }

  /// ================= EXPORT ALBUM MEDIA =================
  ///
  /// One JSON file per album
  ///
  static Future<File> exportAlbumMedia({
    required String albumId,
    required List<AlbumMediaFile> mediaFiles,
    required Directory targetDir,
  }) async {
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    final file = File(
      '${targetDir.path}/${albumMediaFileName(albumId)}',
    );

    final jsonList = mediaFiles.map((m) => m.toJson()).toList();

    final jsonString =
    const JsonEncoder.withIndent('  ').convert(jsonList);

    await file.writeAsString(jsonString, flush: true);

    return file;
  }

  /// ================= IMPORT ALBUMS =================

  static Future<List<Album>> importAlbumsIndex(File jsonFile) async {
    if (!jsonFile.existsSync()) return [];

    final jsonStr = await jsonFile.readAsString();
    final List decoded = jsonDecode(jsonStr);

    return decoded
        .map((e) => Album.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// ================= IMPORT ALBUM MEDIA =================

  static Future<List<AlbumMediaFile>> importAlbumMedia(File jsonFile) async {
    if (!jsonFile.existsSync()) return [];

    final jsonStr = await jsonFile.readAsString();
    final List decoded = jsonDecode(jsonStr);

    return decoded
        .map(
          (e) => AlbumMediaFile.fromJson(
        Map<String, dynamic>.from(e),
      ),
    )
        .toList();
  }
}
