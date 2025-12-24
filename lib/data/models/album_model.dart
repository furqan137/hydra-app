import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Album {
  final String id;
  final String name;
  final bool isPrivate;
  final int fileCount;
  final String? coverImage;

  const Album({
    required this.id,
    required this.name,
    this.isPrivate = false,
    this.fileCount = 0,
    this.coverImage,
  });

  // ================= COPY =================

  Album copyWith({
    String? id,
    String? name,
    bool? isPrivate,
    int? fileCount,
    String? coverImage,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      isPrivate: isPrivate ?? this.isPrivate,
      fileCount: fileCount ?? this.fileCount,
      coverImage: coverImage ?? this.coverImage,
    );
  }

  // ================= JSON =================

  factory Album.fromJson(Map<String, dynamic> json) => Album(
    id: json['id'] as String,
    name: json['name'] as String,
    isPrivate: json['isPrivate'] ?? false,
    fileCount: json['fileCount'] ?? 0,
    coverImage: json['coverImage'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isPrivate': isPrivate,
    'fileCount': fileCount,
    'coverImage': coverImage,
  };

  // ================= HELPERS =================

  bool get hasCover => coverImage != null && coverImage!.isNotEmpty;

  // ================= FILE COUNT =================

  static Future<int> getAlbumFileCount(String albumId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'album_media_$albumId';
    final jsonStr = prefs.getString(key);

    if (jsonStr == null) return 0;

    final List decoded = jsonDecode(jsonStr);
    return decoded.length;
  }
}
