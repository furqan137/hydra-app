import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/models/album_media_file.dart';

class AlbumImageViewer extends StatelessWidget {
  final AlbumMediaFile file;

  /// Navigation
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  /// Actions
  final VoidCallback? onDelete;

  const AlbumImageViewer({
    super.key,
    required this.file,
    this.onNext,
    this.onPrevious,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// ================= IMAGE =================
          Center(
            child: Image.file(
              file.file,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image,
                color: Colors.white54,
                size: 80,
              ),
            ),
          ),

          /// ================= TOP BAR =================
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// DELETE (LEFT)
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                    size: 24,
                  ),
                  onPressed: onDelete == null
                      ? null
                      : () async {
                    final ok = await _confirmDelete(context);
                    if (!ok) return;

                    onDelete!.call();
                    Navigator.pop(context);
                  },
                ),

                /// CLOSE (RIGHT)
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          /// ================= BOTTOM NAVIGATION =================
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// PREVIOUS
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: onPrevious,
                    ),

                    /// NEXT
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: onNext,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= CONFIRM DELETE =================

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF101B2B),
        title: const Text(
          'Delete file?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This file will be permanently deleted.',
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
