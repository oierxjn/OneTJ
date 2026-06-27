import 'dart:convert';

import 'package:flutter/material.dart';

/// 用户主题偏好设置
///
/// 所有颜色字段均为非空
class ThemePreferences {
  const ThemePreferences({
    this.name = '',
    required this.lightSeedColor,
    this.lightSecondaryColor = kDefaultSeedColor,
    this.darkSeedColor = kDefaultSeedColor,
    this.darkSecondaryColor = kDefaultSeedColor,
    this.themeMode = ThemeMode.system,
  });

  /// 方案名称
  final String name;

  /// 亮色模式主色
  final Color lightSeedColor;

  /// 亮色模式辅色
  final Color lightSecondaryColor;

  /// 暗色模式主色
  final Color darkSeedColor;

  /// 暗色模式辅色
  final Color darkSecondaryColor;

  /// 主题模式
  final ThemeMode themeMode;

  // ============================================================
  // 默认值
  // ============================================================

  /// 默认主色 —— 与项目现有紫色一致
  static const Color kDefaultSeedColor = Color(0xFFE65AFF);

  /// 默认主题偏好
  static const ThemePreferences defaultPreferences = ThemePreferences(
    lightSeedColor: kDefaultSeedColor,
  );

  // ============================================================
  // JSON 序列化
  // ============================================================

  /// 从 JSON Map 反序列化
  factory ThemePreferences.fromJson(Map<String, dynamic> json) {
    return ThemePreferences(
      name: json['name'] as String? ?? '',
      lightSeedColor: _colorFromJson(
        json['lightSeedColor'],
        kDefaultSeedColor,
      ),
      lightSecondaryColor: _colorFromJson(
        json['lightSecondaryColor'],
        kDefaultSeedColor,
      ),
      darkSeedColor: _colorFromJson(
        json['darkSeedColor'],
        kDefaultSeedColor,
      ),
      darkSecondaryColor: _colorFromJson(
        json['darkSecondaryColor'],
        kDefaultSeedColor,
      ),
      themeMode: _themeModeFromJson(
        json['themeMode'],
        ThemeMode.system,
      ),
    );
  }

  /// 序列化为 JSON Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lightSeedColor': colorToInt(lightSeedColor),
      'lightSecondaryColor': colorToInt(lightSecondaryColor),
      'darkSeedColor': colorToInt(darkSeedColor),
      'darkSecondaryColor': colorToInt(darkSecondaryColor),
      'themeMode': _themeModeToString(themeMode),
    };
  }

  /// 从 JSON 字符串反序列化
  factory ThemePreferences.fromJsonString(String jsonString) {
    final Map<String, dynamic> map =
        jsonDecode(jsonString) as Map<String, dynamic>;
    return ThemePreferences.fromJson(map);
  }

  /// 序列化为 JSON 字符串
  String toJsonString() => jsonEncode(toJson());

  // ============================================================
  // copyWith
  // ============================================================

  ThemePreferences copyWith({
    String? name,
    Object? lightSeedColor,
    Object? lightSecondaryColor,
    Object? darkSeedColor,
    Object? darkSecondaryColor,
    ThemeMode? themeMode,
  }) {
    return ThemePreferences(
      name: name ?? this.name,
      lightSeedColor:
          lightSeedColor is Color ? lightSeedColor : this.lightSeedColor,
      lightSecondaryColor: lightSecondaryColor is Color
          ? lightSecondaryColor
          : this.lightSecondaryColor,
      darkSeedColor:
          darkSeedColor is Color ? darkSeedColor : this.darkSeedColor,
      darkSecondaryColor: darkSecondaryColor is Color
          ? darkSecondaryColor
          : this.darkSecondaryColor,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  // ============================================================
  // 相等性
  // ============================================================

  /// 仅比较颜色属性是否相同（忽略名称与主题模式）
  bool hasSameColor(ThemePreferences other) {
    return lightSeedColor == other.lightSeedColor &&
        lightSecondaryColor == other.lightSecondaryColor &&
        darkSeedColor == other.darkSeedColor &&
        darkSecondaryColor == other.darkSecondaryColor;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemePreferences &&
        other.name == name &&
        other.lightSeedColor == lightSeedColor &&
        other.lightSecondaryColor == lightSecondaryColor &&
        other.darkSeedColor == darkSeedColor &&
        other.darkSecondaryColor == darkSecondaryColor &&
        other.themeMode == themeMode;
  }

  @override
  int get hashCode => Object.hash(
        name,
        lightSeedColor,
        lightSecondaryColor,
        darkSeedColor,
        darkSecondaryColor,
        themeMode,
      );

  @override
  String toString() {
    return 'ThemePreferences('
        'name=$name, '
        'lightSeedColor=$lightSeedColor, '
        'lightSecondaryColor=$lightSecondaryColor, '
        'darkSeedColor=$darkSeedColor, '
        'darkSecondaryColor=$darkSecondaryColor, '
        'themeMode=$themeMode)';
  }

  // ============================================================
  // 内部辅助方法
  // ============================================================

  static int colorToInt(Color color) {
    return ((color.a * 255).round() << 24) |
        ((color.r * 255).round() << 16) |
        ((color.g * 255).round() << 8) |
        (color.b * 255).round();
  }

  static Color _colorFromJson(dynamic value, Color fallback) {
    if (value is int) {
      return Color(value);
    }
    return fallback;
  }

  static ThemeMode _themeModeFromJson(dynamic value, ThemeMode fallback) {
    if (value is String) {
      return _themeModeFromString(value);
    }
    return fallback;
  }

  static ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
    }
    return ThemeMode.system;
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
