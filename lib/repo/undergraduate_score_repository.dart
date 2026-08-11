import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:onetj/models/undergraduate_score_data.dart';
import 'package:onetj/repo/base_cached_repository.dart';

abstract class UndergraduateScoreStorage
    extends CacheStorage<UndergraduateScoreData, UndergraduateScoreCacheMeta> {}

class UndergraduateScoreCacheMeta extends BaseMeta {
  const UndergraduateScoreCacheMeta({
    required super.lastFetchedAtMillis,
    this.versionKey,
  }) : super();

  final String? versionKey;

  factory UndergraduateScoreCacheMeta.fromJson(Map<String, dynamic> json) {
    return UndergraduateScoreCacheMeta(
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

class HiveUndergraduateScoreStorage implements UndergraduateScoreStorage {
  HiveUndergraduateScoreStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'undergraduate_score';
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
  Future<UndergraduateScoreData?> read() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return UndergraduateScoreData.fromJson(data);
  }

  @override
  Future<void> save(UndergraduateScoreData data) async {
    final Box<String> box = await _openBox();
    await box.put(_key, jsonEncode(data.toJson()));
  }

  @override
  Future<UndergraduateScoreCacheMeta?> readMeta() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_metaKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return UndergraduateScoreCacheMeta.fromJson(data);
  }

  @override
  Future<void> saveMeta(UndergraduateScoreCacheMeta meta) async {
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

class InMemoryUndergraduateScoreStorage implements UndergraduateScoreStorage {
  UndergraduateScoreData? _cache;
  UndergraduateScoreCacheMeta? _meta;

  @override
  Future<UndergraduateScoreData?> read() async => _cache;

  @override
  Future<void> save(UndergraduateScoreData data) async {
    _cache = data;
  }

  @override
  Future<UndergraduateScoreCacheMeta?> readMeta() async => _meta;

  @override
  Future<void> saveMeta(UndergraduateScoreCacheMeta meta) async {
    _meta = meta;
  }

  @override
  Future<void> clear() async {
    _cache = null;
    _meta = null;
  }
}

class UndergraduateScoreRepository extends BaseNetCachedRepository<
    UndergraduateScoreData,
    UndergraduateScoreCacheMeta,
    UndergraduateScoreStorage> {
  UndergraduateScoreRepository({UndergraduateScoreStorage? storage})
      : super(storage ?? HiveUndergraduateScoreStorage());

  String? _pendingVersionKey;

  @override
  UndergraduateScoreCacheMeta buildMeta(DateTime now) {
    return UndergraduateScoreCacheMeta(
      lastFetchedAtMillis: now.millisecondsSinceEpoch,
      versionKey: _pendingVersionKey,
    );
  }

  @override
  bool shouldFetch({
    required DateTime now,
    required Duration ttl,
    required UndergraduateScoreData? cached,
    required UndergraduateScoreCacheMeta? meta,
  }) {
    final bool shouldFetchByBase = super.shouldFetch(
      now: now,
      ttl: ttl,
      cached: cached,
      meta: meta,
    );
    if (shouldFetchByBase) {
      return true;
    }
    final String? versionKey = _pendingVersionKey;
    if (versionKey != null &&
        versionKey.isNotEmpty &&
        meta?.versionKey != versionKey) {
      return true;
    }
    return false;
  }

  Future<UndergraduateScoreData?> getCached({
    bool refreshFromStorage = false,
  }) async {
    if (!refreshFromStorage && cachedData != null) {
      return cachedData;
    }
    return readDataFromStorage();
  }

  Future<UndergraduateScoreCacheMeta?> getCachedMeta({
    bool refreshFromStorage = false,
  }) async {
    if (!refreshFromStorage && cachedMeta != null) {
      return cachedMeta;
    }
    return readMetaFromStorage();
  }

  @override
  Future<UndergraduateScoreData> getOrFetch({
    required DateTime now,
    required Future<UndergraduateScoreData> Function() fetcher,
    String? versionKey,
    Duration ttl = const Duration(days: 7),
  }) async {
    _pendingVersionKey =
        (versionKey != null && versionKey.isNotEmpty) ? versionKey : null;
    try {
      return await super.getOrFetch(
        now: now,
        fetcher: fetcher,
        ttl: ttl,
      );
    } finally {
      _pendingVersionKey = null;
    }
  }

  @override
  Future<UndergraduateScoreData> refresh({
    required DateTime now,
    required Future<UndergraduateScoreData> Function() fetcher,
    String? versionKey,
  }) async {
    _pendingVersionKey =
        (versionKey != null && versionKey.isNotEmpty) ? versionKey : null;
    try {
      return await super.refresh(now: now, fetcher: fetcher);
    } finally {
      _pendingVersionKey = null;
    }
  }
}
