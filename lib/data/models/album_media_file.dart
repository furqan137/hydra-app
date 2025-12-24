import 'dart:io';

enum AlbumMediaType { image, video }

class AlbumMediaFile {
  final File file;
  final AlbumMediaType type;
  final DateTime importedAt;
  final String? thumbnailPath;
  final bool isEncrypted;

  AlbumMediaFile({
    required this.file,
    required this.type,
    required this.importedAt,
    this.thumbnailPath,
    this.isEncrypted = false,
  });

  AlbumMediaFile copyWith({
    File? file,
    AlbumMediaType? type,
    DateTime? importedAt,
    String? thumbnailPath,
    bool? isEncrypted,
  }) {
    return AlbumMediaFile(
      file: file ?? this.file,
      type: type ?? this.type,
      importedAt: importedAt ?? this.importedAt,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }

  Map<String, dynamic> toJson() => {
    'path': file.path,
    'type': type == AlbumMediaType.video ? 'video' : 'image',
    'importedAt': importedAt.toIso8601String(),
    'thumbnailPath': thumbnailPath,
    'isEncrypted': isEncrypted,
  };

  factory AlbumMediaFile.fromJson(Map<String, dynamic> item) {
    final type = item['type'] == 'video' ? AlbumMediaType.video : AlbumMediaType.image;
    return AlbumMediaFile(
      file: File(item['path']),
      type: type,
      importedAt: DateTime.parse(item['importedAt']),
      thumbnailPath: item['thumbnailPath'],
      isEncrypted: item['isEncrypted'] ?? false,
    );
  }
}
