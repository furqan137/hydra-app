import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ REQUIRED
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';
import '../albums/albums_state.dart';

import '../../core/navigation/app_navigator.dart';

import '../../data/models/vault_file.dart';
import '../../core/utils/file_helper.dart';
import '../../services/file_delete_service.dart';
import '../../services/file_export_service.dart';
import '../../services/file_move_service.dart';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../services/local_backup_service.dart';



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

  /// 🔥 PATH-based selection (SAFE after restore)
  final Set<String> _selectedPaths = {};

  bool _isImporting = false;

  // ================= GETTERS =================

  List<VaultFile> get files => List.unmodifiable(_files);

  List<VaultFile> get selectedFiles =>
      _files.where((f) => _selectedPaths.contains(f.file.path)).toList();

  bool get isEmpty => _files.isEmpty;
  bool get isImporting => _isImporting;
  bool get isSelectionMode => _selectedPaths.isNotEmpty;

  int get selectedCount => _selectedPaths.length;
  int get totalFiles => _files.length;

  // ================= INIT =================

  VaultController() {
    loadFiles();
  }

  // ================= LOAD =================

  Future<void> loadFiles() async {
    _files.clear();
    _selectedPaths.clear();

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dbKey);

    if (raw == null || raw.isEmpty) {
      notifyListeners();
      return;
    }

    try {
      final List decoded = jsonDecode(raw);

      /// 🔥 IMPORTANT
      /// Do NOT filter existsSync here
      /// Restore extracts files async
      final restored =
      decoded.map<VaultFile>((e) => VaultFile.fromJson(e)).toList();

      _files.addAll(restored);
    } catch (e) {
      debugPrint('❌ Vault load error: $e');
    }

    notifyListeners();
  }


  // ================= RESTORE BACKUP =================

  Future<void> restoreBackup() async {
    if (_isImporting) return;

    _isImporting = true;
    notifyListeners();

    try {
      // 1️⃣ Pick ANY file (Android-safe)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      // User cancelled picker
      if (result == null || result.files.isEmpty) return;

      final path = result.files.single.path;
      if (path == null) return;

      // 2️⃣ Validate extension MANUALLY
      if (!path.toLowerCase().endsWith('.hidra')) {
        throw Exception('Invalid backup file. Please select a .hidra backup.');
      }

      final backupFile = File(path);
      if (!backupFile.existsSync()) {
        throw Exception('Backup file not found.');
      }

      // 3️⃣ Ask password
      final password = await _askPassword();

      // 4️⃣ Restore backup
      await LocalBackupService.restoreBackup(
        backupFile: backupFile,
        password: password,
      );

// 5️⃣ Reload VAULT
      await reloadAfterRestore();

// 6️⃣ Reload ALBUMS (✅ CORRECT METHOD NAME)
      Provider.of<AlbumsState>(
        navContext,
        listen: false,
      ).reloadFromStorage();



    } catch (e) {
      debugPrint('❌ Restore failed: $e');

      await showDialog(
        context: navContext,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Restore Failed'),
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(navContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }


  /// 🔥 CALLED AFTER BACKUP RESTORE
  Future<void> reloadAfterRestore() async {
    await loadFiles();

    /// Delay cleanup to allow filesystem to settle
    Future.delayed(const Duration(milliseconds: 300), cleanupMissingFiles);
  }

  /// 🔥 UI SAFE FORCE RELOAD
  Future<void> forceReload() async {
    debugPrint('🔄 Vault forceReload');
    await reloadAfterRestore();
  }

  /// 🔥 CLEANUP (OPTIONAL BUT IMPORTANT)
  Future<void> cleanupMissingFiles() async {
    final before = _files.length;
    _files.removeWhere((f) => !f.file.existsSync());

    if (_files.length != before) {
      await saveFiles();
      notifyListeners();
    }
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

  bool isSelected(VaultFile file) =>
      _selectedPaths.contains(file.file.path);

  void toggleSelection(VaultFile file) {
    _selectedPaths.contains(file.file.path)
        ? _selectedPaths.remove(file.file.path)
        : _selectedPaths.add(file.file.path);
    notifyListeners();
  }

  void clearSelection() {
    _selectedPaths.clear();
    notifyListeners();
  }

  void selectAll() {
    _selectedPaths
      ..clear()
      ..addAll(_files.map((f) => f.file.path));
    notifyListeners();
  }

  // ================= DELETE =================

  Future<void> deleteSelected() async {
    if (_selectedPaths.isEmpty) return;

    await FileDeleteService.deleteVaultFiles(selectedFiles);

    _files.removeWhere((f) => _selectedPaths.contains(f.file.path));
    _selectedPaths.clear();

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
    _selectedPaths.remove(file.file.path);

    await saveFiles();
    notifyListeners();
  }

  // ================= EXPORT / MOVE =================

  Future<void> exportSelected(Directory targetDir) async {
    if (_selectedPaths.isEmpty) return;

    await FileExportService.exportVaultFiles(
      selectedFiles,
      targetDir: targetDir,
    );

    clearSelection();
  }

  Future<void> moveSelectedToAlbum(String albumId) async {
    if (_selectedPaths.isEmpty) return;

    await FileMoveService.moveVaultFilesToAlbum(
      files: selectedFiles,
      albumId: albumId,
    );

    _files.removeWhere((f) => _selectedPaths.contains(f.file.path));
    _selectedPaths.clear();

    await saveFiles();
    notifyListeners();
  }

  Future<String> _askPassword() async {
    final controller = TextEditingController();
    String password = '';

    await showDialog(
      context: navContext, // ✅ correct global context
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Enter Backup Password'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Password',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(navContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                password = controller.text.trim();
                Navigator.pop(navContext);
              },
              child: const Text('Restore'),
            ),
          ],
        );
      },
    );

    if (password.isEmpty) {
      throw Exception('Password required');
    }

    return password;
  }





  // ================= STORAGE =================

  Future<void> saveFiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _dbKey,
      jsonEncode(_files.map((f) => f.toJson()).toList()),
    );
  }
}

bool _isVideo(String name) {
  final ext = name.toLowerCase();
  return ext.endsWith('.mp4') ||
      ext.endsWith('.mov') ||
      ext.endsWith('.mkv');
}

bool _isSupportedMedia(File file) {
  final ext = p.extension(file.path).toLowerCase();
  return ext == '.jpg' ||
      ext == '.jpeg' ||
      ext == '.png' ||
      ext == '.webp' ||
      ext == '.mp4' ||
      ext == '.mov' ||
      ext == '.mkv';
}
