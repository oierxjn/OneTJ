import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:onetj/models/course_schedule_data.dart';
import 'package:onetj/repo/base_cached_repository.dart';

abstract class CourseScheduleStorage
    extends CacheStorage<CourseScheduleData, CourseScheduleCacheMeta> {}

class CourseScheduleCacheMeta extends BaseMeta {
  const CourseScheduleCacheMeta({
    required super.lastFetchedAtMillis,
    this.termKey,
  }) : super();

  final String? termKey;

  factory CourseScheduleCacheMeta.fromJson(Map<String, dynamic> json) {
    return CourseScheduleCacheMeta(
      lastFetchedAtMillis: json['lastFetchedAtMillis'] as int? ?? 0,
      termKey: json['termKey'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'lastFetchedAtMillis': lastFetchedAtMillis,
      'termKey': termKey,
    };
  }
}

class HiveCourseScheduleStorage implements CourseScheduleStorage {
  HiveCourseScheduleStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'course_schedule';
  static const String _key = 'payload';
  static const String _metaKey = 'meta';
  final HiveInterface _hive;

  Future<Box<String>> _openBox() async {
    if (_hive.isBoxOpen(_boxName)) {
      return _hive.box<String>(_boxName);
    }
    return _hive.openBox<String>(_boxName);
  }

  @override
  Future<CourseScheduleData?> read() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return CourseScheduleData.fromJson(data);
  }

  @override
  Future<void> save(CourseScheduleData data) async {
    final Box<String> box = await _openBox();
    await box.put(_key, jsonEncode(data.toJson()));
  }

  @override
  Future<CourseScheduleCacheMeta?> readMeta() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_metaKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return CourseScheduleCacheMeta.fromJson(data);
  }

  @override
  Future<void> saveMeta(CourseScheduleCacheMeta meta) async {
    final Box<String> box = await _openBox();
    await box.put(_metaKey, jsonEncode(meta.toJson()));
  }

  @override
  Future<void> clear() async {
    final Box<String> box = await _openBox();
    await box.delete(_key);
    await box.delete(_metaKey);
  }
}

class InMemoryCourseScheduleStorage implements CourseScheduleStorage {
  CourseScheduleData? _cache;
  CourseScheduleCacheMeta? _meta;

  @override
  Future<CourseScheduleData?> read() async => _cache;

  @override
  Future<void> save(CourseScheduleData data) async {
    _cache = data;
  }

  @override
  Future<CourseScheduleCacheMeta?> readMeta() async => _meta;

  @override
  Future<void> saveMeta(CourseScheduleCacheMeta meta) async {
    _meta = meta;
  }

  @override
  Future<void> clear() async {
    _cache = null;
    _meta = null;
  }
}

class CourseScheduleRepository extends BaseNetCachedRepository<
    CourseScheduleData, CourseScheduleCacheMeta, CourseScheduleStorage> {
  CourseScheduleRepository({
    CourseScheduleStorage? storage,
  }) : super(storage ?? HiveCourseScheduleStorage());

  String? _pendingTermKey;

  @override
  CourseScheduleCacheMeta buildMeta(DateTime now) {
    return CourseScheduleCacheMeta(
      lastFetchedAtMillis: now.millisecondsSinceEpoch,
      termKey: _pendingTermKey,
    );
  }

  Future<CourseScheduleData?> getCached({
    bool refreshFromStorage = false,
  }) async {
    if (!refreshFromStorage && cachedData != null) {
      return cachedData;
    }
    return readDataFromStorage();
  }

  Future<CourseScheduleCacheMeta?> getCachedMeta({
    bool refreshFromStorage = false,
  }) async {
    if (!refreshFromStorage && cachedMeta != null) {
      return cachedMeta;
    }
    return readMetaFromStorage();
  }

  @override
  Future<CourseScheduleData> getOrFetch({
    required DateTime now,
    required Future<CourseScheduleData> Function() fetcher,
    String? termKey,
    Duration ttl = const Duration(days: 7),
  }) async {
    _pendingTermKey ??= termKey;
    final CourseScheduleData data;
    try {
      data = await super.getOrFetch(
        now: now,
        fetcher: fetcher,
        ttl: ttl,
      );
      return data;
    } finally {
      _pendingTermKey = null;
    }
  }

  @override
  bool shouldFetch(
      {required DateTime now,
      required Duration ttl,
      required CourseScheduleData? cached,
      required CourseScheduleCacheMeta? meta}) {
    if (meta == null || meta.termKey != _pendingTermKey) {
      return true;
    }
    return super.shouldFetch(now: now, ttl: ttl, cached: cached, meta: meta);
  }

  @override
  Future<CourseScheduleData> refresh({
    required DateTime now,
    required Future<CourseScheduleData> Function() fetcher,
    String? termKey,
  }) async {
    _pendingTermKey ??= termKey;
    final CourseScheduleData data;
    try {
      data = await super.refresh(
        now: now,
        fetcher: fetcher,
      );
      return data;
    } finally {
      _pendingTermKey = null;
    }
  }
}
