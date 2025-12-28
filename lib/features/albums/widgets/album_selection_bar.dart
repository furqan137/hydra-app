import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../album_detail_controller.dart'; // ✅ CORRECT CONTROLLER
import '../../../data/models/album_model.dart';

class AlbumSelectionBar extends StatelessWidget {
  const AlbumSelectionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AlbumDetailController>();

    if (!controller.isSelectionMode) {
      return const SizedBox.shrink();
    }

    return SafeArea(
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
                /// SELECTED COUNT
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
                    final albumId = await _pickAlbum(context);
                    if (albumId == null) return;

                    await controller.moveSelectedToAlbum(albumId);
                  },
                ),

                /// EXPORT
                _action(
                  icon: Icons.upload,
                  label: 'Export',
                  onTap: () async {
                    final dir = await getDownloadsDirectory();
                    if (dir == null) return;

                    await controller.exportSelected(dir);
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
                style: TextStyle(
                  color: color,
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

  Future<String?> _pickAlbum(BuildContext context) async {
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
                    /// FOLDER ICON
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.folder,
                        color: Colors.white70,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 14),

                    /// ALBUM INFO
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
