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
  /// In-memory thumbnail cache
  final Map<String, String?> _videoThumbnails = {};

  // ================= VIDEO THUMBNAIL =================

  Future<String?> _getOrGenerateVideoThumbnail(VaultFile file) async {
    final videoPath = file.file.path;

    if (_videoThumbnails.containsKey(videoPath)) {
      return _videoThumbnails[videoPath];
    }

    final cacheDir = await getTemporaryDirectory();
    final thumbName =
        md5.convert(videoPath.codeUnits).toString() + '.png';
    final thumbPath = '${cacheDir.path}/$thumbName';

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
        final file = controller.files[index];
        final selected = controller.isSelected(file);

        return GestureDetector(
          onLongPress: () => controller.toggleSelection(file),
          onTap: () {
            if (controller.isSelectionMode) {
              controller.toggleSelection(file);
            } else {
              _openViewer(context, index);
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                /// ================= IMAGE =================
                if (_isImage(file.file.path))
                  Image.file(
                    file.file,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Colors.black),
                  ),

                /// ================= VIDEO =================
                if (_isVideo(file.file.path))
                  FutureBuilder<String?>(
                    future: _getOrGenerateVideoThumbnail(file),
                    builder: (_, snapshot) {
                      final thumb = snapshot.data;
                      if (thumb != null &&
                          File(thumb).existsSync()) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(thumb),
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
                if (selected)
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

  // ================= VIEWER =================

  void _openViewer(BuildContext context, int index) {
    final controller = widget.controller;
    final files = controller.files;
    final file = files[index];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          // ================= VIDEO =================
          if (_isVideo(file.file.path)) {
            return VaultVideoViewer(
              file: file,

              /// ✅ DELETE VIDEO CORRECTLY
              onDelete: () async {
                await controller.deleteFile(file);
              },
            );
          }

          // ================= IMAGE =================
          return VaultImageViewer(
            file: file,

            /// ✅ DELETE IMAGE
            onDelete: () async {
              await controller.deleteFile(file);
            },

            onPrevious: index > 0
                ? () {
              Navigator.pop(context);
              _openViewer(context, index - 1);
            }
                : null,

            onNext: index < files.length - 1
                ? () {
              Navigator.pop(context);
              _openViewer(context, index + 1);
            }
                : null,
          );
        },
      ),
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

  bool _isImage(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.jpg') ||
        p.endsWith('.jpeg') ||
        p.endsWith('.png') ||
        p.endsWith('.gif') ||
        p.endsWith('.bmp') ||
        p.endsWith('.webp');
  }

  bool _isVideo(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.mp4') ||
        p.endsWith('.mov') ||
        p.endsWith('.avi') ||
        p.endsWith('.mkv') ||
        p.endsWith('.webm');
  }
}
