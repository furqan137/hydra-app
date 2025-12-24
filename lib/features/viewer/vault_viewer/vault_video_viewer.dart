import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../data/models/vault_file.dart';
import '../../vault/vault_controller.dart';
import 'vault_viewer_actions.dart';

class VaultVideoViewer extends StatefulWidget {
  final VaultFile file;

  const VaultVideoViewer({super.key, required this.file});

  @override
  State<VaultVideoViewer> createState() => _VaultVideoViewerState();
}

class _VaultVideoViewerState extends State<VaultVideoViewer> {
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

          Align(
            alignment: Alignment.bottomCenter,
            child: VaultViewerActions(
              onExport: () {},
              onMove: () {},
              onDelete: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
