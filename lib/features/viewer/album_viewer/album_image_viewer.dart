import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/models/album_media_file.dart';
import 'album_viewer_actions.dart';

class AlbumImageViewer extends StatelessWidget {
  final AlbumMediaFile file;
  final VoidCallback? onDelete;
  final VoidCallback? onExport;
  final VoidCallback? onMove;
  const AlbumImageViewer({Key? key, required this.file, this.onDelete, this.onExport, this.onMove}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Image.file(
              file.file,
              fit: BoxFit.contain,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AlbumViewerActions(
              onExport: onExport ?? () {},
              onMove: onMove ?? () {},
              onDelete: onDelete ?? () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

