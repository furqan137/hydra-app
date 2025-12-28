import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/vault_file.dart';
import '../data/models/album_media_file.dart';
import '../data/models/album_model.dart';

class FileMoveService {
  /// Move vault files into album (LOGICAL MOVE)
  static Future<void> moveVaultFilesToAlbum({
    required List<VaultFile> files,
    required String albumId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final albumKey = 'album_media_$albumId';
    final albumRaw = prefs.getString(albumKey);

    final List<AlbumMediaFile> albumFiles = albumRaw == null
        ? []
        : (jsonDecode(albumRaw) as List)
        .map((e) => AlbumMediaFile.fromJson(e))
        .toList();

    for (final vaultFile in files) {
      albumFiles.add(
        AlbumMediaFile(
          file: vaultFile.file,
          type: vaultFile.type == VaultFileType.video
              ? AlbumMediaType.video
              : AlbumMediaType.image,
          importedAt: DateTime.now(),
          thumbnailPath: vaultFile.thumbnailPath,
          isEncrypted: vaultFile.isEncrypted,
        ),
      );
    }

    /// SAVE ALBUM MEDIA
    await prefs.setString(
      albumKey,
      jsonEncode(albumFiles.map((e) => e.toJson()).toList()),
    );

    /// UPDATE ALBUM META (count + cover)
    final albumsRaw = prefs.getString('albums');
    if (albumsRaw != null) {
      final albums = (jsonDecode(albumsRaw) as List)
          .map((e) => Album.fromJson(e))
          .toList();

      final index = albums.indexWhere((a) => a.id == albumId);
      if (index != -1) {
        albums[index] = albums[index].copyWith(
          fileCount: albumFiles.length,
          coverImage: albumFiles.last.file.path,
        );

        await prefs.setString(
          'albums',
          jsonEncode(albums.map((e) => e.toJson()).toList()),
        );
      }
    }
  }
}
