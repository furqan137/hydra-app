import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/album_model.dart';
import '../utils/album_video_thumbnail_helper.dart';

class AlbumGridCard extends StatelessWidget {
  final Album album;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const AlbumGridCard({
    super.key,
    required this.album,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  // ================= LOAD COVER (IMAGE SAFE) =================

  Future<File?> _loadCover() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('album_media_${album.id}');
    if (raw == null) return null;

    final List decoded = jsonDecode(raw);
    if (decoded.isEmpty) return null;

    final first = decoded.first;
    final String path = first['path'];
    final String type = first['type'];

    // ✅ IMAGE
    if (type == 'image') {
      final file = File(path);
      return file.existsSync() ? file : null;
    }

    // ✅ VIDEO → USE / GENERATE THUMBNAIL
    if (type == 'video') {
      final thumbPath = first['thumbnailPath'];

      if (thumbPath != null) {
        final thumbFile = File(thumbPath);
        if (thumbFile.existsSync()) return thumbFile;
      }

      // Generate thumbnail if missing
      final videoFile = File(path);
      if (!videoFile.existsSync()) return null;

      final generated =
      await AlbumVideoThumbnailHelper.generate(videoFile);

      if (generated != null) {
        // Save thumbnailPath back to prefs (important)
        first['thumbnailPath'] = generated.path;
        await prefs.setString(
          'album_media_${album.id}',
          jsonEncode(decoded),
        );
        return generated;
      }
    }

    return null;
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// COVER
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FutureBuilder<File?>(
                    future: _loadCover(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.done &&
                          snapshot.data != null) {
                        return Image.file(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        );
                      }

                      // Fallback
                      return Container(
                        color: Colors.white.withOpacity(0.08),
                        child: const Center(
                          child: Icon(
                            Icons.folder,
                            size: 42,
                            color: Color(0xFF0FB9B1),
                          ),
                        ),
                      );
                    },
                  ),

                  // LOCK ICON
                  if (album.isPrivate)
                    const Positioned(
                      right: 10,
                      bottom: 10,
                      child: Icon(
                        Icons.lock,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// TITLE + MENU
          Row(
            children: [
              Expanded(
                child: Text(
                  album.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  size: 18,
                  color: Colors.white70,
                ),
                onSelected: (value) {
                  if (value == 'rename') onRename();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'rename',
                    child: Text('Rename'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 2),

          Text(
            '${album.fileCount} files',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
