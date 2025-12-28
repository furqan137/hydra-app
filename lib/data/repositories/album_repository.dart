import 'dart:io';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/album_model.dart';
import '../models/album_media_file.dart';
import '../../core/utils/file_helper.dart';

class AlbumRepository {
  /// ================= LOAD ALL ALBUMS =================
  ///
  /// Albums metadata stored in SharedPreferences
  ///
  static Future<List<Album>> getAllAlbums() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('albums');

    if (jsonStr == null) return [];

    final List decoded = jsonDecode(jsonStr);

    return decoded
        .map((e) => Album.fromJson(e))
        .toList();
  }

  /// ================= LOAD ALL ALBUM MEDIA =================
  ///
  /// Returns:
  /// {
  ///   albumId : List<AlbumMediaFile>
  /// }
  ///
  static Future<Map<String, List<AlbumMediaFile>>>
  getAllAlbumMediaMap() async {
    final prefs = await SharedPreferences.getInstance();

    final Map<String, List<AlbumMediaFile>> result = {};

    final keys = prefs.getKeys().where(
          (k) => k.startsWith('album_media_'),
    );

    for (final key in keys) {
      final albumId = key.replaceFirst('album_media_', '');
      final jsonStr = prefs.getString(key);

      if (jsonStr == null) continue;

      final List decoded = jsonDecode(jsonStr);

      final mediaList = decoded
          .map((e) => AlbumMediaFile.fromJson(e))
          .toList();

      result[albumId] = mediaList;
    }

    return result;
  }
}
