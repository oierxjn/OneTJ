import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:onetj/repo/base_cached_repository.dart';

class TemplateCacheMeta extends BaseMeta {
  const TemplateCacheMeta({
    required super.lastFetchedAtMillis,
  }) : super();

  factory TemplateCacheMeta.fromJson(Map<String, dynamic> json) {
    return TemplateCacheMeta(
      lastFetchedAtMillis: json['lastFetchedAtMillis'] as int? ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'lastFetchedAtMillis': lastFetchedAtMillis,
    };
  }
}

class TemplateData extends BaseData {
  const TemplateData({required this.items}) : super();

  final List<Map<String, dynamic>> items;

  factory TemplateData.fromJson(Map<String, dynamic> json) {
    final Object? rawItems = json['items'];
    final List<Map<String, dynamic>> items = rawItems is List<dynamic>
        ? rawItems.whereType<Map<String, dynamic>>().toList()
        : const [];
    return TemplateData(items: items);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'items': items,
    };
  }
}

abstract class TemplateStorage
    extends CacheStorage<TemplateData, TemplateCacheMeta> {}

class HiveTemplateStorage implements TemplateStorage {
  HiveTemplateStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'template_data';
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
  Future<TemplateData?> read() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return TemplateData.fromJson(data);
  }

  @override
  Future<void> save(TemplateData data) async {
    final Box<String> box = await _openBox();
    await box.put(_key, jsonEncode(data.toJson()));
  }

  @override
  Future<TemplateCacheMeta?> readMeta() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_metaKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return TemplateCacheMeta.fromJson(data);
  }

  @override
  Future<void> saveMeta(TemplateCacheMeta meta) async {
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

class TemplateRepository extends BaseCachedRepository<TemplateData,
    TemplateCacheMeta, TemplateStorage> {
  TemplateRepository._({
    required TemplateStorage storage,
    required Future<TemplateData> Function() fetcher,
  })  : _fetcher = fetcher,
        super(storage);

  static TemplateRepository? _instance;

  static TemplateRepository getInstance({
    TemplateStorage? storage,
    Future<TemplateData> Function()? fetcher,
  }) {
    if (_instance != null) {
      return _instance!;
    }
    if (fetcher == null) {
      throw StateError(
        'TemplateRepository is not initialized. '
        'Provide fetcher on first getInstance() call.',
      );
    }
    final TemplateRepository repo = TemplateRepository._(
      storage: storage ?? HiveTemplateStorage(),
      fetcher: fetcher,
    );
    _instance = repo;
    return repo;
  }

  final Future<TemplateData> Function() _fetcher;

  @visibleForTesting
  static void resetInstanceForTest() {
    _instance = null;
  }

  @override
  Future<TemplateData> fetchFresh() => _fetcher();

  @override
  TemplateCacheMeta buildMeta(DateTime now) {
    return TemplateCacheMeta(
      lastFetchedAtMillis: now.millisecondsSinceEpoch,
    );
  }
}
