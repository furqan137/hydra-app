import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../data/models/vault_file.dart';
import '../vault_controller.dart';

// VIEWERS
import '../../viewer/vault_viewer/vault_image_viewer.dart';
import '../../viewer/vault_viewer/vault_video_viewer.dart';

class VaultGrid extends StatefulWidget {
  final VaultController controller;

  const VaultGrid({
    super.key,
    required this.controller,
  });

  @override
  State<VaultGrid> createState() => _VaultGridState();
}

class _VaultGridState extends State<VaultGrid> {
  // Cache thumbnails in-memory
  final Map<String, String?> _videoThumbnails = {};

  // ================= VIDEO THUMBNAIL =================

  Future<String?> _getOrGenerateVideoThumbnail(VaultFile vaultFile) async {
    final videoPath = vaultFile.file.path;

    // Memory cache
    if (_videoThumbnails.containsKey(videoPath)) {
      return _videoThumbnails[videoPath];
    }

    final cacheDir = await getTemporaryDirectory();
    final thumbName =
        md5.convert(videoPath.codeUnits).toString() + '.png';
    final thumbPath = '${cacheDir.path}/$thumbName';

    // Disk cache
    if (File(thumbPath).existsSync()) {
      _videoThumbnails[videoPath] = thumbPath;
      return thumbPath;
    }

    final generated = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: thumbPath,
      imageFormat: ImageFormat.PNG,
      maxWidth: 256,
      quality: 60,
    );

    _videoThumbnails[videoPath] = generated;
    return generated;
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: controller.files.length,
      itemBuilder: (_, index) {
        final vaultFile = controller.files[index];
        final isSelected = controller.isSelected(vaultFile);

        return GestureDetector(
          onLongPress: () => controller.toggleSelection(vaultFile),
          onTap: () {
            if (controller.isSelectionMode) {
              controller.toggleSelection(vaultFile);
            } else {
              _openViewer(context, vaultFile);
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                /// IMAGE
                if (_isImageFile(vaultFile.file.path))
                  Image.file(
                    vaultFile.file,
                    fit: BoxFit.cover,
                  ),

                /// VIDEO
                if (_isVideoFile(vaultFile.file.path))
                  FutureBuilder<String?>(
                    future: _getOrGenerateVideoThumbnail(vaultFile),
                    builder: (_, snapshot) {
                      final thumbPath = snapshot.data;
                      if (thumbPath != null &&
                          File(thumbPath).existsSync()) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(thumbPath),
                              fit: BoxFit.cover,
                            ),
                            const Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                size: 48,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        );
                      }
                      return _videoPlaceholder();
                    },
                  ),

                /// 🔒 LOCK ICON
                const Positioned(
                  bottom: 8,
                  right: 8,
                  child: Icon(
                    Icons.lock,
                    size: 18,
                    color: Colors.white70,
                  ),
                ),

                /// ✅ SELECTION OVERLAY
                if (isSelected)
                  Container(
                    color: Colors.black.withOpacity(0.35),
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
          ),
        );
      },
    );
  }

  // ================= HELPERS =================

  Widget _videoPlaceholder() {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: Icon(
          Icons.play_circle_fill,
          size: 48,
          color: Colors.white70,
        ),
      ),
    );
  }

  void _openViewer(BuildContext context, VaultFile vaultFile) {
    final path = vaultFile.file.path.toLowerCase();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _isVideoFile(path)
            ? VaultVideoViewer(file: vaultFile)
            : VaultImageViewer(file: vaultFile),
      ),
    );
  }

  bool _isImageFile(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.jpg') ||
        p.endsWith('.jpeg') ||
        p.endsWith('.png') ||
        p.endsWith('.gif') ||
        p.endsWith('.bmp') ||
        p.endsWith('.webp');
  }

  bool _isVideoFile(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.mp4') ||
        p.endsWith('.mov') ||
        p.endsWith('.avi') ||
        p.endsWith('.mkv') ||
        p.endsWith('.webm');
  }
}
