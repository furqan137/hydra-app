class BackupManifest {
  final String appName;
  final String appVersion;
  final DateTime createdAt;
  final int vaultCount;
  final int albumCount;

  BackupManifest({
    required this.appName,
    required this.appVersion,
    required this.createdAt,
    required this.vaultCount,
    required this.albumCount,
  });

  Map<String, dynamic> toJson() => {
    'appName': appName,
    'appVersion': appVersion,
    'createdAt': createdAt.toIso8601String(),
    'vaultCount': vaultCount,
    'albumCount': albumCount,
  };

  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    return BackupManifest(
      appName: json['appName'],
      appVersion: json['appVersion'],
      createdAt: DateTime.parse(json['createdAt']),
      vaultCount: json['vaultCount'],
      albumCount: json['albumCount'],
    );
  }
}
