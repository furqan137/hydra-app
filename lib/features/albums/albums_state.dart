import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/album_model.dart';
import 'albums_controller.dart';

class AlbumsState extends ChangeNotifier {
  static const String _albumsKey = 'albums';
  static const String _viewTypeKey = 'albums_view_type';

  List<Album> _albums = [];
  AlbumViewType _viewType = AlbumViewType.list;

  List<Album> get albums => List.unmodifiable(_albums);
  AlbumViewType get viewType => _viewType;

  bool _initialized = false;

  AlbumsState() {
    _init();
  }

  // ================= INIT =================

  Future<void> _init() async {
    await _loadAlbums();
    await _loadViewType();
    _initialized = true;
    notifyListeners();
  }

  // ================= LOAD / SAVE =================

  Future<void> _loadAlbums() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_albumsKey);

    if (raw == null || raw.isEmpty) {
      _albums = [];
      return;
    }

    try {
      final List decoded = jsonDecode(raw);
      _albums = decoded.map((e) => Album.fromJson(e)).toList();
    } catch (e) {
      debugPrint('❌ Albums decode error: $e');
      _albums = [];
    }
  }

  Future<void> _saveAlbums() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _albumsKey,
      jsonEncode(_albums.map((e) => e.toJson()).toList()),
    );
  }

  // ================= RESTORE SUPPORT (🔥 FIXED) =================

  /// 🔥 MUST be called after backup restore
  Future<void> reloadFromStorage() async {
    debugPrint('🔄 Albums reloadFromStorage');

    // 1️⃣ Clear memory first (forces UI rebuild)
    _albums = [];
    notifyListeners();

    // 2️⃣ Reload from SharedPreferences
    await _loadAlbums();

    // 3️⃣ Notify again (final repaint)
    notifyListeners();
  }

  // ================= VIEW MODE =================

  Future<void> _loadViewType() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_viewTypeKey);

    if (stored == null) return;

    _viewType = AlbumViewType.values.firstWhere(
          (e) => e.name == stored,
      orElse: () => AlbumViewType.list,
    );
  }

  Future<void> _saveViewType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_viewTypeKey, _viewType.name);
  }

  // ================= ALBUM ACTIONS =================

  void setAlbums(List<Album> albums) {
    _albums = albums;
    _saveAlbums();
    notifyListeners();
  }

  void addAlbum(Album album) {
    _albums.add(album);
    _saveAlbums();
    notifyListeners();
  }

  void updateAlbum(Album updated) {
    final index = _albums.indexWhere((a) => a.id == updated.id);
    if (index == -1) return;

    _albums[index] = updated;
    _saveAlbums();
    notifyListeners();
  }

  void removeAlbum(String albumId) {
    _albums.removeWhere((a) => a.id == albumId);
    _saveAlbums();
    notifyListeners();
  }

  void setViewType(AlbumViewType type) {
    if (_viewType == type) return;
    _viewType = type;
    _saveViewType();
    notifyListeners();
  }

  // ================= HELPERS =================

  Album? getAlbumById(String id) {
    try {
      return _albums.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  bool get isReady => _initialized;
}

