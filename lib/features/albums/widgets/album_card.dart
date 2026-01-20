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

  // ================= TEXT COLOR =================

  Color _textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
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
    final String type = first['type'];

    if (path == null) return null;

    final file = File(path);
    if (!file.existsSync()) return null;

    if (type == 'image') return file;

    if (type == 'video') {
      final String? thumbPath = first['thumbnailPath'];
      if (thumbPath != null) {
        final thumbFile = File(thumbPath);
        if (thumbFile.existsSync()) return thumbFile;
      }
      return await AlbumVideoThumbnailHelper.generate(file);
    }

    return null;
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final album = widget.album;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 108,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          // ✅ FIX: NOT WHITE IN LIGHT MODE
          color: theme.brightness == Brightness.dark
              ? colors.surface.withOpacity(0.08)
              : colors.surfaceVariant.withOpacity(0.65),
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
                            color: colors.surfaceVariant,
                            child: Icon(
                              Icons.folder,
                              color: colors.primary,
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          album.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _fileCount == null
                              ? 'Loading…'
                              : '$_fileCount files',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ================= MENU =================
                Theme(
                  data: theme.copyWith(
                    popupMenuTheme: PopupMenuThemeData(
                      color: colors.surface,
                      textStyle: TextStyle(color: colors.onSurface),
                    ),
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: colors.onSurface.withOpacity(0.7),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onSelected: (value) => _handleMenu(context, value),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'rename',
                        child: Row(
                          children: [
                            Icon(Icons.edit,
                                size: 18, color: colors.onSurface),
                            const SizedBox(width: 8),
                            Text(
                              'Rename',
                              style:
                              TextStyle(color: colors.onSurface),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete,
                                size: 18,
                                color: Colors.redAccent),
                            const SizedBox(width: 8),
                            Text(
                              'Delete',
                              style:
                              TextStyle(color: colors.onSurface),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
              ],
            ),

            // ================= LOCK =================
            if (album.isPrivate)
              Positioned(
                right: 14,
                bottom: 14,
                child: Icon(
                  Icons.lock,
                  size: 18,
                  color: colors.onSurface.withOpacity(0.6),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textColor = _textColor(context);

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Delete Album',
        style: theme.textTheme.titleMedium?.copyWith(color: textColor),
      ),
      content: Text(
        'Are you sure you want to delete this album?',
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: textColor.withOpacity(0.8)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: TextStyle(color: textColor)),
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
    );
  }

  Widget _renameDialog(
      BuildContext context,
      TextEditingController controller,
      ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textColor = _textColor(context);

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Rename Album',
        style: theme.textTheme.titleMedium?.copyWith(color: textColor),
      ),
      content: TextField(
        controller: controller,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: 'Album name',
          hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
          filled: true,
          fillColor: colors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: textColor)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
          ),
          onPressed: () =>
              Navigator.pop(context, controller.text.trim()),
          child: const Text('Rename'),
        ),
      ],
    );
  }
}
