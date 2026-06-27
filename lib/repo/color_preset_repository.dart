import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:onetj/models/theme_preferences.dart';

// ============================================================
// Storage 抽象层
// ============================================================

/// 用户自定义预设持久化存储的抽象接口
abstract class ColorPresetStorage {
  Future<List<ThemePreferences>> read();
  Future<void> save(List<ThemePreferences> presets);
  Future<void> clear();
}

/// 基于 Hive 的用户预设存储
///
/// 与 [ThemeRepository] 共用 `'theme'` box，使用 `'presets'` key。
class HiveColorPresetStorage implements ColorPresetStorage {
  HiveColorPresetStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'theme';
  static const String _key = 'presets';

  final HiveInterface _hive;

  Future<Box<String>> _openBox() async {
    if (_hive.isBoxOpen(_boxName)) {
      return _hive.box<String>(_boxName);
    }
    return _hive.openBox<String>(_boxName);
  }

  @override
  Future<List<ThemePreferences>> read() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_key);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(ThemePreferences.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> save(List<ThemePreferences> presets) async {
    final Box<String> box = await _openBox();
    final String json = jsonEncode(
      presets.map((p) => p.toJson()).toList(),
    );
    await box.put(_key, json);
  }

  @override
  Future<void> clear() async {
    final Box<String> box = await _openBox();
    await box.delete(_key);
  }
}

/// 内存中的用户预设存储（用于测试）
class InMemoryColorPresetStorage implements ColorPresetStorage {
  List<ThemePreferences>? _cache;

  @override
  Future<List<ThemePreferences>> read() async => _cache?.toList() ?? [];

  @override
  Future<void> save(List<ThemePreferences> presets) async {
    _cache = presets.toList();
  }

  @override
  Future<void> clear() async {
    _cache = null;
  }
}

// ============================================================
// Repository
// ============================================================

/// 用户自定义预设仓库
class ColorPresetRepository {
  ColorPresetRepository._({
    required ColorPresetStorage storage,
  }) : _storage = storage;

  static ColorPresetRepository? _instance;

  final ColorPresetStorage _storage;

  static ColorPresetRepository getInstance() {
    if (_instance != null) {
      return _instance!;
    }
    _instance = ColorPresetRepository._(storage: HiveColorPresetStorage());
    return _instance!;
  }

  static void resetForTesting({ColorPresetStorage? storage}) {
    _instance = ColorPresetRepository._(
      storage: storage ?? InMemoryColorPresetStorage(),
    );
  }

  Future<List<ThemePreferences>> getPresets() async {
    return _storage.read();
  }

  Future<void> savePreset(ThemePreferences preset) async {
    final List<ThemePreferences> presets = await _storage.read();
    presets.add(preset);
    await _storage.save(presets);
  }

  Future<void> deletePreset(int index) async {
    final List<ThemePreferences> presets = await _storage.read();
    if (index < 0 || index >= presets.length) {
      return;
    }
    presets.removeAt(index);
    await _storage.save(presets);
  }
}
