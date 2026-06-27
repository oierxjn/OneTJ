import 'package:flutter/material.dart';

import 'package:onetj/app/theme/theme_color_scheme_builder.dart';
import 'package:onetj/models/theme_preferences.dart';
import 'package:onetj/repo/theme_repository.dart';

/// 主题变更通知器
///
/// 组合 [ThemeRepository] 和 [ThemeColorSchemeBuilder]，
/// 对外暴露当前亮色/暗色 [ColorScheme] 和 [ThemeMode]。
///
/// 供 [ListenableBuilder] 在 [MaterialApp] 层级使用。
class ThemeChangeNotifier extends ChangeNotifier {
  ThemeChangeNotifier({
    ThemeRepository? repository,
  }) : _repository = repository ?? ThemeRepository.getInstance() {
    // 监听 ThemeRepository 的变更，自动重建 ColorScheme
    _repository.addListener(_onPreferencesChanged);
    // 从当前缓存构建初始 ColorScheme
    final ThemePreferences prefs = _repository.preferences;
    _lightColorScheme = ThemeColorSchemeBuilder.buildLight(prefs);
    _darkColorScheme = ThemeColorSchemeBuilder.buildDark(prefs);
  }

  final ThemeRepository _repository;
  late ColorScheme _lightColorScheme;
  late ColorScheme _darkColorScheme;

  /// 当前亮色 ColorScheme
  ColorScheme get lightColorScheme => _lightColorScheme;

  /// 当前暗色 ColorScheme
  ColorScheme get darkColorScheme => _darkColorScheme;

  /// 当前主题模式
  ThemeMode get themeMode => _repository.preferences.themeMode;

  /// 当前主题偏好
  ThemePreferences get preferences => _repository.preferences;

  /// 是否已从存储中加载完成
  bool get initialized => _repository.initialized;

  /// 初始化：从 Hive 加载主题偏好
  Future<void> initialize() async {
    await _repository.initialize();
    // _onPreferencesChanged 已在 addListener 中处理
  }

  /// 更新主题偏好
  ///
  /// 委托给 [ThemeRepository.save]，ColorScheme 会自动重建。
  Future<void> updatePreferences(ThemePreferences preferences) async {
    await _repository.save(preferences);
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    await _repository.setThemeMode(mode);
  }

  /// 设置亮色主色
  Future<void> setLightSeedColor(Color color) async {
    await _repository.setLightSeedColor(color);
  }

  /// 设置亮色辅色
  Future<void> setLightSecondaryColor(Color color) async {
    await _repository.setLightSecondaryColor(color);
  }

  /// 设置暗色主色
  Future<void> setDarkSeedColor(Color color) async {
    await _repository.setDarkSeedColor(color);
  }

  /// 设置暗色辅色
  Future<void> setDarkSecondaryColor(Color color) async {
    await _repository.setDarkSecondaryColor(color);
  }

  /// 重置为默认主题
  Future<void> reset() async {
    await _repository.reset();
  }

  void _onPreferencesChanged() {
    final ThemePreferences prefs = _repository.preferences;
    _lightColorScheme = ThemeColorSchemeBuilder.buildLight(prefs);
    _darkColorScheme = ThemeColorSchemeBuilder.buildDark(prefs);
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.removeListener(_onPreferencesChanged);
    super.dispose();
  }
}