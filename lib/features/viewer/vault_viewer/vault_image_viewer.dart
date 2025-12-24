import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/models/vault_file.dart';
import 'vault_viewer_actions.dart';
import '../../vault/vault_controller.dart';

class VaultImageViewer extends StatelessWidget {
  final VaultFile file;

  const VaultImageViewer({super.key, required this.file});

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

          // TOP BAR
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // BOTTOM ACTIONS
          Align(
            alignment: Alignment.bottomCenter,
            child: VaultViewerActions(
              onExport: () {},
              onMove: () {},
              onDelete: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
