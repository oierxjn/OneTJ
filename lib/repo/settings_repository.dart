import 'dart:async';
import 'dart:convert';

import 'package:onetj/models/dashboard_upcoming_mode.dart';
import 'package:onetj/models/settings_defaults.dart';
import 'package:onetj/models/settings_validation.dart' as settings_validation;
import 'package:onetj/models/time_period_range.dart';
import 'package:hive/hive.dart';
import 'package:onetj/app/exception/app_exception.dart';

class SettingsData {
  const SettingsData({
    required this.maxWeek,
    required this.timeSlotRanges,
    required this.dashboardUpcomingMode,
    required this.dashboardUpcomingCount,
  });

  final int maxWeek;
  final List<TimePeriodRangeData> timeSlotRanges;
  final DashboardUpcomingMode dashboardUpcomingMode;
  final int dashboardUpcomingCount;

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    final int maxWeek = _readMaxWeekWithFallback(json);
    final List<TimePeriodRangeData> timeSlotRanges =
        _readTimeSlotRangesWithFallback(json);
    return SettingsData(
      maxWeek: maxWeek,
      timeSlotRanges: timeSlotRanges,
      dashboardUpcomingMode: _readDashboardUpcomingModeWithFallback(json),
      dashboardUpcomingCount: _readDashboardUpcomingCountWithFallback(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxWeek': maxWeek,
      'timeSlotRanges': timeSlotRanges.map((item) => item.toJson()).toList(),
      'dashboardUpcomingMode': dashboardUpcomingMode.jsonValue,
      'dashboardUpcomingCount': dashboardUpcomingCount,
    };
  }

  static int _readMaxWeekWithFallback(Map<String, dynamic> json) {
    if (!json.containsKey('maxWeek')) {
      return kDefaultMaxWeek;
    }
    try {
      return _parseMaxWeek(json['maxWeek']);
    } on SettingsResolveException {
      return kDefaultMaxWeek;
    }
  }

  static List<TimePeriodRangeData> _readTimeSlotRangesWithFallback(
    Map<String, dynamic> json,
  ) {
    if (json.containsKey('timeSlotRanges')) {
      try {
        return _parseTimeSlotRanges(json['timeSlotRanges']);
      } on SettingsResolveException {
        return _defaultTimeSlotRanges();
      } on SettingsValidationException {
        return _defaultTimeSlotRanges();
      }
    }
    if (json.containsKey('timeSlotStartMinutes')) {
      try {
        final List<int> starts = _parseTimeSlotStartMinutes(
          json['timeSlotStartMinutes'],
        );
        return _deriveRangesFromStarts(starts);
      } on SettingsResolveException {
        return _defaultTimeSlotRanges();
      } on SettingsValidationException {
        return _defaultTimeSlotRanges();
      }
    }
    return _defaultTimeSlotRanges();
  }

  static DashboardUpcomingMode _readDashboardUpcomingModeWithFallback(
    Map<String, dynamic> json,
  ) {
    if (!json.containsKey('dashboardUpcomingMode')) {
      return kDefaultDashboardUpcomingMode;
    }
    return DashboardUpcomingMode.fromJsonValue(
      json['dashboardUpcomingMode'],
      defaultValue: kDefaultDashboardUpcomingMode,
    );
  }

  static int _readDashboardUpcomingCountWithFallback(
    Map<String, dynamic> json,
  ) {
    if (!json.containsKey('dashboardUpcomingCount')) {
      return kDefaultDashboardUpcomingCount;
    }
    final Object? value = json['dashboardUpcomingCount'];
    if (value is! int) {
      return kDefaultDashboardUpcomingCount;
    }
    if (value < kMinDashboardUpcomingCount ||
        value > kMaxDashboardUpcomingCount) {
      return kDefaultDashboardUpcomingCount;
    }
    return value;
  }

  static int _parseMaxWeek(Object? value) {
    if (value is! int) {
      throw SettingsResolveException(message: 'maxWeek must be int');
    }
    return value;
  }

  static List<int> _parseTimeSlotStartMinutes(Object? values) {
    if (values is! List) {
      throw SettingsResolveException(
          message:
              'timeSlotStartMinutes(${values.runtimeType}) must be a list');
    }
    return values.map<int>((item) {
      if (item is! int) {
        throw SettingsResolveException(
          message: 'timeSlotStartMinutes item must be int',
        );
      }
      return item;
    }).toList(growable: false);
  }

  static List<TimePeriodRangeData> _parseTimeSlotRanges(Object? values) {
    if (values is! List) {
      throw SettingsResolveException(
        message: 'timeSlotRanges(${values.runtimeType}) must be a list',
      );
    }
    final List<TimePeriodRangeData> ranges =
        values.map<TimePeriodRangeData>((item) {
      if (item is! Map<String, dynamic>) {
        throw SettingsResolveException(
          message: 'timeSlotRanges item must be Map<String, dynamic>',
        );
      }
      return TimePeriodRangeData.fromJson(item);
    }).toList(growable: false);
    settings_validation.validateTimeSlotRanges(ranges);
    return ranges;
  }

  static List<TimePeriodRangeData> _deriveRangesFromStarts(List<int> starts) {
    return settings_validation.buildTimeSlotRangesFromStartMinutes(starts);
  }

  static List<TimePeriodRangeData> _defaultTimeSlotRanges() {
    return kDefaultTimeSlotRanges;
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
  static final SettingsData _defaultSettings = SettingsData(
    maxWeek: kDefaultMaxWeek,
    timeSlotRanges: kDefaultTimeSlotRanges,
    dashboardUpcomingMode: kDefaultDashboardUpcomingMode,
    dashboardUpcomingCount: kDefaultDashboardUpcomingCount,
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
