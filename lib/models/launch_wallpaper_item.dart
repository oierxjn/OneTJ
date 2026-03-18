class LaunchWallpaperItem {
  const LaunchWallpaperItem({
    required this.id,
    required this.displayName,
    required this.fileName,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String displayName;
  final String fileName;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory LaunchWallpaperItem.fromJson(Map<String, dynamic> json) {
    return LaunchWallpaperItem(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      fileName: json['fileName'] as String,
      source: json['source'] as String? ?? 'gallery',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'displayName': displayName,
      'fileName': fileName,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  LaunchWallpaperItem copyWith({
    String? displayName,
    String? fileName,
    String? source,
    DateTime? updatedAt,
  }) {
    return LaunchWallpaperItem(
      id: id,
      displayName: displayName ?? this.displayName,
      fileName: fileName ?? this.fileName,
      source: source ?? this.source,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
