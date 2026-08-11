import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:onetj/models/school_calendar_data.dart';
import 'package:onetj/repo/base_cached_repository.dart';

class SchoolCalendarCacheMeta extends BaseMeta {
  const SchoolCalendarCacheMeta({
    required super.lastFetchedAtMillis,
    required this.weekBeginDay,
  }) : super();

  final int weekBeginDay;

  factory SchoolCalendarCacheMeta.fromJson(Map<String, dynamic> json) {
    return SchoolCalendarCacheMeta(
      lastFetchedAtMillis: json['lastFetchedAtMillis'] as int? ?? 0,
      weekBeginDay: json['weekBeginDay'] as int? ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'lastFetchedAtMillis': lastFetchedAtMillis,
      'weekBeginDay': weekBeginDay,
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

  int? _fetchedWeekBeginDay;

  @override
  SchoolCalendarCacheMeta buildMeta(DateTime now) {
    final int weekBeginDay = _fetchedWeekBeginDay ?? 0;
    _fetchedWeekBeginDay = null;
    return SchoolCalendarCacheMeta(
      lastFetchedAtMillis: now.millisecondsSinceEpoch,
      weekBeginDay: weekBeginDay,
    );
  }

  @override
  bool shouldFetch({
    required DateTime now,
    required Duration ttl,
    required SchoolCalendarData? cached,
    required SchoolCalendarCacheMeta? meta,
  }) {
    final bool baseShouldFetch = super.shouldFetch(
      now: now,
      ttl: ttl,
      cached: cached,
      meta: meta,
    );
    if (baseShouldFetch || meta == null) {
      return baseShouldFetch;
    }
    final int weekBeginDay = meta.weekBeginDay;
    if (weekBeginDay < DateTime.monday || weekBeginDay > DateTime.sunday) {
      return false;
    }

    final DateTime fetchedAt =
        DateTime.fromMillisecondsSinceEpoch(meta.lastFetchedAtMillis);
    final DateTime startOfFetchedDay = DateTime(
      fetchedAt.year,
      fetchedAt.month,
      fetchedAt.day,
    );
    int daysUntilNextWeekBoundary = (weekBeginDay - fetchedAt.weekday + 7) % 7;
    if (daysUntilNextWeekBoundary == 0) {
      daysUntilNextWeekBoundary = 7;
    }
    final DateTime nextWeekBoundary = startOfFetchedDay.add(
      Duration(days: daysUntilNextWeekBoundary),
    );
    return !now.isBefore(nextWeekBoundary);
  }

  @override
  Future<SchoolCalendarData> getOrFetch({
    required DateTime now,
    required Future<SchoolCalendarData> Function() fetcher,
    Duration ttl = const Duration(days: 1),
  }) {
    return super.getOrFetch(
      now: now,
      fetcher: _withWeekBeginDay(fetcher),
      ttl: ttl,
    );
  }

  @override
  Future<SchoolCalendarData> refresh({
    required DateTime now,
    required Future<SchoolCalendarData> Function() fetcher,
  }) {
    return super.refresh(
      now: now,
      fetcher: _withWeekBeginDay(fetcher),
    );
  }

  Future<SchoolCalendarData> Function() _withWeekBeginDay(
    Future<SchoolCalendarData> Function() fetcher,
  ) {
    return () async {
      final SchoolCalendarData data = await fetcher();
      _fetchedWeekBeginDay = data.schoolCalendar.weekBeginDay;
      return data;
    };
  }
}
