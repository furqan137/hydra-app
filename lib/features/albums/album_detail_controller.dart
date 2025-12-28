import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/album_model.dart';
import '../../data/models/vault_file.dart';

class AlbumDetailController extends ChangeNotifier {
  final Album album;

  AlbumDetailController(this.album);

  final List<VaultFile> _files = [];
  final Set<VaultFile> _selected = {};

  // ================= GETTERS =================

  List<VaultFile> get files => List.unmodifiable(_files);

  bool get isSelectionMode => _selected.isNotEmpty;
  int get selectedCount => _selected.length;

  List<VaultFile> get selectedFiles => List.unmodifiable(_selected);

  // ================= LOAD FILES =================

  Future<void> loadFiles() async {
    final albumDir =
    Directory('/storage/emulated/0/Hidra/Albums/${album.id}');

    if (!albumDir.existsSync()) {
      _files.clear();
      notifyListeners();
      return;
    }

    final items = albumDir.listSync().whereType<File>();

    _files
      ..clear()
      ..addAll(
        items.map(
              (f) => VaultFile(
            file: f,
            type: f.path.toLowerCase().endsWith('.mp4')
                ? VaultFileType.video
                : VaultFileType.image,
            importedAt: f.lastModifiedSync(),
          ),
        ),
      );

    notifyListeners();
  }

  // ================= SELECTION =================

  bool isSelected(VaultFile file) => _selected.contains(file);

  void toggleSelection(VaultFile file) {
    _selected.contains(file)
        ? _selected.remove(file)
        : _selected.add(file);
    notifyListeners();
  }

  void clearSelection() {
    _selected.clear();
    notifyListeners();
  }

  void selectAll() {
    _selected
      ..clear()
      ..addAll(_files);
    notifyListeners();
  }

  // ================= DELETE =================

  Future<void> deleteSelected() async {
    if (_selected.isEmpty) return;

    for (final file in _selected) {
      try {
        if (file.file.existsSync()) {
          await file.file.delete();
        }
      } catch (_) {}
    }

    _files.removeWhere(_selected.contains);
    clearSelection();
  }

  // ================= EXPORT =================

  Future<void> exportSelected(Directory targetDir) async {
    if (_selected.isEmpty) return;

    for (final file in _selected) {
      final target = File(
        '${targetDir.path}/${file.file.path.split('/').last}',
      );
      await file.file.copy(target.path);
    }

    clearSelection();
  }

  // ================= MOVE =================

  Future<void> moveSelectedToAlbum(String targetAlbumId) async {
    if (_selected.isEmpty) return;

    final albumDir =
    Directory('/storage/emulated/0/Hidra/Albums/$targetAlbumId');

    if (!albumDir.existsSync()) {
      await albumDir.create(recursive: true);
    }

    for (final file in _selected) {
      final newPath =
          '${albumDir.path}/${file.file.path.split('/').last}';

      // COPY first (safe)
      await file.file.copy(newPath);

      // DELETE original
      if (file.file.existsSync()) {
        await file.file.delete();
      }
    }

    _files.removeWhere(_selected.contains);
    clearSelection();
  }
}
