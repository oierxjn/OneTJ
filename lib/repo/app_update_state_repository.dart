import 'dart:convert';

import 'package:hive/hive.dart';

class AppUpdateStateData {
  const AppUpdateStateData({
    this.lastCheckedAtMillis,
    this.skippedVersionTag,
  });

  final int? lastCheckedAtMillis;
  final String? skippedVersionTag;

  DateTime? get lastCheckedAt {
    final int? millis = lastCheckedAtMillis;
    if (millis == null || millis <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  AppUpdateStateData copyWith({
    int? lastCheckedAtMillis,
    String? skippedVersionTag,
    bool clearSkippedVersionTag = false,
  }) {
    return AppUpdateStateData(
      lastCheckedAtMillis: lastCheckedAtMillis ?? this.lastCheckedAtMillis,
      skippedVersionTag: clearSkippedVersionTag
          ? null
          : (skippedVersionTag ?? this.skippedVersionTag),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'lastCheckedAtMillis': lastCheckedAtMillis,
      'skippedVersionTag': skippedVersionTag,
    };
  }

  factory AppUpdateStateData.fromJson(Map<String, dynamic> json) {
    return AppUpdateStateData(
      lastCheckedAtMillis: (json['lastCheckedAtMillis'] as num?)?.toInt(),
      skippedVersionTag: json['skippedVersionTag'] as String?,
    );
  }
}

class AppUpdateStateRepository {
  AppUpdateStateRepository._({required HiveInterface hive}) : _hive = hive;

  static const String _boxName = 'app_update_state';
  static const String _key = 'payload';
  static AppUpdateStateRepository? _instance;

  static AppUpdateStateRepository getInstance() {
    return _instance ??= AppUpdateStateRepository._(hive: Hive);
  }

  final HiveInterface _hive;
  AppUpdateStateData? _cached;

  Future<Box<String>> _openBox() async {
    if (_hive.isBoxOpen(_boxName)) {
      return _hive.box<String>(_boxName);
    }
    return _hive.openBox<String>(_boxName);
  }

  Future<AppUpdateStateData> getState({bool refreshFromStorage = false}) async {
    if (!refreshFromStorage && _cached != null) {
      return _cached!;
    }
    final Box<String> box = await _openBox();
    final String? raw = box.get(_key);
    if (raw == null || raw.isEmpty) {
      _cached = const AppUpdateStateData();
      return _cached!;
    }
    final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
    _cached = AppUpdateStateData.fromJson(map);
    return _cached!;
  }

  Future<void> saveState(AppUpdateStateData data) async {
    final Box<String> box = await _openBox();
    await box.put(_key, jsonEncode(data.toJson()));
    _cached = data;
  }

  Future<void> markCheckedAt(DateTime time) async {
    final AppUpdateStateData current = await getState();
    await saveState(
      current.copyWith(
        lastCheckedAtMillis: time.millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> skipVersion(String versionTag) async {
    final AppUpdateStateData current = await getState();
    await saveState(current.copyWith(skippedVersionTag: versionTag));
  }

  Future<void> clearSkippedVersion() async {
    final AppUpdateStateData current = await getState();
    await saveState(current.copyWith(clearSkippedVersionTag: true));
  }
}
