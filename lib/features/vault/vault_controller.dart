import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/vault_file.dart';

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

  final List<VaultFile> _files = [];
  final Set<VaultFile> _selectedFiles = {};

  bool _isImporting = false;

  static const _dbKey = 'vault_files';

  List<VaultFile> get files => List.unmodifiable(_files);
  List<VaultFile> get selectedFiles => List.unmodifiable(_selectedFiles);

  bool get isEmpty => _files.isEmpty;
  bool get isImporting => _isImporting;
  bool get isSelectionMode => _selectedFiles.isNotEmpty;

  int get selectedCount => _selectedFiles.length;
  int get totalFiles => _files.length;

  Future<void> importFromGallery({bool deleteOriginals = false}) async {
    if (_isImporting) return;

    try {
      _isImporting = true;
      notifyListeners();

      final List<XFile> picked = await _picker.pickMultipleMedia();
      if (picked.isEmpty) return;

      for (final x in picked) {
        final file = File(x.path);
        if (!file.existsSync()) continue;

        final isVideo = x.mimeType?.startsWith('video') ?? false;

        final vaultFile = VaultFile(
          file: file,
          importedAt: DateTime.now(),
          type: isVideo ? VaultFileType.video : VaultFileType.image,
        );

        if (_files.contains(vaultFile)) continue;

        _files.add(vaultFile);

        if (deleteOriginals) {
          try {
            await file.delete();
          } catch (_) {}
        }
      }

      await saveFiles();
    } catch (e) {
      debugPrint('Vault import error: $e');
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  void sortFiles(VaultSortType type) {
    switch (type) {
      case VaultSortType.nameAsc:
        _files.sort((a, b) =>
            a.file.path.toLowerCase().compareTo(b.file.path.toLowerCase()));
        break;

      case VaultSortType.nameDesc:
        _files.sort((a, b) =>
            b.file.path.toLowerCase().compareTo(a.file.path.toLowerCase()));
        break;

      case VaultSortType.dateNewest:
        _files.sort((a, b) => b.importedAt.compareTo(a.importedAt));
        break;

      case VaultSortType.dateOldest:
        _files.sort((a, b) => a.importedAt.compareTo(b.importedAt));
        break;

      case VaultSortType.sizeAsc:
        _files.sort((a, b) =>
            a.file.lengthSync().compareTo(b.file.lengthSync()));
        break;

      case VaultSortType.sizeDesc:
        _files.sort((a, b) =>
            b.file.lengthSync().compareTo(a.file.lengthSync()));
        break;

      case VaultSortType.reset:
        _files.sort((a, b) => a.importedAt.compareTo(b.importedAt));
        break;
    }

    notifyListeners();
  }


  bool isSelected(VaultFile file) => _selectedFiles.contains(file);

  void toggleSelection(VaultFile file) {
    if (_selectedFiles.contains(file)) {
      _selectedFiles.remove(file);
    } else {
      _selectedFiles.add(file);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedFiles.clear();
    notifyListeners();
  }

  void selectAll() {
    _selectedFiles
      ..clear()
      ..addAll(_files);
    notifyListeners();
  }

  void deleteSelected() {
    _files.removeWhere(_selectedFiles.contains);
    _selectedFiles.clear();
    saveFiles();
    notifyListeners();
  }

  void removeFile(VaultFile file) {
    _files.remove(file);
    _selectedFiles.remove(file);
    saveFiles();
    notifyListeners();
  }

  void clearVault() {
    _files.clear();
    _selectedFiles.clear();
    saveFiles();
    notifyListeners();
  }

  Future<void> saveFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final fileJsons = _files.map((f) => _vaultFileToJson(f)).toList();
    await prefs.setStringList(_dbKey, fileJsons);
  }

  Future<void> loadFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final fileJsons = prefs.getStringList(_dbKey) ?? [];
    _files.clear();

    for (final jsonStr in fileJsons) {
      try {
        final f = _vaultFileFromJson(jsonStr);
        if (f.file.existsSync()) {
          _files.add(f);
        }
      } catch (_) {}
    }

    notifyListeners();
  }

  String _vaultFileToJson(VaultFile f) {
    return '{'
        '"path":"${f.file.path}",'
        '"importedAt":${f.importedAt.millisecondsSinceEpoch},'
        '"type":"${f.type.name}",'
        '"thumbnailPath":${f.thumbnailPath != null ? '"${f.thumbnailPath}"' : 'null'}'
        '}';
  }

  VaultFile _vaultFileFromJson(String jsonStr) {
    final map = _parseJson(jsonStr);

    return VaultFile(
      file: File(map['path'] as String),
      importedAt:
      DateTime.fromMillisecondsSinceEpoch(map['importedAt'] as int),
      type: (map['type'] as String) == 'video'
          ? VaultFileType.video
          : VaultFileType.image,
      thumbnailPath: map['thumbnailPath'] as String?,
    );
  }

  Map<String, dynamic> _parseJson(String jsonStr) {
    final map = <String, dynamic>{};
    final regex = RegExp(r'"(\w+)":(null|"[^"]*"|\d+)');

    for (final match in regex.allMatches(jsonStr)) {
      final key = match.group(1)!;
      final value = match.group(2)!;

      if (value == 'null') {
        map[key] = null;
      } else if (value.startsWith('"')) {
        map[key] = value.substring(1, value.length - 1);
      } else {
        map[key] = int.parse(value);
      }
    }

    return map;
  }

  VaultController() {
    loadFiles();
  }
}
