import 'package:onetj/models/settings_defaults.dart';

class LaunchWallpaperRef {
  const LaunchWallpaperRef({
    required this.type,
    required this.id,
  });

  static const int typeBuiltin = 0;
  static const int typeLocal = 1;
  static const int typeNetwork = 2;

  static const LaunchWallpaperRef defaultValue = LaunchWallpaperRef(
    type: typeBuiltin,
    id: kDefaultLaunchWallpaperId,
  );

  final int type;
  final String id;

  bool get isBuiltin => type == typeBuiltin;
  bool get isLocal => type == typeLocal;
  bool get isNetwork => type == typeNetwork;

  factory LaunchWallpaperRef.fromJson(Object? json) {
    if (json is! Map) {
      return defaultValue;
    }
    final Object? rawType = json['type'];
    final Object? rawId = json['id'];
    if (rawType is! int || rawId is! String || rawId.isEmpty) {
      return defaultValue;
    }
    if (rawType != typeBuiltin &&
        rawType != typeLocal &&
        rawType != typeNetwork) {
      return defaultValue;
    }
    return LaunchWallpaperRef(type: rawType, id: rawId);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'id': id,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is LaunchWallpaperRef && other.type == type && other.id == id;
  }

  @override
  int get hashCode => Object.hash(type, id);
}
