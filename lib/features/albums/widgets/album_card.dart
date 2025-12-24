import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/album_model.dart';
import '../albums_state.dart';
import '../utils/album_video_thumbnail_helper.dart';

class AlbumCard extends StatefulWidget {
  final Album album;
  final VoidCallback? onTap;

  const AlbumCard({
    super.key,
    required this.album,
    this.onTap,
  });

  @override
  State<AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<AlbumCard> {
  int? _fileCount;

  @override
  void initState() {
    super.initState();
    _loadFileCount();
  }

  // ================= FILE COUNT =================

  Future<void> _loadFileCount() async {
    final count = await Album.getAlbumFileCount(widget.album.id);
    if (!mounted) return;
    setState(() => _fileCount = count);
  }

  // ================= COVER IMAGE =================

  Future<File?> _loadCover() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('album_media_${widget.album.id}');
    if (raw == null) return null;

    final List decoded = jsonDecode(raw);
    if (decoded.isEmpty) return null;

    final first = decoded.first;
    final String? path = first['path'];
    final String type = first['type']; // 'image' or 'video'

    if (path == null) return null;

    final file = File(path);
    if (!file.existsSync()) return null;

    // ✅ IMAGE → return directly
    if (type == 'image') {
      return file;
    }

    // ✅ VIDEO → use thumbnail
    if (type == 'video') {
      final String? thumbPath = first['thumbnailPath'];

      // Thumbnail already exists
      if (thumbPath != null) {
        final thumbFile = File(thumbPath);
        if (thumbFile.existsSync()) return thumbFile;
      }

      // Generate thumbnail if missing
      final generated =
      await AlbumVideoThumbnailHelper.generate(file);
      return generated;
    }

    return null;
  }


  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final album = widget.album;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 108, // ✅ taller card like reference UI
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // ================= COVER =================
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 120,
                      height: double.infinity,
                      child: FutureBuilder<File?>(
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

                          return Container(
                            color: Colors.black26,
                            child: const Icon(
                              Icons.folder,
                              color: Color(0xFF0FB9B1),
                              size: 42,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ================= TEXT =================
                Expanded(
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          album.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _fileCount == null
                              ? 'Loading…'
                              : '$_fileCount files',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ================= MENU =================
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white70),
                  color: const Color(0xFF101B2B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (value) => _handleMenu(context, value),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Rename'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete,
                              size: 18, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 8),
              ],
            ),

            // ================= LOCK OVERLAY =================
            if (album.isPrivate)
              const Positioned(
                right: 14,
                bottom: 14,
                child: Icon(
                  Icons.lock,
                  size: 18,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================= MENU HANDLER =================

  Future<void> _handleMenu(BuildContext context, String action) async {
    final albumsState = context.read<AlbumsState>();

    if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => _confirmDeleteDialog(context),
      );

      if (confirm == true) {
        albumsState.setAlbums(
          albumsState.albums
              .where((a) => a.id != widget.album.id)
              .toList(),
        );
      }
    }

    if (action == 'rename') {
      final controller = TextEditingController(text: widget.album.name);

      final newName = await showDialog<String>(
        context: context,
        builder: (_) => _renameDialog(context, controller),
      );

      if (newName != null && newName.isNotEmpty) {
        albumsState.setAlbums(
          albumsState.albums.map<Album>((a) {
            if (a.id == widget.album.id) {
              return Album(
                id: a.id,
                name: newName,
                isPrivate: a.isPrivate,
                fileCount: a.fileCount,
                coverImage: a.coverImage,
              );
            }
            return a;
          }).toList(),
        );
      }
    }
  }

  // ================= DIALOGS =================

  Widget _confirmDeleteDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF101B2B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Delete Album', style: TextStyle(color: Colors.white)),
      content: const Text(
        'Are you sure you want to delete this album?',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0FB9B1),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  Widget _renameDialog(
      BuildContext context,
      TextEditingController controller,
      ) {
    return AlertDialog(
      backgroundColor: const Color(0xFF101B2B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Rename Album', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Album name',
          hintStyle: TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Color(0xFF192841),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0FB9B1),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () =>
              Navigator.pop(context, controller.text.trim()),
          child: const Text('Rename'),
        ),
      ],
    );
  }
}
