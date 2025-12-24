import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class AlbumVideoThumbnailHelper {
  static Future<File?> generate(File videoFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final String? thumbPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 400,
        quality: 75,
        thumbnailPath: tempDir.path,
      );
      if (thumbPath == null) return null;
      final thumbFile = File(thumbPath);
      if (!thumbFile.existsSync() || await thumbFile.length() == 0) return null;
      return thumbFile;
    } catch (e) {
      return null;
    }
  }
}

