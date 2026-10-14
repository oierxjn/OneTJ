import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/models/base_data.dart';

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

  /// 持久化写入链，链头保持无错，使后续入队不被上一次失败短路。
  ///
  /// 存储操作必须串行：data 与 meta 是同一次缓存的两个部分，并发写会让两者
  /// 交错落盘，出现「缓存是新值、元数据是旧值」这类不一致。
  Future<void> _persistChain = Future<void>.value();

  /// 最近一次排入队列的写入，供 [flush] 等待；链本身见 [_persistChain]。
  Future<void>? _pendingPersist;
  Future<TData>? _inFlightFetch;
  Object? _inFlightRequestKey;
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

  TMeta buildMeta(
    DateTime now,
    TData data, {
    String? requestKey,
  });

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
    String? requestKey,
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
    String? requestKey,
  }) async {
    _throwIfClearing();
    final TData? cached = _cachedData;
    final TMeta? meta = _cachedMeta;
    bool shouldFetchFlag = shouldFetch(
      now: now,
      ttl: ttl,
      cached: cached,
      meta: meta,
      requestKey: requestKey,
    );
    if (!shouldFetchFlag) {
      return cached!;
    }
    return _runSingleFlightFetch(
      now: now,
      fetcher: fetcher,
      requestKey: requestKey,
    );
  }

  Future<TData> refresh({
    required DateTime now,
    required Future<TData> Function() fetcher,
    String? requestKey,
  }) {
    return _runSingleFlightFetch(
      now: now,
      fetcher: fetcher,
      requestKey: requestKey,
    );
  }

  /// 等待在飞的持久化落定。
  ///
  /// 不关心写入结果：落盘失败意味着下次启动重新拉取，不影响本次流程。
  Future<void> flush() {
    final Future<void>? pending = _pendingPersist;
    if (pending == null) {
      return Future<void>.value();
    }
    return pending.catchError((_) {});
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
      _cachedData = null;
      _cachedMeta = null;
      _inFlightFetch = null;
      _inFlightRequestKey = null;
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
    required String? requestKey,
  }) {
    _throwIfClearing();
    final Future<TData>? inFlight = _inFlightFetch;
    if (inFlight != null) {
      if (_inFlightRequestKey == requestKey) {
        return inFlight;
      }
      return _runAfterInFlight(
        inFlight: inFlight,
        now: now,
        fetcher: fetcher,
        requestKey: requestKey,
      );
    }
    late final Future<TData> nextInFlight;
    nextInFlight = () async {
      try {
        return await _fetchAndSave(
          now: now,
          fetcher: fetcher,
          requestKey: requestKey,
        );
      } finally {
        if (identical(_inFlightFetch, nextInFlight)) {
          _inFlightFetch = null;
          _inFlightRequestKey = null;
        }
      }
    }();
    _inFlightFetch = nextInFlight;
    _inFlightRequestKey = requestKey;
    return nextInFlight;
  }

  Future<TData> _runAfterInFlight({
    required Future<TData> inFlight,
    required DateTime now,
    required Future<TData> Function() fetcher,
    required String? requestKey,
  }) async {
    try {
      await inFlight;
    } catch (_) {}
    _throwIfClearing();
    return _runSingleFlightFetch(
      now: now,
      fetcher: fetcher,
      requestKey: requestKey,
    );
  }

  Future<TData> _fetchAndSave({
    required DateTime now,
    required Future<TData> Function() fetcher,
    required String? requestKey,
  }) async {
    final TData fetched = await fetcher();
    final TMeta meta = buildMeta(now, fetched, requestKey: requestKey);
    _saveCache(data: fetched, meta: meta, persist: true);
    return fetched;
  }

  /// 更新内存缓存，并按需把它排入持久化队列。
  ///
  /// 刻意不 await 写入：内存已经是权威副本，落盘失败只意味着下次启动重新拉取，
  /// 不影响调用方拿到的结果。写入失败因此在本方法内就地记录后结束，不外抛、
  /// 也不向上传播给 await [_queuePersist] 的人。
  ///
  /// 需要感知写入结果的调用方应自行 await [_queuePersist]，而不是依赖这里。
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
    // 队列无人在 await，这里是错误唯一的落脚点，因此就地记录。
    unawaited(
      _queuePersist(dataToPersist, metaToPersist).catchError(
        (Object error, StackTrace stackTrace) {
          AppLogger.warning(
            'Cache persist failed, memory cache only',
            loggerName: runtimeType.toString(),
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
    );
  }

  /// 轻量式检查是否正在清除缓存
  void _throwIfClearing() {
    if (_clearCompleter != null) {
      throw RepositoryClearingException(
        repositoryName: runtimeType.toString(),
      );
    }
  }

  /// 把一次 data/meta 写入排到持久化链末尾，返回它自身的完成期。
  ///
  /// 返回值带着写入的真实结果，失败照常抛出。当前 [_saveCache] 不 await 它：
  /// 内存已先更新，落盘只是尽力而为，失败不打断主流程。将来某类缓存的磁盘
  /// 镜像变得关键时，由新的写入方 await 这个方法接住错误，而不是改这里。
  ///
  /// 注意 [persistData] / [persistMeta] 必须在 `then` 内部调用：若在外部先把
  /// `Future.wait` 构造出来再链接，两个存储操作当下就已启动，串行形同虚设。
  Future<void> _queuePersist(
    TData data,
    TMeta meta,
  ) {
    final Future<void> result = _persistChain.then(
      (_) => Future.wait(<Future<void>>[
        persistData(data),
        persistMeta(meta),
      ]),
    );
    _persistChain = result.catchError((_) {});
    _pendingPersist = result;
    return result;
  }
}
