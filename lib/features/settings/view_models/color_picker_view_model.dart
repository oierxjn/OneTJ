import 'package:flutter/material.dart';

import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/models/theme_preferences.dart';
import 'package:onetj/repo/color_preset_repository.dart';

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
/// 进入页面时快照当前主题偏好，支持实时预览、撤销回退、预设保存/删除。
class ColorPickerViewModel extends ChangeNotifier {
  ColorPickerViewModel({
    ThemeChangeNotifier? themeChangeNotifier,
    ColorPresetRepository? presetRepository,
  })  : _themeChangeNotifier =
            themeChangeNotifier ?? appLocator<ThemeChangeNotifier>(),
        _presetRepository =
            presetRepository ?? ColorPresetRepository.getInstance() {
    _snapshot = _themeChangeNotifier.preferences;
    _current = _snapshot;
    _presetName = '';
    _loadUserPresets();
  }

  final ThemeChangeNotifier _themeChangeNotifier;
  final ColorPresetRepository _presetRepository;

  late ThemePreferences _snapshot;
  late ThemePreferences _current;
  late String _presetName;
  List<ThemePreferences> _userPresets = [];

  /// 当前编辑中的偏好
  ThemePreferences get current => _current;

  /// 预设名称输入值
  String get presetName => _presetName;

  /// 合并后的预设列表（内置 + 用户）
  List<ThemePreferences> get presets => [
        ..._userPresets,
        ...kPresetColorThemes,
      ];

  /// 用户预设列表
  List<ThemePreferences> get userPresets =>
      List<ThemePreferences>.unmodifiable(_userPresets);

  /// 该预设是否为用户自定义预设（可删除）
  bool isUserPreset(int index) =>
      index < _userPresets.length;

  /// 判断预设是否与当前编辑的配色一致
  bool isPresetSelected(ThemePreferences preset) =>
      _current.hasSameColor(preset);

  void _generateDefaultName() {
    final int total = _userPresets.length;
    _presetName = '预设${total + 1}';
  }

  void _loadUserPresets() async {
    _userPresets = await _presetRepository.getPresets();
    _generateDefaultName();
    notifyListeners();
  }

  /// 更新预设名称
  void updatePresetName(String name) {
    _presetName = name;
    notifyListeners();
  }

  /// 选择预设方案
  void selectPreset(ThemePreferences preset) {
    _presetName = preset.name;
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

  /// 将当前方案保存为自定义预设
  Future<void> savePreset() async {
    final String name = _presetName.trim().isEmpty
        ? '预设${_userPresets.length + 1}'
        : _presetName.trim();
    final ThemePreferences preset = _current.copyWith(name: name);
    await _presetRepository.savePreset(preset);
    _userPresets.add(preset);
    _current = preset;
    _applyCurrent();
    notifyListeners();
  }

  /// 删除自定义预设
  Future<void> deletePreset(int index) async {
    if (index < 0 || index >= _userPresets.length) {
      return;
    }
    await _presetRepository.deletePreset(index);
    _userPresets.removeAt(index);
    notifyListeners();
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

  void _applyCurrent() {
    _themeChangeNotifier.updatePreferences(_current);
    notifyListeners();
  }
}