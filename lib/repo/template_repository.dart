import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';

class TemplateCacheMeta {
  const TemplateCacheMeta({
    required this.lastFetchedAtMillis,
    this.versionKey,
  });

  final int lastFetchedAtMillis;
  final String? versionKey;

  factory TemplateCacheMeta.fromJson(Map<String, dynamic> json) {
    return TemplateCacheMeta(
      lastFetchedAtMillis: json['lastFetchedAtMillis'] as int? ?? 0,
      versionKey: json['versionKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastFetchedAtMillis': lastFetchedAtMillis,
      'versionKey': versionKey,
    };
  }
}

class TemplateData {
  const TemplateData({required this.items});

  final List<Map<String, dynamic>> items;

  factory TemplateData.fromJson(Map<String, dynamic> json) {
    final Object? rawItems = json['items'];
    final List<Map<String, dynamic>> items = rawItems is List<dynamic>
        ? rawItems.whereType<Map<String, dynamic>>().toList()
        : const [];
    return TemplateData(items: items);
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items,
    };
  }
}

abstract class TemplateStorage {
  Future<TemplateData?> read();
  Future<TemplateCacheMeta?> readMeta();
  Future<void> save(TemplateData data);
  Future<void> saveMeta(TemplateCacheMeta meta);
  Future<void> clear();
}

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

class TemplateRepository {
  TemplateRepository._({required TemplateStorage storage}) : _storage = storage;

  static TemplateRepository? _instance;

  static TemplateRepository getInstance() {
    if (_instance != null) {
      return _instance!;
    }
    final TemplateRepository repo = TemplateRepository._(
      storage: HiveTemplateStorage(),
    );
    _instance = repo;
    return repo;
  }

  final TemplateStorage _storage;
  TemplateData? _cached;
  TemplateCacheMeta? _cachedMeta;
  Completer<void>? _readyCompleter;
  Future<void>? _pendingPersist;

  /// Loads cache from local storage only, without network calls.
  Future<void> warmUp() async {
    try {
      final TemplateData? data = await _storage.read();
      final TemplateCacheMeta? meta = await _storage.readMeta();
      if (data == null && meta == null) {
        return;
      }
      _saveCache(data: data, meta: meta, persist: false);
    } catch (error, stackTrace) {
      _completeLoadError(error, stackTrace);
      rethrow;
    }
  }

  /// Waits until cache is ready (from local warm-up or save paths).
  Future<void> ensureLoaded() async {
    if (_cached != null && _cachedMeta != null) {
      return;
    }
    if (_readyCompleter != null) {
      return _readyCompleter!.future;
    }
    _readyCompleter = Completer<void>();
    return _readyCompleter!.future;
  }

  Future<TemplateData> fetchAndSave({
    required DateTime now,
    required Future<TemplateData> Function() fetcher,
    String? versionKey,
  }) async {
    final TemplateData fetched = await fetcher();
    final TemplateCacheMeta meta = TemplateCacheMeta(
      lastFetchedAtMillis: now.millisecondsSinceEpoch,
      versionKey: versionKey,
    );
    _saveCache(data: fetched, meta: meta, persist: true);
    return fetched;
  }

  /// Returns cached data if valid, otherwise fetches and persists fresh data.
  Future<TemplateData> getOrFetch({
    required DateTime now,
    required Future<TemplateData> Function() fetcher,
    String? versionKey,
    Duration ttl = const Duration(days: 7),
  }) async {
    final TemplateData? cached = _cached;
    final TemplateCacheMeta? meta = _cachedMeta;
    bool shouldFetch = cached == null;
    if (!shouldFetch) {
      if (versionKey != null && versionKey.isNotEmpty && meta?.versionKey != versionKey) {
        shouldFetch = true;
      } else if (meta == null || meta.lastFetchedAtMillis <= 0) {
        shouldFetch = true;
      } else {
        final DateTime lastFetched =
            DateTime.fromMillisecondsSinceEpoch(meta.lastFetchedAtMillis);
        if (now.difference(lastFetched) >= ttl) {
          shouldFetch = true;
        }
      }
    }
    if (!shouldFetch) {
      return cached!;
    }
    return fetchAndSave(
      now: now,
      versionKey: versionKey,
      fetcher: fetcher,
    );
  }

  Future<void> save(TemplateData data) async {
    _saveCache(data: data, persist: true);
  }

  Future<void> saveMeta(TemplateCacheMeta meta) async {
    _saveCache(meta: meta, persist: true);
  }

  Future<void> flush() {
    return _pendingPersist ?? Future.value();
  }

  Future<void> clear() async {
    await flush();
    _pendingPersist = null;
    _cached = null;
    _cachedMeta = null;
    _readyCompleter = null;
    await _storage.clear();
  }

  void _saveCache({
    TemplateData? data,
    TemplateCacheMeta? meta,
    required bool persist,
  }) {
    if (data != null) {
      _cached = data;
    }
    if (meta != null) {
      _cachedMeta = meta;
    }
    _completeReady();
    if (!persist || _cached == null || _cachedMeta == null) {
      return;
    }
    _queuePersist(_cached!, _cachedMeta!);
  }

  Future<void> _queuePersist(
    TemplateData data,
    TemplateCacheMeta meta,
  ) {
    final Future<void> task = Future.wait([
      _storage.save(data),
      _storage.saveMeta(meta),
    ]).then((_) => null);
    _pendingPersist = (_pendingPersist ?? Future.value()).then((_) => task);
    return _pendingPersist!;
  }

  void _completeReady() {
    if (_readyCompleter != null && !_readyCompleter!.isCompleted) {
      _readyCompleter!.complete();
    }
  }

  void _completeLoadError(Object error, [StackTrace? stackTrace]) {
    if (_readyCompleter != null && !_readyCompleter!.isCompleted) {
      _readyCompleter!.completeError(error, stackTrace);
    }
    _readyCompleter = null;
  }
}
