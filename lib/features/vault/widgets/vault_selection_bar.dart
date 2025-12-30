import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../vault_controller.dart';
import '../../../data/models/album_model.dart';

class VaultSelectionBar extends StatelessWidget {
  const VaultSelectionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VaultController>();

    if (!controller.isSelectionMode) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        /// 🔹 TOP SELECTION BAR
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Text(
                      'Selected • ${controller.selectedCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),

                    /// MOVE
                    _action(
                      icon: Icons.folder,
                      label: 'Move',
                      onTap: () async {
                        final albumId =
                        await _showAlbumPicker(context);
                        if (albumId == null) return;

                        await controller.moveSelectedToAlbum(albumId);
                      },
                    ),

                    /// EXPORT
                    /// EXPORT
                    _action(
                      icon: Icons.upload,
                      label: 'Export',
                      onTap: () async {
                        final selectedPath =
                        await FilePicker.platform.getDirectoryPath(
                          dialogTitle: 'Select folder to export files',
                        );

                        if (selectedPath == null) return;

                        await controller.exportSelected(
                          Directory(selectedPath),
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Files exported successfully'),
                              backgroundColor: Colors.teal,
                            ),
                          );
                        }
                      },
                    ),


                    /// DELETE
                    _action(
                      icon: Icons.delete,
                      label: 'Delete',
                      color: Colors.redAccent,
                      onTap: () async {
                        final ok = await _confirmDelete(context);
                        if (!ok) return;
                        await controller.deleteSelected();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        /// 🔹 BOTTOM INFO TEXT
        const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 96),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Encrypting files securely...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Import photos or videos.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= ACTION BUTTON =================

  Widget _action({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: color, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= EXPORT DIRECTORY (FIXED) =================

  Future<Directory?> _getExportDirectory() async {
    if (Platform.isAndroid) {
      return await getDownloadsDirectory();
    }
    // iOS fallback
    return await getApplicationDocumentsDirectory();
  }

  // ================= ALBUM PICKER =================

  Future<String?> _showAlbumPicker(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('albums');
    if (raw == null) return null;

    final List decoded = jsonDecode(raw);
    final albums = decoded.map((e) => Album.fromJson(e)).toList();

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF101B2B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: albums.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final album = albums[index];

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pop(context, album.id),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    /// COVER
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: album.coverImage != null &&
                          File(album.coverImage!).existsSync()
                          ? Image.file(
                        File(album.coverImage!),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        width: 56,
                        height: 56,
                        color: Colors.white12,
                        child: const Icon(
                          Icons.folder,
                          color: Colors.white70,
                          size: 28,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            album.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${album.fileCount} items',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white38,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= CONFIRM DELETE =================

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF101B2B),
        title: const Text(
          'Delete files?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Selected files will be permanently deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ??
        false;
  }
}
