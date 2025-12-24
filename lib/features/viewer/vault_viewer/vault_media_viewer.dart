import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../vault/vault_controller.dart';
import '../../../data/models/vault_file.dart';
import 'vault_image_viewer.dart';
import 'vault_video_viewer.dart';

class VaultMediaViewer extends StatelessWidget {
  final VaultFile file;

  const VaultMediaViewer({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return file.type == VaultFileType.image
        ? VaultImageViewer(file: file)
        : VaultVideoViewer(file: file);
  }
}
