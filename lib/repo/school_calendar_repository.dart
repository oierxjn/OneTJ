import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/models/school_calendar_data.dart';
import 'package:onetj/repo/base_cached_repository.dart';

class SchoolCalendarCacheMeta extends BaseMeta {
  const SchoolCalendarCacheMeta({required super.lastFetchedAtMillis}) : super();

  factory SchoolCalendarCacheMeta.fromJson(Map<String, dynamic> json) {
    return SchoolCalendarCacheMeta(
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

abstract class SchoolCalendarStorage
    extends CacheStorage<SchoolCalendarData, SchoolCalendarCacheMeta> {}

class HiveSchoolCalendarStorage implements SchoolCalendarStorage {
  HiveSchoolCalendarStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'school_calendar';
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
  Future<SchoolCalendarData?> read() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return SchoolCalendarData.fromJson(data);
  }

  @override
  Future<void> save(SchoolCalendarData data) async {
    final Box<String> box = await _openBox();
    await box.put(_key, jsonEncode(data.toJson()));
  }

  @override
  Future<SchoolCalendarCacheMeta?> readMeta() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_metaKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return SchoolCalendarCacheMeta.fromJson(data);
  }

  @override
  Future<void> saveMeta(SchoolCalendarCacheMeta meta) async {
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

class InMemorySchoolCalendarStorage implements SchoolCalendarStorage {
  SchoolCalendarData? _cache;
  SchoolCalendarCacheMeta? _meta;

  @override
  Future<SchoolCalendarData?> read() async => _cache;

  @override
  Future<void> save(SchoolCalendarData data) async {
    _cache = data;
  }

  @override
  Future<SchoolCalendarCacheMeta?> readMeta() async => _meta;

  @override
  Future<void> saveMeta(SchoolCalendarCacheMeta meta) async {
    _meta = meta;
  }

  @override
  Future<void> clear() async {
    _cache = null;
    _meta = null;
  }
}

class SchoolCalendarRepository extends BaseNetCachedRepository<
    SchoolCalendarData, SchoolCalendarCacheMeta, SchoolCalendarStorage> {
  SchoolCalendarRepository({
    SchoolCalendarStorage? storage,
  }) : super(storage ?? HiveSchoolCalendarStorage());

  @override
  SchoolCalendarCacheMeta buildMeta(
    DateTime now,
    SchoolCalendarData data, {
    String? requestKey,
  }) {
    AppLogger.info(
      'School calendar fetched',
      loggerName: 'SchoolCalendarRepository',
      context: <String, Object?>{
        'week': data.week,
        'term': '${data.schoolCalendar.year}-${data.schoolCalendar.term}',
        'termBeginDay': data.schoolCalendar.beginDay,
        'serverNow': data.now,
      },
    );
    return SchoolCalendarCacheMeta(
      lastFetchedAtMillis: now.millisecondsSinceEpoch,
    );
  }

  /// 判定是否需要重新拉取校历
  ///
  /// 在基础 TTL 之上增加跨周判定：教学周固定从周一起算，一旦越过上次
  /// 拉取日之后的下一个周一零点，就强制刷新，保证周一当天能读到新周数。
  ///
  /// 刻意不使用服务器返回的 weekBenginDay 参与判定：官方 API 文档示例中，
  /// 开学日分别在周一（2021-2022 学年第 2 学期）和周二（2027-2028 学年
  /// 第 1 学期）的两个学期，该字段均为常量 2，没有真实语义。若误信它，
  /// 刷新边界会被推迟到周二，导致周一整天显示上一周的周数。
  @override
  bool shouldFetch({
    required DateTime now,
    required Duration ttl,
    required SchoolCalendarData? cached,
    required SchoolCalendarCacheMeta? meta,
    String? requestKey,
  }) {
    final bool baseShouldFetch = super.shouldFetch(
      now: now,
      ttl: ttl,
      cached: cached,
      meta: meta,
      requestKey: requestKey,
    );
    if (baseShouldFetch || meta == null) {
      return baseShouldFetch;
    }
    final DateTime fetchedAt =
        DateTime.fromMillisecondsSinceEpoch(meta.lastFetchedAtMillis);
    final DateTime startOfFetchedDay = DateTime(
      fetchedAt.year,
      fetchedAt.month,
      fetchedAt.day,
    );
    int daysUntilNextMonday = (DateTime.monday - fetchedAt.weekday + 7) % 7;
    if (daysUntilNextMonday == 0) {
      daysUntilNextMonday = 7;
    }
    final DateTime nextWeekBoundary = startOfFetchedDay.add(
      Duration(days: daysUntilNextMonday),
    );
    return !now.isBefore(nextWeekBoundary);
  }

  @override
  Future<SchoolCalendarData> getOrFetch({
    required DateTime now,
    required Future<SchoolCalendarData> Function() fetcher,
    Duration ttl = const Duration(days: 1),
    String? requestKey,
  }) {
    return super.getOrFetch(
      now: now,
      fetcher: fetcher,
      ttl: ttl,
      requestKey: requestKey,
    );
  }
}
