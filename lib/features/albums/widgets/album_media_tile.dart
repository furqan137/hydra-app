import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/models/album_media_file.dart';


class AlbumMediaTile extends StatelessWidget {
  final AlbumMediaFile mediaFile;
  final VoidCallback? onTap;

  const AlbumMediaTile({Key? key, required this.mediaFile, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isVideo = mediaFile.type == AlbumMediaType.video;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isVideo
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      if (mediaFile.thumbnailPath != null && File(mediaFile.thumbnailPath!).existsSync())
                        Image.file(File(mediaFile.thumbnailPath!), fit: BoxFit.cover)
                      else
                        Container(color: Colors.black45),
                      const Center(
                        child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 40),
                      ),
                    ],
                  )
                : Image.file(
                    mediaFile.file,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black),
                  ),
          ),
        ],
      ),
    );
  }
}
