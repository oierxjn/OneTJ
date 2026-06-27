import 'package:flutter/material.dart';

import 'package:onetj/models/theme_preferences.dart';

/// 从 [ThemePreferences] 构建 [ColorScheme] 的纯函数工具类
///
/// 方案 C 实现：主色做 seed 生成全套 ColorScheme，辅色通过
/// [ColorScheme.fromSeed] 的 [secondary] 参数和谐化到主色的色相体系。
class ThemeColorSchemeBuilder {
  const ThemeColorSchemeBuilder._();

  /// 根据偏好和亮度构建 [ColorScheme]
  static ColorScheme build({
    required ThemePreferences preferences,
    required Brightness brightness,
  }) {
    final bool isLight = brightness == Brightness.light;
    final Color seedColor =
        isLight ? preferences.lightSeedColor : preferences.darkSeedColor;

    final Color secondaryColor;
    if (isLight) {
      secondaryColor = preferences.lightSecondaryColor;
    } else {
      secondaryColor = preferences.darkSecondaryColor;
    }

    return ColorScheme.fromSeed(
      seedColor: seedColor,
      secondary: secondaryColor,
      brightness: brightness,
    );
  }

  /// 构建亮色 ColorScheme
  static ColorScheme buildLight(ThemePreferences preferences) {
    return build(preferences: preferences, brightness: Brightness.light);
  }

  /// 构建暗色 ColorScheme
  static ColorScheme buildDark(ThemePreferences preferences) {
    return build(preferences: preferences, brightness: Brightness.dark);
  }
}
