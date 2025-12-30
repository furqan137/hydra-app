import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/models/album_model.dart';
import '../../data/models/album_media_file.dart';
import '../../../data/models/vault_file.dart'; //

import 'widgets/album_media_tile.dart';
import '../viewer/album_viewer/album_image_viewer.dart';
import '../viewer/album_viewer/album_video_viewer.dart';
import 'utils/album_video_thumbnail_helper.dart';
import 'widgets/album_selection_bar.dart';
import '../albums/pickers/vault_picker_screen.dart';
import 'album_detail_controller.dart';

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

  final Set<AlbumMediaFile> _selected = {};


  bool get isSelectionMode => _selected.isNotEmpty;
  int get selectedCount => _selected.length;

  bool isSelected(AlbumMediaFile file) => _selected.contains(file);

  void toggleSelection(AlbumMediaFile file) {
    setState(() {
      _selected.contains(file)
          ? _selected.remove(file)
          : _selected.add(file);
    });
  }

  void clearSelection() {
    setState(() => _selected.clear());
  }


  static const double _selectionBarHeight = 88;
  static const double _topBarHeight = 88;



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

  Future<Directory?> _getExportDirectory() async {
    try {
      if (Platform.isAndroid) {
        return await getDownloadsDirectory();
      } else {
        return await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _deleteSelected() async {
    for (final media in _selected) {
      try {
        if (media.file.existsSync()) {
          await media.file.delete();
        }
      } catch (_) {}
    }

    setState(() {
      mediaFiles.removeWhere(_selected.contains);
      _selected.clear();
    });

    await _saveMedia();
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
    final List<VaultFile>? selectedVaultFiles =
    await showModalBottomSheet<List<VaultFile>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return VaultPickerScreen(
          albumId: widget.album.id,
        );
      },
    );

    if (selectedVaultFiles == null || selectedVaultFiles.isEmpty) return;

    final List<AlbumMediaFile> newMedia = selectedVaultFiles
        .where((vaultFile) {
      // prevent duplicates
      return !mediaFiles.any(
            (m) => m.file.path == vaultFile.file.path,
      );
    })
        .map<AlbumMediaFile>((vaultFile) {
      return AlbumMediaFile(
        file: vaultFile.file,
        type: vaultFile.type == VaultFileType.video
            ? AlbumMediaType.video
            : AlbumMediaType.image,
        importedAt: DateTime.now(),
        thumbnailPath: vaultFile.thumbnailPath,
      );
    })
        .toList();

    if (newMedia.isEmpty) return;

    setState(() {
      mediaFiles.addAll(newMedia); // ✅ now correct type
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

      body: Stack(
        children: [
          // ================= GRID CONTENT (NEVER MOVES) =================
          Container(
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
              padding: const EdgeInsets.fromLTRB(
                16,
                _topBarHeight + 16, // ✅ ONE fixed offset
                16,
                16,
              ),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: mediaFiles.length,
              itemBuilder: (_, i) {
                final media = mediaFiles[i];
                final selected = isSelected(media);

                return AlbumMediaTile(
                  mediaFile: media,
                  isSelected: selected,
                  onLongPress: () => toggleSelection(media),
                  onTap: () {
                    if (isSelectionMode) {
                      toggleSelection(media);
                    } else {
                      _openViewer(media, i);
                    }
                  },
                );
              },
            ),
          ),

          // ================= NORMAL TOP BAR =================
          if (!isSelectionMode)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _topBarHeight,
              child: SafeArea(
                bottom: false,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
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
            ),

          // ================= SELECTION BAR =================
          if (isSelectionMode)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _topBarHeight,
              child: AlbumSelectionBar(
                selectedCount: selectedCount,
                onClear: clearSelection,
                onDelete: _deleteSelected,
                onExport: _exportSelected,
              ),
            ),
        ],
      ),


      /// ================= FAB =================
      floatingActionButton: isSelectionMode
          ? null
          : FloatingActionButton.extended(
        heroTag: 'album_detail_fab',
        backgroundColor: const Color(0xFF0FB9B1),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        onPressed: _showAddOptions,
      ),
    );
  }

  Future<void> _exportSelected() async {
    final dir = await _getExportDirectory();
    if (dir == null) return;

    for (final media in _selected) {
      final name = media.file.uri.pathSegments.last;
      await media.file.copy('${dir.path}/$name');
    }

    clearSelection();
  }



  // ================= VIEWER =================

  void _openViewer(AlbumMediaFile media, int index) {
    final files = mediaFiles;

    final onDelete = () async {
      setState(() {
        mediaFiles.removeAt(index);
      });
      await _saveMedia();
      Navigator.pop(context);
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          // ================= VIDEO =================
          if (media.type == AlbumMediaType.video) {
            return AlbumVideoViewer(
              file: media,
              onDelete: onDelete,
            );
          }

          // ================= IMAGE =================
          return AlbumImageViewer(
            file: media,
            onDelete: onDelete,
            onPrevious: index > 0
                ? () {
              Navigator.pop(context);
              _openViewer(files[index - 1], index - 1);
            }
                : null,
            onNext: index < files.length - 1
                ? () {
              Navigator.pop(context);
              _openViewer(files[index + 1], index + 1);
            }
                : null,
          );
        },
      ),
    );
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
