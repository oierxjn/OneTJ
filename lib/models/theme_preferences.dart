import 'dart:convert';

import 'package:flutter/material.dart';

/// 用户主题偏好设置
///
/// 包含主色、辅色、主题模式等配置，支持 JSON 序列化以持久化到 Hive。
class ThemePreferences {
  const ThemePreferences({
    this.name = '',
    required this.lightSeedColor,
    this.lightSecondaryColor,
    this.darkSeedColor,
    this.darkSecondaryColor,
    this.themeMode = ThemeMode.system,
  });

  /// 方案名称
  final String name;

  /// 亮色模式主色
  final Color lightSeedColor;

  /// 亮色模式辅色（可选，null 表示不启用辅色定制）
  final Color? lightSecondaryColor;

  /// 暗色模式主色（可选，null 表示沿用亮色主色）
  final Color? darkSeedColor;

  /// 暗色模式辅色（可选，null 表示沿用亮色辅色）
  final Color? darkSecondaryColor;

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
  // 派生属性
  // ============================================================

  /// 暗色模式实际使用的主色
  Color get effectiveDarkSeedColor => darkSeedColor ?? lightSeedColor;

  /// 暗色模式实际使用的辅色
  Color? get effectiveDarkSecondaryColor =>
      darkSecondaryColor ?? lightSecondaryColor;

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
      lightSecondaryColor: _nullableColorFromJson(json['lightSecondaryColor']),
      darkSeedColor: _nullableColorFromJson(json['darkSeedColor']),
      darkSecondaryColor: _nullableColorFromJson(json['darkSecondaryColor']),
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
      'lightSeedColor': _colorToInt(lightSeedColor),
      'lightSecondaryColor':
          lightSecondaryColor != null ? _colorToInt(lightSecondaryColor!) : null,
      'darkSeedColor':
          darkSeedColor != null ? _colorToInt(darkSeedColor!) : null,
      'darkSecondaryColor':
          darkSecondaryColor != null ? _colorToInt(darkSecondaryColor!) : null,
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
    Color? lightSeedColor,
    Color? lightSecondaryColor,
    Color? darkSeedColor,
    Color? darkSecondaryColor,
    ThemeMode? themeMode,
    /// 传 true 可将 lightSecondaryColor 置为 null
    bool clearLightSecondaryColor = false,
    /// 传 true 可将 darkSeedColor 置为 null
    bool clearDarkSeedColor = false,
    /// 传 true 可将 darkSecondaryColor 置为 null
    bool clearDarkSecondaryColor = false,
  }) {
    return ThemePreferences(
      name: name ?? this.name,
      lightSeedColor: lightSeedColor ?? this.lightSeedColor,
      lightSecondaryColor: clearLightSecondaryColor
          ? null
          : (lightSecondaryColor ?? this.lightSecondaryColor),
      darkSeedColor:
          clearDarkSeedColor ? null : (darkSeedColor ?? this.darkSeedColor),
      darkSecondaryColor: clearDarkSecondaryColor
          ? null
          : (darkSecondaryColor ?? this.darkSecondaryColor),
      themeMode: themeMode ?? this.themeMode,
    );
  }

  // ============================================================
  // 相等性
  // ============================================================

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

  // 忽略 Color.value 的弃用警告，因为 toARGB32() 在此 SDK 版本中不可用
  // ignore: deprecated_member_use
  static int _colorToInt(Color color) => color.value;

  static Color _colorFromJson(dynamic value, Color fallback) {
    if (value is int) {
      return Color(value);
    }
    return fallback;
  }

  static Color? _nullableColorFromJson(dynamic value) {
    if (value is int) {
      return Color(value);
    }
    return null;
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