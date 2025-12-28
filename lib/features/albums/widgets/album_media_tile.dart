import 'dart:io';
import 'package:flutter/material.dart';

import '../../../data/models/album_media_file.dart';

class AlbumMediaTile extends StatelessWidget {
  final AlbumMediaFile mediaFile;

  /// NEW
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AlbumMediaTile({
    super.key,
    required this.mediaFile,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  bool get _isVideo => mediaFile.type == AlbumMediaType.video;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          /// ================= THUMBNAIL =================
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _isVideo ? _videoThumb() : _imageThumb(),
          ),

          /// ▶ VIDEO PLAY ICON
          if (_isVideo)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white70,
                size: 44,
              ),
            ),

          /// 🔒 LOCK ICON (optional, keep for future private albums)
          if (mediaFile.isEncrypted)
            const Positioned(
              right: 8,
              bottom: 8,
              child: Icon(
                Icons.lock,
                color: Colors.white70,
                size: 18,
              ),
            ),

          /// ✅ SELECTION OVERLAY
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF0FB9B1),
                  size: 36,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ================= IMAGE =================

  Widget _imageThumb() {
    return Image.file(
      mediaFile.file,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
      const ColoredBox(color: Colors.black),
    );
  }

  // ================= VIDEO =================

  Widget _videoThumb() {
    if (mediaFile.thumbnailPath != null &&
        File(mediaFile.thumbnailPath!).existsSync()) {
      return Image.file(
        File(mediaFile.thumbnailPath!),
        fit: BoxFit.cover,
      );
    }

    return const ColoredBox(
      color: Colors.black87,
      child: Center(
        child: Icon(
          Icons.videocam,
          color: Colors.white38,
          size: 32,
        ),
      ),
    );
  }
}
