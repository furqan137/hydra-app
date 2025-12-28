import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../data/models/album_media_file.dart';

class AlbumVideoViewer extends StatefulWidget {
  final AlbumMediaFile file;
  final VoidCallback? onDelete;

  const AlbumVideoViewer({
    super.key,
    required this.file,
    this.onDelete,
  });

  @override
  State<AlbumVideoViewer> createState() => _AlbumVideoViewerState();
}

class _AlbumVideoViewerState extends State<AlbumVideoViewer> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file.file)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// ================= VIDEO =================
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : const CircularProgressIndicator(color: Colors.white),
          ),

          /// ================= TOP BAR =================
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          /// ================= BOTTOM CONTROLS =================
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _bottomControls(context),
            ),
          ),
        ],
      ),
    );
  }

  // ================= CONTROLS =================

  Widget _bottomControls(BuildContext context) {
    final duration = _controller.value.duration;
    final position = _controller.value.position;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.65),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ===== TIMELINE =====
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Color(0xFF0FB9B1),
              bufferedColor: Colors.white38,
              backgroundColor: Colors.white24,
            ),
          ),

          const SizedBox(height: 8),

          /// ===== TIME =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_format(position),
                  style: const TextStyle(color: Colors.white70)),
              Text(_format(duration),
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),

          const SizedBox(height: 14),

          /// ===== ACTIONS =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              /// PLAY / PAUSE
              IconButton(
                iconSize: 44,
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                    _isPlaying
                        ? _controller.play()
                        : _controller.pause();
                  });
                },
              ),

              /// DELETE
              IconButton(
                iconSize: 40,
                icon: const Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                ),
                onPressed: () async {
                  final ok = await _confirmDelete(context);
                  if (!ok) return;

                  widget.onDelete?.call();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF101B2B),
        title: const Text(
          'Delete video?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This video will be permanently deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ??
        false;
  }
}
