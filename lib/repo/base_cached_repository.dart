import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:onetj/app/exception/app_exception.dart';

/// 基础数据类，所有缓存数据都必须实现该类
///
/// 建议补上fromJson工厂方法
abstract class BaseData {
  const BaseData();
  Map<String, dynamic> toJson();
}

/// 基础元数据类，所有缓存元数据都必须实现该类
///
/// 建议补上fromJson工厂方法
abstract class BaseMeta {
  const BaseMeta({required this.lastFetchedAtMillis});

  final int lastFetchedAtMillis;

  Map<String, dynamic> toJson();
}

abstract class CacheStorage<TData extends BaseData, TMeta extends BaseMeta> {
  Future<TData?> read();
  Future<TMeta?> readMeta();
  Future<void> save(TData data);
  Future<void> saveMeta(TMeta meta);
  Future<void> clear();
}

abstract class BaseNetCachedRepository<TData extends BaseData,
    TMeta extends BaseMeta, TStorage extends CacheStorage<TData, TMeta>> {
  BaseNetCachedRepository(this._storage);

  final TStorage _storage;

  TData? _cachedData;
  TMeta? _cachedMeta;
  Future<void>? _pendingPersist;
  Future<TData>? _inFlightFetch;
  Completer<void>? _clearCompleter;
  @protected
  TData? get cachedData => _cachedData;
  @protected
  TMeta? get cachedMeta => _cachedMeta;

  Future<TData?> readDataFromStorage() async => await _storage.read();
  Future<TMeta?> readMetaFromStorage() async => await _storage.readMeta();
  Future<void> persistData(TData data) async => await _storage.save(data);
  Future<void> persistMeta(TMeta meta) async => await _storage.saveMeta(meta);
  Future<void> clearStorage() async => await _storage.clear();

  TMeta buildMeta(DateTime now);

  Future<void> warmUp() async {
    _throwIfClearing();
    final TData? data = await readDataFromStorage();
    final TMeta? meta = await readMetaFromStorage();
    _throwIfClearing();
    if (data == null && meta == null) {
      return;
    }
    _saveCache(data: data, meta: meta, persist: false);
  }

  bool shouldFetch({
    required DateTime now,
    required Duration ttl,
    required TData? cached,
    required TMeta? meta,
  }) {
    if (cached == null || meta == null) {
      return true;
    }
    final int lastFetchedAtMillis = meta.lastFetchedAtMillis;
    if (lastFetchedAtMillis <= 0 ||
        now.difference(
                DateTime.fromMillisecondsSinceEpoch(lastFetchedAtMillis)) >=
            ttl) {
      return true;
    }
    return false;
  }

  Future<TData> getOrFetch({
    required DateTime now,
    required Future<TData> Function() fetcher,
    Duration ttl = const Duration(days: 7),
  }) async {
    _throwIfClearing();
    final TData? cached = _cachedData;
    final TMeta? meta = _cachedMeta;
    bool shouldFetchFlag = shouldFetch(
      now: now,
      ttl: ttl,
      cached: cached,
      meta: meta,
    );
    if (!shouldFetchFlag) {
      return cached!;
    }
    return _runSingleFlightFetch(now: now, fetcher: fetcher);
  }

  Future<TData> refresh({
    required DateTime now,
    required Future<TData> Function() fetcher,
  }) {
    return _runSingleFlightFetch(now: now, fetcher: fetcher);
  }

  Future<void> flush() {
    return _pendingPersist ?? Future.value();
  }

  Future<void> flushInFlight() async {
    final Future<TData>? inFlight = _inFlightFetch;
    if (inFlight == null) {
      return;
    }
    try {
      await inFlight;
    } catch (_) {}
  }

  Future<void> clearCache() async {
    final Completer<void>? activeClear = _clearCompleter;
    if (activeClear != null) {
      return activeClear.future;
    }
    final Completer<void> clearCompleter = Completer<void>();
    _clearCompleter = clearCompleter;
    try {
      await flushInFlight();
      await flush();
      _pendingPersist = null;
      _cachedData = null;
      _cachedMeta = null;
      _inFlightFetch = null;
      await clearStorage();
      clearCompleter.complete();
    } catch (error, stackTrace) {
      clearCompleter.completeError(error, stackTrace);
      rethrow;
    } finally {
      if (identical(_clearCompleter, clearCompleter)) {
        _clearCompleter = null;
      }
    }
  }

  Future<TData> _runSingleFlightFetch({
    required DateTime now,
    required Future<TData> Function() fetcher,
  }) {
    _throwIfClearing();
    final Future<TData>? inFlight = _inFlightFetch;
    if (inFlight != null) {
      return inFlight;
    }
    late final Future<TData> nextInFlight;
    nextInFlight = () async {
      try {
        return await _fetchAndSave(now: now, fetcher: fetcher);
      } finally {
        if (identical(_inFlightFetch, nextInFlight)) {
          _inFlightFetch = null;
        }
      }
    }();
    _inFlightFetch = nextInFlight;
    return nextInFlight;
  }

  Future<TData> _fetchAndSave({
    required DateTime now,
    required Future<TData> Function() fetcher,
  }) async {
    final TData fetched = await fetcher();
    final TMeta meta = buildMeta(now);
    _saveCache(data: fetched, meta: meta, persist: true);
    return fetched;
  }

  void _saveCache({
    TData? data,
    TMeta? meta,
    required bool persist,
  }) {
    if (data != null) {
      _cachedData = data;
    }
    if (meta != null) {
      _cachedMeta = meta;
    }
    if (!persist || _cachedData == null || _cachedMeta == null) {
      return;
    }
    final TData dataToPersist = _cachedData as TData;
    final TMeta metaToPersist = _cachedMeta as TMeta;
    _queuePersist(dataToPersist, metaToPersist);
  }

  /// 轻量式检查是否正在清除缓存
  void _throwIfClearing() {
    if (_clearCompleter != null) {
      throw RepositoryClearingException(
        repositoryName: runtimeType.toString(),
      );
    }
  }

  Future<void> _queuePersist(
    TData data,
    TMeta meta,
  ) {
    final Future<void> task = Future.wait([
      persistData(data),
      persistMeta(meta),
    ]).then((_) => null);
    _pendingPersist = (_pendingPersist ?? Future.value()).then((_) => task);
    return _pendingPersist!;
  }
}
