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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
                  // ✅ THEME-AWARE BACKGROUND
                  color: theme.brightness == Brightness.dark
                      ? colors.surface.withOpacity(0.45)
                      : colors.surfaceVariant.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Text(
                      'Selected • ${controller.selectedCount}',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),

                    /// MOVE
                    _action(
                      context,
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
                    _action(
                      context,
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
                            SnackBar(
                              content:
                              const Text('Files exported successfully'),
                              backgroundColor: colors.primary,
                            ),
                          );
                        }
                      },
                    ),

                    /// DELETE
                    _action(
                      context,
                      icon: Icons.delete,
                      label: 'Delete',
                      color: colors.error,
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
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 96),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Encrypting files securely...',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Import photos or videos.',
                  style: TextStyle(
                    color: colors.onSurface.withOpacity(0.6),
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

  Widget _action(
      BuildContext context, {
        required IconData icon,
        required String label,
        Color? color,
        required VoidCallback onTap,
      }) {
    final colors = Theme.of(context).colorScheme;

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
              Icon(
                icon,
                color: color ?? colors.onSurface,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color ?? colors.onSurface,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= ALBUM PICKER =================

  Future<String?> _showAlbumPicker(BuildContext context) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('albums');
    if (raw == null) return null;

    final List decoded = jsonDecode(raw);
    final albums = decoded.map((e) => Album.fromJson(e)).toList();

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.surface,
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
                  color: theme.brightness == Brightness.dark
                      ? colors.surface.withOpacity(0.08)
                      : colors.surfaceVariant,
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
                        color: colors.surfaceVariant,
                        child: Icon(
                          Icons.folder,
                          color:
                          colors.onSurface.withOpacity(0.6),
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
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${album.fileCount} items',
                            style: TextStyle(
                              color:
                              colors.onSurface.withOpacity(0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.chevron_right,
                      color: colors.onSurface.withOpacity(0.4),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          'Delete files?',
          style: TextStyle(color: colors.onSurface),
        ),
        content: Text(
          'Selected files will be permanently deleted.',
          style:
          TextStyle(color: colors.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.onSurface),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
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
