import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/vault_file.dart';
import '../data/models/album_media_file.dart';
import '../data/models/album_model.dart';

class FileMoveService {
  // =====================================================
  // VAULT → ALBUM
  // =====================================================

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

    // Save album media
    await prefs.setString(
      albumKey,
      jsonEncode(albumFiles.map((e) => e.toJson()).toList()),
    );

    // Update album meta
    await _updateAlbumMeta(
      albumId: albumId,
      files: albumFiles,
      prefs: prefs,
    );
  }

  // =====================================================
  // ALBUM → ALBUM (NEW)
  // =====================================================

  static Future<void> moveAlbumMediaFilesToAlbum({
    required String sourceAlbumId,
    required String targetAlbumId,
    required List<AlbumMediaFile> files,
  }) async {
    if (sourceAlbumId == targetAlbumId) return;

    final prefs = await SharedPreferences.getInstance();

    final sourceKey = 'album_media_$sourceAlbumId';
    final targetKey = 'album_media_$targetAlbumId';

    // Load source album media
    final sourceRaw = prefs.getString(sourceKey);
    final List<AlbumMediaFile> sourceFiles = sourceRaw == null
        ? []
        : (jsonDecode(sourceRaw) as List)
        .map((e) => AlbumMediaFile.fromJson(e))
        .toList();

    // Load target album media
    final targetRaw = prefs.getString(targetKey);
    final List<AlbumMediaFile> targetFiles = targetRaw == null
        ? []
        : (jsonDecode(targetRaw) as List)
        .map((e) => AlbumMediaFile.fromJson(e))
        .toList();

    // Remove from source
    sourceFiles.removeWhere(
          (f) => files.any((m) => m.file.path == f.file.path),
    );

    // Add to target
    targetFiles.addAll(files);

    // Save both albums
    await prefs.setString(
      sourceKey,
      jsonEncode(sourceFiles.map((e) => e.toJson()).toList()),
    );

    await prefs.setString(
      targetKey,
      jsonEncode(targetFiles.map((e) => e.toJson()).toList()),
    );

    // Update album metadata
    await _updateAlbumMeta(
      albumId: sourceAlbumId,
      files: sourceFiles,
      prefs: prefs,
    );

    await _updateAlbumMeta(
      albumId: targetAlbumId,
      files: targetFiles,
      prefs: prefs,
    );
  }

  // =====================================================
  // ALBUM META UPDATE (PRIVATE)
  // =====================================================

  static Future<void> _updateAlbumMeta({
    required String albumId,
    required List<AlbumMediaFile> files,
    required SharedPreferences prefs,
  }) async {
    final albumsRaw = prefs.getString('albums');
    if (albumsRaw == null) return;

    final albums = (jsonDecode(albumsRaw) as List)
        .map((e) => Album.fromJson(e))
        .toList();

    final index = albums.indexWhere((a) => a.id == albumId);
    if (index == -1) return;

    albums[index] = albums[index].copyWith(
      fileCount: files.length,
      coverImage: files.isNotEmpty ? files.last.file.path : null,
    );

    await prefs.setString(
      'albums',
      jsonEncode(albums.map((e) => e.toJson()).toList()),
    );
  }
}
