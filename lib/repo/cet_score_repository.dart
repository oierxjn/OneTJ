import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:onetj/models/cet_score_data.dart';
import 'package:onetj/repo/base_cached_repository.dart';

abstract class CetScoreStorage
    extends CacheStorage<CetScoreData, CetScoreCacheMeta> {}

class CetScoreCacheMeta extends BaseMeta {
  const CetScoreCacheMeta({required super.lastFetchedAtMillis}) : super();

  factory CetScoreCacheMeta.fromJson(Map<String, dynamic> json) {
    return CetScoreCacheMeta(
      lastFetchedAtMillis: json['lastFetchedAtMillis'] as int? ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'lastFetchedAtMillis': lastFetchedAtMillis};
  }
}

class HiveCetScoreStorage implements CetScoreStorage {
  HiveCetScoreStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'cet_score';
  static const String _dataKey = 'payload';
  static const String _metaKey = 'meta';

  final HiveInterface _hive;

  Future<Box<String>> _openBox() async {
    if (_hive.isBoxOpen(_boxName)) {
      return _hive.box<String>(_boxName);
    }
    return _hive.openBox<String>(_boxName);
  }

  @override
  Future<CetScoreData?> read() async {
    final String? raw = (await _openBox()).get(_dataKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return CetScoreData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(CetScoreData data) async {
    await (await _openBox()).put(_dataKey, jsonEncode(data.toJson()));
  }

  @override
  Future<CetScoreCacheMeta?> readMeta() async {
    final String? raw = (await _openBox()).get(_metaKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return CetScoreCacheMeta.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> saveMeta(CetScoreCacheMeta meta) async {
    await (await _openBox()).put(_metaKey, jsonEncode(meta.toJson()));
  }

  @override
  Future<void> clear() async {
    final Box<String> box = await _openBox();
    await box.delete(_dataKey);
    await box.delete(_metaKey);
  }
}

class InMemoryCetScoreStorage implements CetScoreStorage {
  CetScoreData? _data;
  CetScoreCacheMeta? _meta;

  @override
  Future<CetScoreData?> read() async => _data;

  @override
  Future<void> save(CetScoreData data) async {
    _data = data;
  }

  @override
  Future<CetScoreCacheMeta?> readMeta() async => _meta;

  @override
  Future<void> saveMeta(CetScoreCacheMeta meta) async {
    _meta = meta;
  }

  @override
  Future<void> clear() async {
    _data = null;
    _meta = null;
  }
}

class CetScoreRepository extends BaseNetCachedRepository<CetScoreData,
    CetScoreCacheMeta, CetScoreStorage> {
  CetScoreRepository({CetScoreStorage? storage})
      : super(storage ?? HiveCetScoreStorage());

  @override
  CetScoreCacheMeta buildMeta(
    DateTime now,
    CetScoreData data, {
    String? requestKey,
  }) {
    return CetScoreCacheMeta(lastFetchedAtMillis: now.millisecondsSinceEpoch);
  }

  Future<CetScoreData?> getCached({bool refreshFromStorage = false}) async {
    if (!refreshFromStorage && cachedData != null) {
      return cachedData;
    }
    return readDataFromStorage();
  }

  Future<CetScoreCacheMeta?> getCachedMeta({
    bool refreshFromStorage = false,
  }) async {
    if (!refreshFromStorage && cachedMeta != null) {
      return cachedMeta;
    }
    return readMetaFromStorage();
  }
}
