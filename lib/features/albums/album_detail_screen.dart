import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/album_model.dart';
import '../../data/models/album_media_file.dart';

import 'widgets/album_media_tile.dart';
import '../viewer/album_viewer/album_image_viewer.dart';
import '../viewer/album_viewer/album_video_viewer.dart';
import 'utils/album_video_thumbnail_helper.dart';

// ⬇️ NEW (Vault picker)
import '../albums/pickers/vault_picker_screen.dart';

class AlbumDetailScreen extends StatefulWidget {
  final Album album;

  const AlbumDetailScreen({
    Key? key,
    required this.album,
  }) : super(key: key);

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  final List<AlbumMediaFile> mediaFiles = [];

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  // ================= LOAD / SAVE =================

  Future<void> _loadMedia() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'album_media_${widget.album.id}';
    final jsonStr = prefs.getString(key);

    if (jsonStr == null) return;

    final List decoded = jsonDecode(jsonStr);

    setState(() {
      mediaFiles.clear();
      mediaFiles.addAll(
        decoded.map<AlbumMediaFile>((item) {
          final type =
          item['type'] == 'video' ? AlbumMediaType.video : AlbumMediaType.image;
          return AlbumMediaFile(
            file: File(item['path']),
            type: type,
            importedAt: DateTime.parse(item['importedAt']),
            thumbnailPath: item['thumbnailPath'],
          );
        }),
      );
    });

    // Generate missing thumbnails
    for (int i = 0; i < mediaFiles.length; i++) {
      final media = mediaFiles[i];
      if (media.type == AlbumMediaType.video &&
          (media.thumbnailPath == null ||
              !File(media.thumbnailPath!).existsSync())) {
        final thumb = await AlbumVideoThumbnailHelper.generate(media.file);
        if (thumb != null) {
          mediaFiles[i] = media.copyWith(thumbnailPath: thumb.path);
          await _saveMedia();
        }
      }
    }
  }

  Future<void> _saveMedia() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'album_media_${widget.album.id}';

    final jsonList = mediaFiles.map((f) {
      return {
        'path': f.file.path,
        'type': f.type == AlbumMediaType.video ? 'video' : 'image',
        'importedAt': f.importedAt.toIso8601String(),
        'thumbnailPath': f.thumbnailPath,
      };
    }).toList();

    await prefs.setString(key, jsonEncode(jsonList));
  }

  // ================= ADD OPTIONS =================

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101B2B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _optionTile(
                icon: Icons.add_photo_alternate,
                title: 'Import from phone',
                onTap: () {
                  Navigator.pop(context);
                  _importFromPhone();
                },
              ),
              const SizedBox(height: 12),
              _optionTile(
                icon: Icons.lock,
                title: 'Select from Vault',
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFromVault();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _albumTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF050B18).withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // BACK BUTTON (FORCED WHITE)
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),

            const SizedBox(width: 8),

            // ALBUM NAME
            Expanded(
              child: Text(
                widget.album.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _optionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0FB9B1)),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  // ================= IMPORT FROM PHONE =================

  Future<void> _importFromPhone() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultipleMedia();

    if (picked.isEmpty) return;

    final newMedia = picked.map((x) {
      final isVideo =
          (x.mimeType?.startsWith('video') ?? false) ||
              x.path.toLowerCase().endsWith('.mp4') ||
              x.path.toLowerCase().endsWith('.mov') ||
              x.path.toLowerCase().endsWith('.avi') ||
              x.path.toLowerCase().endsWith('.mkv') ||
              x.path.toLowerCase().endsWith('.webm');

      return AlbumMediaFile(
        file: File(x.path),
        type: isVideo ? AlbumMediaType.video : AlbumMediaType.image,
        importedAt: DateTime.now(),
      );
    }).toList();

    setState(() {
      mediaFiles.addAll(newMedia);
    });

    await _generateMissingThumbnails();
    await _saveMedia();
  }

  // ================= PICK FROM VAULT =================

  Future<void> _pickFromVault() async {
    final List<File>? selectedFiles = await showModalBottomSheet<List<File>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return VaultPickerScreen(
          albumId: widget.album.id,
        );
      },
    );

    if (selectedFiles == null || selectedFiles.isEmpty) return;

    setState(() {
      mediaFiles.addAll(
        selectedFiles.map(
              (file) => AlbumMediaFile(
            file: file,
            type: _isVideo(file)
                ? AlbumMediaType.video
                : AlbumMediaType.image,
            importedAt: DateTime.now(),
          ),
        ),
      );
    });

    await _generateMissingThumbnails();
    await _saveMedia();
  }



  Future<void> _generateMissingThumbnails() async {
    for (int i = 0; i < mediaFiles.length; i++) {
      final media = mediaFiles[i];
      if (media.type == AlbumMediaType.video &&
          (media.thumbnailPath == null ||
              !File(media.thumbnailPath!).existsSync())) {
        final thumb = await AlbumVideoThumbnailHelper.generate(media.file);
        if (thumb != null) {
          mediaFiles[i] = media.copyWith(thumbnailPath: thumb.path);
        }
      }
    }
  }

// ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),

      body: Column(
        children: [
          // ================= TOP BAR =================
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF050B18),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white12,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // BACK BUTTON
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),

                  const SizedBox(width: 4),

                  // TITLE
                  Expanded(
                    child: Text(
                      widget.album.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= CONTENT =================
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF050B18),
                    Color(0xFF0FB9B1),
                  ],
                ),
              ),
              child: mediaFiles.isEmpty
                  ? const Center(
                child: Text(
                  'No media yet',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              )
                  : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: mediaFiles.length,
                itemBuilder: (_, i) {
                  final media = mediaFiles[i];
                  return AlbumMediaTile(
                    mediaFile: media,
                    onTap: () => _openViewer(media, i),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // ================= FAB =================
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'album_detail_fab',
        backgroundColor: const Color(0xFF0FB9B1),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        onPressed: _showAddOptions,
      ),
    );
  }

  // ================= VIEWER =================

  void _openViewer(AlbumMediaFile media, int index) {
    final onDelete = () async {
      setState(() {
        mediaFiles.removeAt(index);
      });
      await _saveMedia();
      Navigator.pop(context);
    };

    if (media.type == AlbumMediaType.image) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AlbumImageViewer(
            file: media,
            onDelete: onDelete,
            onExport: () {},
            onMove: () {},
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AlbumVideoViewer(
            file: media,
            onDelete: onDelete,
            onExport: () {},
            onMove: () {},
          ),
        ),
      );
    }
  }
}

bool _isVideo(File file) {
  final path = file.path.toLowerCase();

  return path.endsWith('.mp4') ||
      path.endsWith('.mov') ||
      path.endsWith('.avi') ||
      path.endsWith('.mkv') ||
      path.endsWith('.webm');
}
