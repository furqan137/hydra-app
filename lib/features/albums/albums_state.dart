import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/album_model.dart';
import 'albums_controller.dart'; // AlbumViewType enum

class AlbumsState extends ChangeNotifier {
  // ================= DATA =================

  List<Album> _albums = [];
  AlbumViewType _viewType = AlbumViewType.list;

  List<Album> get albums => _albums;
  AlbumViewType get viewType => _viewType;

  // ================= INIT =================

  AlbumsState() {
    _init();
  }

  Future<void> _init() async {
    await _loadAlbums();
    await _loadViewType();
  }

  // ================= LOAD / SAVE =================

  Future<void> _loadAlbums() async {
    final prefs = await SharedPreferences.getInstance();
    final albumsJson = prefs.getString('albums');

    if (albumsJson == null) return;

    final List decoded = jsonDecode(albumsJson);
    _albums = decoded.map((e) => Album.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> _saveAlbums() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'albums',
      jsonEncode(_albums.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _loadViewType() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('albums_view_type');

    if (stored == null) return;

    _viewType = AlbumViewType.values.firstWhere(
          (e) => e.name == stored,
      orElse: () => AlbumViewType.list,
    );
    notifyListeners();
  }

  Future<void> _saveViewType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('albums_view_type', _viewType.name);
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

  void removeAlbum(String albumId) {
    _albums.removeWhere((a) => a.id == albumId);
    _saveAlbums();
    notifyListeners();
  }

  // ================= VIEW MODE =================

  void setViewType(AlbumViewType type) {
    if (_viewType == type) return;

    _viewType = type;
    _saveViewType();
    notifyListeners();
  }
}
