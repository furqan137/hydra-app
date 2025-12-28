import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/vault_file.dart';
import '../../core/utils/file_helper.dart';
import '../../services/file_delete_service.dart';
import '../../services/file_export_service.dart';
import '../../services/file_move_service.dart';

enum VaultSortType {
  nameAsc,
  nameDesc,
  dateNewest,
  dateOldest,
  sizeAsc,
  sizeDesc,
  reset,
}

class VaultController extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  static const String _dbKey = 'vault_files';

  final List<VaultFile> _files = [];
  final Set<VaultFile> _selected = {};

  bool _isImporting = false;

  // ================= GETTERS =================

  List<VaultFile> get files => List.unmodifiable(_files);
  List<VaultFile> get selectedFiles => List.unmodifiable(_selected);

  bool get isEmpty => _files.isEmpty;
  bool get isImporting => _isImporting;
  bool get isSelectionMode => _selected.isNotEmpty;

  int get selectedCount => _selected.length;
  int get totalFiles => _files.length;

  // ================= INIT =================

  VaultController() {
    loadFiles();
  }

  // ================= IMPORT =================

  Future<void> importFromGallery({bool deleteOriginals = false}) async {
    if (_isImporting) return;

    try {
      _isImporting = true;
      notifyListeners();

      final picked = await _picker.pickMultipleMedia();
      if (picked.isEmpty) return;

      await FileHelper.ensureStructure();
      final vaultDir = await FileHelper.vaultDir;

      for (final x in picked) {
        final src = File(x.path);
        if (!src.existsSync()) continue;

        final fileName = src.path.split('/').last;
        final dest = File('${vaultDir.path}/$fileName');

        if (dest.existsSync()) continue;

        await src.copy(dest.path);

        _files.add(
          VaultFile(
            file: dest,
            type: x.mimeType?.startsWith('video') ?? false
                ? VaultFileType.video
                : VaultFileType.image,
            importedAt: DateTime.now(),
          ),
        );

        if (deleteOriginals) {
          try {
            await src.delete();
          } catch (_) {}
        }
      }

      await saveFiles();
    } catch (e) {
      debugPrint('❌ Vault import error: $e');
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  // ================= SORT =================

  void sortFiles(VaultSortType type) {
    switch (type) {
      case VaultSortType.nameAsc:
        _files.sort((a, b) => a.file.path.compareTo(b.file.path));
        break;
      case VaultSortType.nameDesc:
        _files.sort((a, b) => b.file.path.compareTo(a.file.path));
        break;
      case VaultSortType.dateNewest:
        _files.sort((a, b) => b.importedAt.compareTo(a.importedAt));
        break;
      case VaultSortType.dateOldest:
        _files.sort((a, b) => a.importedAt.compareTo(b.importedAt));
        break;
      case VaultSortType.sizeAsc:
        _files.sort(
              (a, b) => a.file.lengthSync().compareTo(b.file.lengthSync()),
        );
        break;
      case VaultSortType.sizeDesc:
        _files.sort(
              (a, b) => b.file.lengthSync().compareTo(a.file.lengthSync()),
        );
        break;
      case VaultSortType.reset:
        _files.sort((a, b) => a.importedAt.compareTo(b.importedAt));
        break;
    }
    notifyListeners();
  }

  // ================= SELECTION =================

  bool isSelected(VaultFile file) => _selected.contains(file);

  void toggleSelection(VaultFile file) {
    _selected.contains(file) ? _selected.remove(file) : _selected.add(file);
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

    await FileDeleteService.deleteVaultFiles(_selected.toList());

    _files.removeWhere(_selected.contains);
    _selected.clear();

    await saveFiles();
    notifyListeners();
  }

  Future<void> deleteFile(VaultFile file) async {
    try {
      if (file.file.existsSync()) {
        await file.file.delete();
      }
    } catch (_) {}

    _files.removeWhere((f) => f.file.path == file.file.path);
    _selected.remove(file);

    await saveFiles();
    notifyListeners();
  }

  // ================= EXPORT / MOVE =================

  Future<void> exportSelected(Directory targetDir) async {
    if (_selected.isEmpty) return;

    await FileExportService.exportVaultFiles(
      _selected.toList(),
      targetDir: targetDir,
    );

    clearSelection();
  }

  Future<void> moveSelectedToAlbum(String albumId) async {
    if (_selected.isEmpty) return;

    await FileMoveService.moveVaultFilesToAlbum(
      files: _selected.toList(),
      albumId: albumId,
    );

    _files.removeWhere(_selected.contains);
    _selected.clear();

    await saveFiles();
    notifyListeners();
  }

  // ================= STORAGE =================

  Future<void> saveFiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _dbKey,
      jsonEncode(_files.map((f) => f.toJson()).toList()),
    );
  }

  /// 🔥 IMPORTANT: rebuild vault from disk (used after restore)
  Future<void> loadFiles() async {
    _files.clear();

    await FileHelper.ensureStructure();
    final vaultDir = await FileHelper.vaultDir;

    if (!vaultDir.existsSync()) {
      notifyListeners();
      return;
    }

    for (final entity in vaultDir.listSync()) {
      if (entity is! File) continue;

      final ext = entity.path.toLowerCase();
      final type = ext.endsWith('.mp4') ||
          ext.endsWith('.mkv') ||
          ext.endsWith('.avi')
          ? VaultFileType.video
          : VaultFileType.image;

      _files.add(
        VaultFile(
          file: entity,
          type: type,
          importedAt: entity.lastModifiedSync(),
        ),
      );
    }

    await saveFiles();
    notifyListeners();
  }

  /// ✅ CALL THIS AFTER BACKUP RESTORE
  Future<void> reloadAfterRestore() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_dbKey);
    await loadFiles();
  }
}
