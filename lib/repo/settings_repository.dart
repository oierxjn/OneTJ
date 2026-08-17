import 'dart:async';
import 'dart:convert';

import 'package:onetj/models/launch_wallpaper_ref.dart';
import 'package:onetj/models/settings_data.dart';
import 'package:onetj/models/settings_defaults.dart';
import 'package:hive/hive.dart';

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
  SettingsRepository({SettingsStorage? storage})
      : _storage = storage ?? HiveSettingsStorage(),
        _controller = StreamController<SettingsData>.broadcast();

  static final SettingsData _defaultSettings = SettingsData(
    maxWeek: kDefaultMaxWeek,
    timeSlotRanges: kDefaultTimeSlotRanges,
    dashboardUpcomingMode: kDefaultDashboardUpcomingMode,
    dashboardUpcomingCount: kDefaultDashboardUpcomingCount,
    userCollectionFields: kDefaultUserCollectionFields,
    selectedLaunchWallpaperRef: LaunchWallpaperRef.defaultValue,
  );

  final SettingsStorage _storage;
  final StreamController<SettingsData> _controller;
  SettingsData? _cached;

  Stream<SettingsData> get stream => _controller.stream;

  SettingsData peekCachedOrDefault() {
    return _cached ?? _defaultSettings;
  }

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
