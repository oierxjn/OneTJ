import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/models/school_calendar_data.dart';
import 'package:onetj/repo/school_calendar_repository.dart';

SchoolCalendarData _calendarData(int week) {
  return SchoolCalendarData(
    schoolCalendar: SchoolCalendarItemData(
      id: 1,
      year: 2026,
      term: 1,
      beginDay: 1789468800000,
      endDay: 1796035200000,
      weekNum: 16,
      weekBeginDay: 2,
      createdAt: null,
      updatedAt: null,
      deleteFlag: null,
    ),
    week: week,
    simpleName: '26-27秋',
    now: '2026年9月',
    name: '2026-2027学年秋季学期',
  );
}

/// 2026-09-27 是周日，2026-09-28 是周一（教学周切换日）。
void main() {
  group('SchoolCalendarRepository', () {
    late InMemorySchoolCalendarStorage storage;
    late SchoolCalendarRepository repo;

    setUp(() {
      storage = InMemorySchoolCalendarStorage();
      repo = SchoolCalendarRepository(storage: storage);
    });

    test('fetches on first read when cache is empty', () async {
      int fetchCount = 0;
      final SchoolCalendarData data = await repo.getOrFetch(
        now: DateTime(2026, 9, 27, 22, 37),
        fetcher: () async {
          fetchCount += 1;
          return _calendarData(2);
        },
      );

      expect(fetchCount, 1);
      expect(data.week, 2);
    });

    test('serves cache within the same teaching week and ttl', () async {
      int fetchCount = 0;
      Future<SchoolCalendarData> fetcher() async {
        fetchCount += 1;
        return _calendarData(2);
      }

      await repo.getOrFetch(
        now: DateTime(2026, 9, 27, 15, 0),
        fetcher: fetcher,
      );
      await repo.getOrFetch(
        now: DateTime(2026, 9, 27, 20, 0),
        fetcher: fetcher,
      );

      expect(fetchCount, 1);
    });

    test('refetches on Monday after being fetched on Sunday', () async {
      int fetchCount = 0;
      int weekAtFetch = 0;
      Future<SchoolCalendarData> fetcher() async {
        fetchCount += 1;
        // 服务器在周一将周数递增
        weekAtFetch = fetchCount == 1 ? 2 : 3;
        return _calendarData(weekAtFetch);
      }

      await repo.getOrFetch(
        now: DateTime(2026, 9, 27, 22, 37),
        fetcher: fetcher,
      );
      final SchoolCalendarData mondayRead = await repo.getOrFetch(
        now: DateTime(2026, 9, 28, 8, 0),
        fetcher: fetcher,
      );

      expect(fetchCount, 2, reason: '周一读取必须越过周边界重新拉取');
      expect(mondayRead.week, 3, reason: '周一读取必须拿到递增后的新周数');
    });

    test('does not refetch mid-week before ttl expires', () async {
      int fetchCount = 0;
      Future<SchoolCalendarData> fetcher() async {
        fetchCount += 1;
        return _calendarData(2);
      }

      await repo.getOrFetch(
        now: DateTime(2026, 9, 28, 10, 0),
        fetcher: fetcher,
      );
      await repo.getOrFetch(
        now: DateTime(2026, 9, 29, 9, 0),
        fetcher: fetcher,
      );

      expect(fetchCount, 1);
    });

    test('refetches when ttl expires without week boundary', () async {
      int fetchCount = 0;
      Future<SchoolCalendarData> fetcher() async {
        fetchCount += 1;
        return _calendarData(2);
      }

      await repo.getOrFetch(
        now: DateTime(2026, 9, 28, 10, 0),
        fetcher: fetcher,
      );
      await repo.getOrFetch(
        now: DateTime(2026, 9, 29, 10, 1),
        fetcher: fetcher,
      );

      expect(fetchCount, 2);
    });

    test('meta persists only lastFetchedAtMillis', () async {
      await repo.getOrFetch(
        now: DateTime(2026, 9, 27, 22, 37),
        fetcher: () async => _calendarData(2),
      );

      final SchoolCalendarCacheMeta? meta = await storage.readMeta();

      expect(meta?.lastFetchedAtMillis,
          DateTime(2026, 9, 27, 22, 37).millisecondsSinceEpoch);
      expect(meta?.toJson().keys, <String>{'lastFetchedAtMillis'});
    });

    test('meta fromJson tolerates legacy weekBeginDay field', () {
      final SchoolCalendarCacheMeta meta = SchoolCalendarCacheMeta.fromJson(
        <String, dynamic>{
          'lastFetchedAtMillis': 1780000000000,
          'weekBeginDay': 2,
        },
      );

      expect(meta.lastFetchedAtMillis, 1780000000000);
    });
  });
}
