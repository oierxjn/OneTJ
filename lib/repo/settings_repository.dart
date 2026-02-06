import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';

class SettingsData {
  const SettingsData({
    required this.maxWeek,
  });

  /// 一个学期的最大周数
  final int maxWeek;

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    final Object? rawMaxWeek = json['maxWeek'];
    final int maxWeek = rawMaxWeek is int ? rawMaxWeek : int.parse(rawMaxWeek as String);
    return SettingsData(maxWeek: maxWeek);
  }

  Map<String, dynamic> toJson() {
    return {
      'maxWeek': maxWeek,
    };
  }
}

abstract class SettingsStorage {
  Future<SettingsData?> read();
  Future<void> save(SettingsData data);
  Future<void> clear();
}

class HiveSettingsStorage implements SettingsStorage {
  HiveSettingsStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'settings';
  static const String _key = 'payload';
  final HiveInterface _hive;

  Future<Box<String>> _openBox() async {
    if (_hive.isBoxOpen(_boxName)) {
      return _hive.box<String>(_boxName);
    }
    return _hive.openBox<String>(_boxName);
  }

  @override
  Future<SettingsData?> read() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return SettingsData.fromJson(data);
  }

  @override
  Future<void> save(SettingsData data) async {
    final Box<String> box = await _openBox();
    await box.put(_key, jsonEncode(data.toJson()));
  }

  @override
  Future<void> clear() async {
    final Box<String> box = await _openBox();
    await box.delete(_key);
  }
}

class InMemorySettingsStorage implements SettingsStorage {
  SettingsData? _cache;

  @override
  Future<SettingsData?> read() async => _cache;

  @override
  Future<void> save(SettingsData data) async {
    _cache = data;
  }

  @override
  Future<void> clear() async {
    _cache = null;
  }
}

class SettingsRepository {
  SettingsRepository._({required SettingsStorage storage})
      : _storage = storage,
        _controller = StreamController<SettingsData>.broadcast();

  static SettingsRepository? _instance;
  static const SettingsData _defaultSettings = SettingsData(maxWeek: 22);

  static SettingsRepository getInstance() {
    if (_instance != null) {
      return _instance!;
    }
    final SettingsRepository repo = SettingsRepository._(
      storage: HiveSettingsStorage(),
    );
    _instance = repo;
    return repo;
  }

  final SettingsStorage _storage;
  final StreamController<SettingsData> _controller;
  SettingsData? _cached;

  Stream<SettingsData> get stream => _controller.stream;

  /// 获取设置
  /// 
  /// [refreshFromStorage] 是否从存储中刷新数据
  /// 
  /// 返回一定不为null的设置数据。读取不到本地数据时返回默认值。
  Future<SettingsData> getSettings({bool refreshFromStorage = false}) async {
    if (!refreshFromStorage && _cached != null) {
      return _cached!;
    }
    _cached = await _storage.read();
    _cached ??= _defaultSettings;
    return _cached!;
  }

  Future<void> saveSettings(SettingsData data) async {
    await _storage.save(data);
    _cached = data;
    _controller.add(data);
  }

  Future<void> clearSettings() async {
    await _storage.clear();
    _cached = null;
    _controller.add(_defaultSettings);
  }
}
