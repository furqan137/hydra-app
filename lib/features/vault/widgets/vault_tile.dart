import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../vault_controller.dart';
import '../utils/video_thumbnail_helper.dart';
import '../../viewer/vault_viewer/vault_image_viewer.dart';
import '../../viewer/vault_viewer/vault_video_viewer.dart';
import '../../../data/models/vault_file.dart';

class VaultTile extends StatelessWidget {
  final VaultFile vaultFile;

  const VaultTile({
    super.key,
    required this.vaultFile,
  });

  bool get _isVideo => vaultFile.type == VaultFileType.video;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VaultController>();
    final bool selected = controller.isSelected(vaultFile);

    return GestureDetector(
      onLongPress: () => controller.toggleSelection(vaultFile),
      onTap: () {
        if (controller.isSelectionMode) {
          controller.toggleSelection(vaultFile);
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _isVideo
                ? VaultVideoViewer(file: vaultFile)
                : VaultImageViewer(file: vaultFile),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          /// ================= THUMBNAIL =================
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _isVideo
                ? _VideoThumbnailPersistent(vaultFile: vaultFile)
                : Image.file(
                    vaultFile.file,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: Colors.black),
                  ),
          ),

          /// ▶ PLAY ICON (VIDEO)
          if (_isVideo)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 48,
                color: Colors.white70,
              ),
            ),

          /// 🔒 LOCK ICON
          const Positioned(
            bottom: 8,
            right: 8,
            child: Icon(
              Icons.lock,
              color: Colors.white70,
              size: 18,
            ),
          ),

          /// ✅ SELECTION OVERLAY
          if (selected)
            Container(
              color: const Color.fromRGBO(0, 0, 0, 0.35),
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
}

/// ===============================
/// Video thumbnail widget that persists thumbnailPath in VaultFile
/// ===============================
class _VideoThumbnailPersistent extends StatefulWidget {
  final VaultFile vaultFile;
  const _VideoThumbnailPersistent({super.key, required this.vaultFile});

  @override
  State<_VideoThumbnailPersistent> createState() => _VideoThumbnailPersistentState();
}

class _VideoThumbnailPersistentState extends State<_VideoThumbnailPersistent> {
  late Future<String?> _thumbFuture;

  @override
  void initState() {
    super.initState();
    _thumbFuture = _getOrGenerateThumb();
  }

  Future<String?> _getOrGenerateThumb() async {
    if (widget.vaultFile.thumbnailPath != null &&
        File(widget.vaultFile.thumbnailPath!).existsSync()) {
      return widget.vaultFile.thumbnailPath;
    }
    // Generate thumbnail and update controller
    final thumbFile = await VideoThumbnailHelper.generate(
      widget.vaultFile.file,
      isEncrypted: widget.vaultFile.isEncrypted,
      decrypt: widget.vaultFile.isEncrypted ? () async {
        // TODO: Implement your decryption logic here
        // Example:
        // final decryptedBytes = await decryptFile(widget.vaultFile.file);
        // final temp = await File('${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}_${widget.vaultFile.file.path.split('/').last}').create();
        // await temp.writeAsBytes(decryptedBytes);
        // return temp;
        return null;
      } : null,
    );
    if (thumbFile != null && thumbFile.existsSync()) {
      final controller = context.read<VaultController>();
      final updated = widget.vaultFile.copyWith(thumbnailPath: thumbFile.path);
      final idx = controller.files.indexWhere((f) => f.file.path == widget.vaultFile.file.path);
      if (idx != -1) {
        controller.files[idx] = updated;
        await controller.saveFiles();
        controller.notifyListeners();
      }
      return thumbFile.path;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _thumbFuture,
      builder: (context, snapshot) {
        final thumbPath = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done &&
            thumbPath != null && File(thumbPath).existsSync()) {
          return Image.file(
            File(thumbPath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Colors.black),
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
      },
    );
  }
}
