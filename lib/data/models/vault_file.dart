import 'dart:io';

enum VaultFileType { image, video }

class VaultFile {
  final File file;
  final VaultFileType type;
  final DateTime importedAt;
  final String? thumbnailPath;
  final bool isEncrypted;

  VaultFile({
    required this.file,
    required this.type,
    required this.importedAt,
    this.thumbnailPath,
    this.isEncrypted = false,
  });

  VaultFile copyWith({
    File? file,
    VaultFileType? type,
    DateTime? importedAt,
    String? thumbnailPath,
    bool? isEncrypted,
  }) {
    return VaultFile(
      file: file ?? this.file,
      type: type ?? this.type,
      importedAt: importedAt ?? this.importedAt,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }

  Map<String, dynamic> toJson() => {
    'file': file.path,
    'type': type.toString().split('.').last,
    'importedAt': importedAt.toIso8601String(),
    'thumbnailPath': thumbnailPath,
    'isEncrypted': isEncrypted,
  };

  factory VaultFile.fromJson(Map<String, dynamic> json) => VaultFile(
    file: File(json['file']),
    type: json['type'] == 'video' ? VaultFileType.video : VaultFileType.image,
    importedAt: DateTime.parse(json['importedAt']),
    thumbnailPath: json['thumbnailPath'],
    isEncrypted: json['isEncrypted'] ?? false,
  );
}
