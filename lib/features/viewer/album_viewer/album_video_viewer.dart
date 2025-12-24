import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../data/models/album_media_file.dart';
import 'album_viewer_actions.dart';

class AlbumVideoViewer extends StatefulWidget {
  final AlbumMediaFile file;
  final VoidCallback? onDelete;
  final VoidCallback? onExport;
  final VoidCallback? onMove;
  const AlbumVideoViewer({Key? key, required this.file, this.onDelete, this.onExport, this.onMove}) : super(key: key);

  @override
  State<AlbumVideoViewer> createState() => _AlbumVideoViewerState();
}

class _AlbumVideoViewerState extends State<AlbumVideoViewer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file.file)
      ..initialize().then((_) => setState(() {}))
      ..play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : const CircularProgressIndicator(),
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
              onExport: widget.onExport ?? () {},
              onMove: widget.onMove ?? () {},
              onDelete: widget.onDelete ?? () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

