import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:onetj/models/student_info_data.dart';
import 'package:onetj/repo/base_cached_repository.dart';

class StudentInfoCacheMeta extends BaseMeta {
  const StudentInfoCacheMeta({
    required super.lastFetchedAtMillis,
    this.versionKey,
  }) : super();

  final String? versionKey;

  factory StudentInfoCacheMeta.fromJson(Map<String, dynamic> json) {
    return StudentInfoCacheMeta(
      lastFetchedAtMillis: json['lastFetchedAtMillis'] as int? ?? 0,
      versionKey: json['versionKey'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'lastFetchedAtMillis': lastFetchedAtMillis,
      'versionKey': versionKey,
    };
  }
}

abstract class StudentInfoStorage
    extends CacheStorage<StudentInfoData, StudentInfoCacheMeta> {}

class HiveStudentInfoStorage implements StudentInfoStorage {
  HiveStudentInfoStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'student_info';
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
  Future<StudentInfoData?> read() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return StudentInfoData.fromJson(data);
  }

  @override
  Future<void> save(StudentInfoData info) async {
    final Box<String> box = await _openBox();
    await box.put(_key, jsonEncode(info.toJson()));
  }

  @override
  Future<StudentInfoCacheMeta?> readMeta() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_metaKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return StudentInfoCacheMeta.fromJson(data);
  }

  @override
  Future<void> saveMeta(StudentInfoCacheMeta meta) async {
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

class InMemoryStudentInfoStorage implements StudentInfoStorage {
  StudentInfoData? _cache;
  StudentInfoCacheMeta? _metaCache;

  @override
  Future<StudentInfoData?> read() async => _cache;

  @override
  Future<StudentInfoCacheMeta?> readMeta() async => _metaCache;

  @override
  Future<void> save(StudentInfoData info) async {
    _cache = info;
  }

  @override
  Future<void> saveMeta(StudentInfoCacheMeta meta) async {
    _metaCache = meta;
  }

  @override
  Future<void> clear() async {
    _cache = null;
    _metaCache = null;
  }
}

class StudentInfoRepository extends BaseNetCachedRepository<StudentInfoData,
    StudentInfoCacheMeta, StudentInfoStorage> {
  StudentInfoRepository({
    StudentInfoStorage? storage,
  }) : super(storage ?? HiveStudentInfoStorage());

  @override
  StudentInfoCacheMeta buildMeta(
    DateTime now,
    StudentInfoData data, {
    Object? requestKey,
  }) {
    return StudentInfoCacheMeta(
      lastFetchedAtMillis: now.millisecondsSinceEpoch,
      versionKey: requestKey as String?,
    );
  }

  @override
  bool shouldFetch({
    required DateTime now,
    required Duration ttl,
    required StudentInfoData? cached,
    required StudentInfoCacheMeta? meta,
    Object? requestKey,
  }) {
    final bool shouldFetchByBase = super.shouldFetch(
      now: now,
      ttl: ttl,
      cached: cached,
      meta: meta,
      requestKey: requestKey,
    );
    if (shouldFetchByBase) {
      return true;
    }
    final String? versionKey = requestKey as String?;
    return versionKey != null &&
        versionKey.isNotEmpty &&
        meta?.versionKey != versionKey;
  }

  Future<StudentInfoData?> getCached({
    bool refreshFromStorage = false,
  }) async {
    if (!refreshFromStorage && cachedData != null) {
      return cachedData;
    }
    return readDataFromStorage();
  }

  Future<StudentInfoCacheMeta?> getCachedMeta({
    bool refreshFromStorage = false,
  }) async {
    if (!refreshFromStorage && cachedMeta != null) {
      return cachedMeta;
    }
    return readMetaFromStorage();
  }

  @override
  Future<StudentInfoData> getOrFetch({
    required DateTime now,
    required Future<StudentInfoData> Function() fetcher,
    String? versionKey,
    Duration ttl = const Duration(days: 7),
    Object? requestKey,
  }) {
    return super.getOrFetch(
      now: now,
      fetcher: fetcher,
      ttl: ttl,
      requestKey: _normalizeVersionKey(versionKey) ?? requestKey,
    );
  }

  @override
  Future<StudentInfoData> refresh({
    required DateTime now,
    required Future<StudentInfoData> Function() fetcher,
    String? versionKey,
    Object? requestKey,
  }) {
    return super.refresh(
      now: now,
      fetcher: fetcher,
      requestKey: _normalizeVersionKey(versionKey) ?? requestKey,
    );
  }

  String? _normalizeVersionKey(String? versionKey) {
    return versionKey != null && versionKey.isNotEmpty ? versionKey : null;
  }
}
