import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/vault_file.dart';
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

  /// ✅ FIX: RESTORED (used by UI)
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

      for (final x in picked) {
        final file = File(x.path);
        if (!file.existsSync()) continue;

        // Prevent duplicates
        if (_files.any((f) => f.file.path == file.path)) continue;

        final isVideo = x.mimeType?.startsWith('video') ?? false;

        _files.add(
          VaultFile(
            file: file,
            type: isVideo ? VaultFileType.video : VaultFileType.image,
            importedAt: DateTime.now(),
          ),
        );

        if (deleteOriginals) {
          try {
            await file.delete();
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

  // ================= EXPORT =================

  Future<void> exportSelected(Directory targetDir) async {
    if (_selected.isEmpty) return;

    await FileExportService.exportVaultFiles(
      _selected.toList(),
      targetDir: targetDir,
    );

    clearSelection();
  }


  // ================= MOVE =================

  Future<void> moveSelectedToAlbum(String albumId) async {
    if (_selected.isEmpty) return;

    await FileMoveService.moveVaultFilesToAlbum(
      files: _selected.toList(),
      albumId: albumId,
    );

    /// REMOVE FROM VAULT
    _files.removeWhere(_selected.contains);
    _selected.clear();

    await saveFiles();
    notifyListeners();
  }



  // ================= SINGLE DELETE =================

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


  // ================= STORAGE =================

  Future<void> saveFiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _dbKey,
      jsonEncode(_files.map((f) => f.toJson()).toList()),
    );
  }

  Future<void> loadFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dbKey);

    if (raw == null) return;

    try {
      final List decoded = jsonDecode(raw);

      _files
        ..clear()
        ..addAll(
          decoded
              .map<VaultFile>((e) => VaultFile.fromJson(e))
              .where((v) => v.file.existsSync()),
        );

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Vault load error: $e');
    }
  }
}
