import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:onetj/models/theme_preferences.dart';

// ============================================================
// Storage 抽象层
// ============================================================

/// 主题偏好持久化存储的抽象接口
///
/// 提供 [HiveThemeStorage]（生产）和 [InMemoryThemeStorage]（测试）两种实现。
abstract class ThemeStorage {
  Future<ThemePreferences?> read();
  Future<void> save(ThemePreferences preferences);
  Future<void> clear();
}

/// 基于 Hive 的主题偏好存储
class HiveThemeStorage implements ThemeStorage {
  HiveThemeStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'theme';
  static const String _key = 'preferences';

  final HiveInterface _hive;

  Future<Box<String>> _openBox() async {
    if (_hive.isBoxOpen(_boxName)) {
      return _hive.box<String>(_boxName);
    }
    return _hive.openBox<String>(_boxName);
  }

  @override
  Future<ThemePreferences?> read() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return ThemePreferences.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(ThemePreferences preferences) async {
    final Box<String> box = await _openBox();
    await box.put(_key, preferences.toJsonString());
  }

  @override
  Future<void> clear() async {
    final Box<String> box = await _openBox();
    await box.delete(_key);
  }
}

/// 内存中的主题偏好存储（用于测试）
class InMemoryThemeStorage implements ThemeStorage {
  ThemePreferences? _cache;

  @override
  Future<ThemePreferences?> read() async => _cache;

  @override
  Future<void> save(ThemePreferences preferences) async {
    _cache = preferences;
  }

  @override
  Future<void> clear() async {
    _cache = null;
  }
}

// ============================================================
// Repository
// ============================================================

/// 主题偏好持久化存储
///
/// 继承 [ChangeNotifier]，当主题偏好变更时通知监听者。
class ThemeRepository extends ChangeNotifier {
  ThemeRepository._({
    required ThemeStorage storage,
  }) : _storage = storage {
    _preferences = ThemePreferences.defaultPreferences;
  }

  static ThemeRepository? _instance;

  final ThemeStorage _storage;
  late ThemePreferences _preferences;
  bool _initialized = false;

  /// 当前主题偏好
  ThemePreferences get preferences => _preferences;

  /// 是否已从存储中加载完成
  bool get initialized => _initialized;

  /// 获取单例
  static ThemeRepository getInstance() {
    if (_instance != null) {
      return _instance!;
    }
    _instance = ThemeRepository._(storage: HiveThemeStorage());
    return _instance!;
  }

  /// 重置单例（用于测试）
  static void resetForTesting({ThemeStorage? storage}) {
    _instance = ThemeRepository._(
      storage: storage ?? InMemoryThemeStorage(),
    );
  }

  /// 从 Hive 加载主题偏好
  ///
  /// 首次调用会读取持久化数据。
  /// 如果存储中没有数据，使用默认值。
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    final ThemePreferences? stored = await _storage.read();
    if (stored != null) {
      _preferences = stored;
    }
    _initialized = true;
    notifyListeners();
  }

  /// 保存主题偏好
  ///
  /// 写入存储并通知监听者。
  Future<void> save(ThemePreferences preferences) async {
    if (_preferences == preferences) {
      return;
    }
    _preferences = preferences;
    await _storage.save(preferences);
    notifyListeners();
  }

  /// 重置为默认主题偏好
  Future<void> reset() async {
    await save(ThemePreferences.defaultPreferences);
  }

  /// 更新主题模式（system / light / dark）
  Future<void> setThemeMode(ThemeMode mode) async {
    await save(_preferences.copyWith(themeMode: mode));
  }

  /// 更新亮色主色
  Future<void> setLightSeedColor(Color color) async {
    await save(_preferences.copyWith(lightSeedColor: color));
  }

  /// 更新亮色辅色
  Future<void> setLightSecondaryColor(Color color) async {
    await save(_preferences.copyWith(lightSecondaryColor: color));
  }

  /// 更新暗色主色
  Future<void> setDarkSeedColor(Color color) async {
    await save(_preferences.copyWith(darkSeedColor: color));
  }

  /// 更新暗色辅色
  Future<void> setDarkSecondaryColor(Color color) async {
    await save(_preferences.copyWith(darkSecondaryColor: color));
  }
}
