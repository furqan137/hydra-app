import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class VideoThumbnailHelper {
  static Future<File?> generate(File videoFile, {bool isEncrypted = false, Future<File?> Function()? decrypt}) async {
    File? tempDecrypted;
    String videoPath = videoFile.path;
    if (isEncrypted && decrypt != null) {
      tempDecrypted = await decrypt();
      if (tempDecrypted == null) {
        debugPrint('[Vault] Decryption failed for thumbnail.');
        return null;
      }
      videoPath = tempDecrypted.path;
      debugPrint('[Vault] Using decrypted temp file for thumbnail: $videoPath');
    }
    try {
      final tempDir = await getTemporaryDirectory();
      final String? thumbPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 400,
        quality: 75,
        thumbnailPath: tempDir.path,
      );
      if (tempDecrypted != null) {
        await tempDecrypted.delete();
        debugPrint('[Vault] Deleted temp decrypted video: $videoPath');
      }
      if (thumbPath == null) return null;
      final thumbFile = File(thumbPath);
      debugPrint('[Vault] Thumbnail generated: $thumbPath, size: ${await thumbFile.length()}');
      if (!thumbFile.existsSync() || await thumbFile.length() == 0) return null;
      return thumbFile;
    } catch (e) {
      debugPrint('[Vault] Thumbnail generation error: $e');
      if (tempDecrypted != null) await tempDecrypted.delete();
      return null;
    }
  }
}
