import 'dart:async';
import 'dart:convert';

import 'package:onetj/app/exception/app_exception.dart';
import 'package:hive/hive.dart';
import 'package:onetj/models/time_slot.dart';

class SettingsData {
  const SettingsData({
    required this.maxWeek,
    required this.timeSlotStartMinutes,
  });

  /// 一个学期的最大周数
  final int maxWeek;
  final List<int> timeSlotStartMinutes;

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    final Object? rawMaxWeek = json['maxWeek'];
    final int maxWeek = _validateMaxWeek(rawMaxWeek);
    
    final Object? rawTimeSlotStartMinutes = json['timeSlotStartMinutes'];
    final List<int> timeSlotStartMinutes = _validateTimeSlotStartMinutes(rawTimeSlotStartMinutes);
    return SettingsData(
      maxWeek: maxWeek,
      timeSlotStartMinutes: timeSlotStartMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxWeek': maxWeek,
      'timeSlotStartMinutes': List<int>.from(timeSlotStartMinutes),
    };
  }

  void validate() {
    _validateMaxWeek(maxWeek);
    _validateTimeSlotStartMinutes(timeSlotStartMinutes);
  }

  static int _validateMaxWeek(Object? value) {
    if (value is! int) {
      throw SettingsResolveException(message: 'maxWeek must be int');
    }
    if (value < 1 || value > 52) {
      throw SettingsResolveException(message: 'maxWeek out of range');
    }
    return value;
  }

  /// 验证时间槽开始时间是否合法
  /// 
  /// 时间槽为列表，开始时间不为空，必须在 00:00 到 23:59 之间，且必须严格递增
  static List<int> _validateTimeSlotStartMinutes(Object? values) {
    if (values is! List) {
      throw SettingsResolveException(message: 'timeSlotStartMinutes must be a list');
    }
    final List<int> timeSlotStartMinutes = values.map<int>((item) {
          if (item is! int) {
            throw SettingsResolveException(message: 'timeSlotStartMinutes item must be int');
          }
          return item;
        })
        .toList(growable: false);
    if (timeSlotStartMinutes.isEmpty) {
      throw SettingsResolveException(message: 'timeSlotStartMinutes must not be empty');
    }
    for (int i = 0; i < timeSlotStartMinutes.length; i += 1) {
      final int minute = timeSlotStartMinutes[i];
      // 时间槽开始时间必须在 00:00 到 23:59 之间
      if (minute < 0 || minute > 24 * 60 - 1) {
        throw SettingsResolveException(message: 'timeSlotStartMinutes item out of range');
      }
      // 时间槽开始时间必须严格递增
      if (i > 0 && minute <= timeSlotStartMinutes[i - 1]) {
        throw SettingsResolveException(message: 'timeSlotStartMinutes must be strictly increasing');
      }
    }
    return timeSlotStartMinutes;
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
  static const SettingsData _defaultSettings = SettingsData(
    maxWeek: 22,
    timeSlotStartMinutes: TimeSlot.defaultStartMinutes,
  );

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
    data.validate();
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
