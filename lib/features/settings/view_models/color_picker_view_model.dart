import 'package:flutter/material.dart';

import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/models/theme_preferences.dart';

/// 内置预设配色方案
const List<ThemePreferences> kPresetColorThemes = [
  ThemePreferences(
    name: 'Material 紫',
    lightSeedColor: Color(0xFF6750A4),
  ),
  ThemePreferences(
    name: 'Material 蓝',
    lightSeedColor: Color(0xFF2196F3),
  ),
  ThemePreferences(
    name: 'Material 绿',
    lightSeedColor: Color(0xFF4CAF50),
  ),
  ThemePreferences(
    name: 'Material 橙',
    lightSeedColor: Color(0xFFFF9800),
  ),
  ThemePreferences(
    name: 'Material 红',
    lightSeedColor: Color(0xFFF44336),
  ),
];

/// 取色器页面的 ViewModel
///
/// 进入页面时快照当前主题偏好，支持实时预览和撤销回退。
class ColorPickerViewModel extends ChangeNotifier {
  ColorPickerViewModel({
    ThemeChangeNotifier? themeChangeNotifier,
  }) : _themeChangeNotifier =
            themeChangeNotifier ?? appLocator<ThemeChangeNotifier>() {
    _snapshot = _themeChangeNotifier.preferences;
    _current = _snapshot;
  }

  final ThemeChangeNotifier _themeChangeNotifier;
  late ThemePreferences _snapshot;
  late ThemePreferences _current;

  /// 当前编辑中的偏好
  ThemePreferences get current => _current;

  /// 预设列表
  List<ThemePreferences> get presets => kPresetColorThemes;

  /// 选择预设方案
  void selectPreset(ThemePreferences preset) {
    _current = _current.copyWith(
      name: preset.name,
      lightSeedColor: preset.lightSeedColor,
      lightSecondaryColor: preset.lightSecondaryColor,
      clearLightSecondaryColor: preset.lightSecondaryColor == null,
      darkSeedColor: preset.darkSeedColor,
      clearDarkSeedColor: preset.darkSeedColor == null,
      darkSecondaryColor: preset.darkSecondaryColor,
      clearDarkSecondaryColor: preset.darkSecondaryColor == null,
    );
    _applyCurrent();
  }

  /// 更新亮色主色
  void updateLightSeedColor(Color color) {
    _current = _current.copyWith(lightSeedColor: color);
    _applyCurrent();
  }

  /// 更新亮色辅色
  void updateLightSecondaryColor(Color? color) {
    if (color == null) {
      _current = _current.copyWith(clearLightSecondaryColor: true);
    } else {
      _current = _current.copyWith(lightSecondaryColor: color);
    }
    _applyCurrent();
  }

  /// 更新暗色主色
  void updateDarkSeedColor(Color? color) {
    if (color == null) {
      _current = _current.copyWith(clearDarkSeedColor: true);
    } else {
      _current = _current.copyWith(darkSeedColor: color);
    }
    _applyCurrent();
  }

  /// 更新暗色辅色
  void updateDarkSecondaryColor(Color? color) {
    if (color == null) {
      _current = _current.copyWith(clearDarkSecondaryColor: true);
    } else {
      _current = _current.copyWith(darkSecondaryColor: color);
    }
    _applyCurrent();
  }

  /// 撤销：恢复到进入页面时的快照
  void undo() {
    _current = _snapshot;
    _applyCurrent();
  }

  /// 确认：保存当前方案到持久化存储
  ///
  /// 返回时自动调用，不需要手动调用。
  Future<void> confirm() async {
    await _themeChangeNotifier.updatePreferences(_current);
  }

  void _applyCurrent() {
    _themeChangeNotifier.updatePreferences(_current);
    notifyListeners();
  }
}