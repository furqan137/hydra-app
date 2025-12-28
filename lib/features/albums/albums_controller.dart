import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/album_model.dart';
import 'albums_state.dart';

/// ================= ENUMS =================

enum AlbumSortType {
  nameAsc,
  nameDesc,
  newest,
  oldest,
}

enum AlbumViewType {
  list,
  grid,
}

/// ================= CONTROLLER =================
/// Manages album metadata only (NOT album media)
class AlbumsController {
  final AlbumsState state;

  static const String _albumsKey = 'albums';

  AlbumsController(this.state) {
    loadAlbums();
  }

  // ================= LOAD / SAVE =================

  Future<void> loadAlbums() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_albumsKey);

    if (jsonStr == null) {
      state.setAlbums([]);
      return;
    }

    try {
      final List decoded = jsonDecode(jsonStr);
      final albums = decoded.map((e) => Album.fromJson(e)).toList();
      state.setAlbums(albums);
    } catch (e) {
      debugPrint('❌ Album load error: $e');
      state.setAlbums([]);
    }
  }

  Future<void> _saveAlbums() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _albumsKey,
      jsonEncode(state.albums.map((a) => a.toJson()).toList()),
    );
  }

  /// 🔥 CALL THIS AFTER BACKUP RESTORE
  Future<void> reloadAfterRestore() async {
    await loadAlbums();
  }

  // ================= CREATE =================

  void createAlbum(
      String name, {
        bool isPrivate = false,
      }) {
    final album = Album(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      isPrivate: isPrivate,
      fileCount: 0,
      coverImage: null,
    );

    state.addAlbum(album);
    _saveAlbums();
  }

  // ================= SEARCH =================

  List<Album> searchAlbums(String query) {
    if (query.trim().isEmpty) return state.albums;

    final q = query.toLowerCase();
    return state.albums
        .where((album) => album.name.toLowerCase().contains(q))
        .toList();
  }

  // ================= SORT =================

  void sortAlbums(AlbumSortType type) {
    final albums = [...state.albums];

    switch (type) {
      case AlbumSortType.nameAsc:
        albums.sort((a, b) => a.name.compareTo(b.name));
        break;
      case AlbumSortType.nameDesc:
        albums.sort((a, b) => b.name.compareTo(a.name));
        break;
      case AlbumSortType.newest:
        albums.sort((a, b) => b.id.compareTo(a.id));
        break;
      case AlbumSortType.oldest:
        albums.sort((a, b) => a.id.compareTo(b.id));
        break;
    }

    state.setAlbums(albums);
    _saveAlbums();
  }

  // ================= VIEW MODE =================

  void changeView(AlbumViewType type) {
    state.setViewType(type);
  }

  // ================= RENAME =================

  void renameAlbum(BuildContext context, Album album) {
    final controller = TextEditingController(text: album.name);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF101B2B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Rename Album', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Album name',
            hintStyle: TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Color(0xFF192841),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0FB9B1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;

              _replaceAlbum(album.copyWith(name: newName));
              _saveAlbums();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ================= DELETE =================

  void deleteAlbum(BuildContext context, Album album) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF101B2B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete Album', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${album.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final updated = [...state.albums]
                ..removeWhere((a) => a.id == album.id);
              state.setAlbums(updated);
              _saveAlbums();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ================= INTERNAL =================

  void _replaceAlbum(Album updated) {
    final list = state.albums.map((a) {
      return a.id == updated.id ? updated : a;
    }).toList();

    state.setAlbums(list);
  }
}
