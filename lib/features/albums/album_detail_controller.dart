import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../data/models/album_model.dart';
import '../../data/models/album_media_file.dart';
import '../../core/utils/file_helper.dart';
import '../../services/file_delete_service.dart';
import '../../services/file_export_service.dart';
import '../../services/file_move_service.dart';

class AlbumDetailController extends ChangeNotifier {
  final Album album;

  AlbumDetailController(this.album) {
    loadFiles();
  }

  // ================= DATA =================

  final List<AlbumMediaFile> _files = [];
  final Set<AlbumMediaFile> _selected = {};

  // ================= GETTERS =================

  List<AlbumMediaFile> get files => List.unmodifiable(_files);
  List<AlbumMediaFile> get selectedFiles => List.unmodifiable(_selected);

  bool get isSelectionMode => _selected.isNotEmpty;
  int get selectedCount => _selected.length;

  // ================= LOAD FILES =================

  Future<void> loadFiles() async {
    _files.clear();

    await FileHelper.ensureStructure();
    final root = await getExternalStorageDirectory();

    final albumDir = Directory(
      '${root!.path}/Hidra/Albums/${album.id}',
    );

    if (!albumDir.existsSync()) {
      notifyListeners();
      return;
    }

    for (final entity in albumDir.listSync()) {
      if (entity is! File) continue;

      final path = entity.path.toLowerCase();
      final isVideo = path.endsWith('.mp4') ||
          path.endsWith('.mkv') ||
          path.endsWith('.avi');

      _files.add(
        AlbumMediaFile(
          file: entity,
          type: isVideo ? AlbumMediaType.video : AlbumMediaType.image,
          importedAt: entity.lastModifiedSync(),
          thumbnailPath: null,
          isEncrypted: false,
        ),
      );
    }

    notifyListeners();
  }

  // ================= SELECTION =================

  bool isSelected(AlbumMediaFile file) => _selected.contains(file);

  void toggleSelection(AlbumMediaFile file) {
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

    await FileDeleteService.deleteAlbumMediaFiles(
      _selected.toList(),
    );

    _files.removeWhere(_selected.contains);
    clearSelection();
    notifyListeners();
  }

  // ================= EXPORT =================

  /// Opens system file manager (Downloads etc.)
  Future<void> exportSelected(Directory targetDir) async {
    if (_selected.isEmpty) return;

    await FileExportService.exportAlbumMediaFiles(
      _selected.toList(),
      targetDir: targetDir,
    );

    clearSelection();
  }



  // ================= MOVE =================

  Future<void> moveSelectedToAlbum(String targetAlbumId) async {
    if (_selected.isEmpty) return;

    await FileMoveService.moveAlbumMediaFilesToAlbum(
      sourceAlbumId: album.id,
      targetAlbumId: targetAlbumId,
      files: _selected.toList(),
    );

    _files.removeWhere(_selected.contains);
    clearSelection();
    notifyListeners();
  }

  // ================= RESTORE SUPPORT =================

  /// Call this after backup restore
  Future<void> reloadAfterRestore() async {
    clearSelection();
    await loadFiles();
  }
}
