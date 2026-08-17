import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/models/course_schedule_data.dart';
import 'package:onetj/repo/course_schedule_repository.dart';

void main() {
  group('CourseScheduleRepository', () {
    late InMemoryCourseScheduleStorage storage;
    late CourseScheduleRepository repo;

    setUp(() {
      storage = InMemoryCourseScheduleStorage();
      repo = CourseScheduleRepository(storage: storage);
    });

    test('fetches and caches data on first getOrFetch', () async {
      int fetchCount = 0;
      final CourseScheduleData data = await repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        termKey: '2025-1',
        fetcher: () async {
          fetchCount += 1;
          return const CourseScheduleData(items: <CourseScheduleItemData>[]);
        },
      );

      final CourseScheduleCacheMeta? meta =
          await repo.getCachedMeta(refreshFromStorage: true);

      expect(fetchCount, 1);
      expect(data.items, isEmpty);
      expect(meta?.termKey, '2025-1');
      expect(meta?.lastFetchedAtMillis,
          DateTime(2026, 1, 1).millisecondsSinceEpoch);
    });

    test('does not refetch when termKey unchanged and ttl valid', () async {
      int fetchCount = 0;
      Future<CourseScheduleData> fetcher() async {
        fetchCount += 1;
        return const CourseScheduleData(items: <CourseScheduleItemData>[]);
      }

      await repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        termKey: '2025-1',
        fetcher: fetcher,
      );
      await repo.getOrFetch(
        now: DateTime(2026, 1, 2),
        termKey: '2025-1',
        fetcher: fetcher,
      );

      expect(fetchCount, 1);
    });

    test('refetches when termKey changes even before ttl expires', () async {
      int fetchCount = 0;
      Future<CourseScheduleData> fetcher() async {
        fetchCount += 1;
        return const CourseScheduleData(items: <CourseScheduleItemData>[]);
      }

      await repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        termKey: '2025-1',
        fetcher: fetcher,
      );
      await repo.getOrFetch(
        now: DateTime(2026, 1, 2),
        termKey: '2025-2',
        fetcher: fetcher,
      );

      expect(fetchCount, 2);
      final CourseScheduleCacheMeta? meta =
          await repo.getCachedMeta(refreshFromStorage: true);
      expect(meta?.termKey, '2025-2');
    });

    test('ttl zero forces refetch', () async {
      int fetchCount = 0;
      Future<CourseScheduleData> fetcher() async {
        fetchCount += 1;
        return const CourseScheduleData(items: <CourseScheduleItemData>[]);
      }

      await repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        termKey: '2025-1',
        ttl: Duration.zero,
        fetcher: fetcher,
      );
      await repo.getOrFetch(
        now: DateTime(2026, 1, 1, 0, 0, 1),
        termKey: '2025-1',
        ttl: Duration.zero,
        fetcher: fetcher,
      );

      expect(fetchCount, 2);
    });

    test('refresh forces refetch and updates termKey', () async {
      int fetchCount = 0;
      Future<CourseScheduleData> fetcher() async {
        fetchCount += 1;
        return const CourseScheduleData(items: <CourseScheduleItemData>[]);
      }

      await repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        termKey: '2025-1',
        fetcher: fetcher,
      );
      await repo.refresh(
        now: DateTime(2026, 1, 1, 0, 0, 1),
        termKey: '2025-2',
        fetcher: fetcher,
      );

      final CourseScheduleCacheMeta? meta =
          await repo.getCachedMeta(refreshFromStorage: true);
      expect(fetchCount, 2);
      expect(meta?.termKey, '2025-2');
    });

    test('concurrent refresh shares the same in-flight fetch', () async {
      int fetchCount = 0;
      Future<CourseScheduleData> fetcher() async {
        fetchCount += 1;
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return const CourseScheduleData(items: <CourseScheduleItemData>[]);
      }

      final List<CourseScheduleData> result = await Future.wait([
        repo.refresh(
          now: DateTime(2026, 1, 1),
          termKey: '2025-1',
          fetcher: fetcher,
        ),
        repo.refresh(
          now: DateTime(2026, 1, 1),
          termKey: '2025-1',
          fetcher: fetcher,
        ),
      ]);

      expect(fetchCount, 1);
      expect(result.length, 2);
    });

    test('different termKey refreshes do not share an in-flight fetch',
        () async {
      final Completer<void> firstFetchStarted = Completer<void>();
      final Completer<void> releaseFirstFetch = Completer<void>();
      int firstFetchCount = 0;
      int secondFetchCount = 0;

      final Future<CourseScheduleData> firstRequest = repo.refresh(
        now: DateTime(2026, 1, 1),
        termKey: '2025-1',
        fetcher: () async {
          firstFetchCount += 1;
          firstFetchStarted.complete();
          await releaseFirstFetch.future;
          return const CourseScheduleData(items: <CourseScheduleItemData>[]);
        },
      );
      await firstFetchStarted.future;

      final Future<CourseScheduleData> secondRequest = repo.refresh(
        now: DateTime(2026, 1, 1),
        termKey: '2025-2',
        fetcher: () async {
          secondFetchCount += 1;
          return const CourseScheduleData(items: <CourseScheduleItemData>[]);
        },
      );
      releaseFirstFetch.complete();

      await Future.wait(<Future<CourseScheduleData>>[
        firstRequest,
        secondRequest,
      ]);

      final CourseScheduleCacheMeta? meta =
          await repo.getCachedMeta(refreshFromStorage: true);
      expect(firstFetchCount, 1);
      expect(secondFetchCount, 1);
      expect(meta?.termKey, '2025-2');
    });

    test('null and non-null termKeys do not share an in-flight fetch',
        () async {
      final Completer<void> firstFetchStarted = Completer<void>();
      final Completer<void> releaseFirstFetch = Completer<void>();
      int firstFetchCount = 0;
      int secondFetchCount = 0;

      final Future<CourseScheduleData> firstRequest = repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        fetcher: () async {
          firstFetchCount += 1;
          firstFetchStarted.complete();
          await releaseFirstFetch.future;
          return const CourseScheduleData(items: <CourseScheduleItemData>[]);
        },
      );
      await firstFetchStarted.future;

      final Future<CourseScheduleData> secondRequest = repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        termKey: '2025-1',
        fetcher: () async {
          secondFetchCount += 1;
          return const CourseScheduleData(items: <CourseScheduleItemData>[]);
        },
      );
      releaseFirstFetch.complete();

      await Future.wait(<Future<CourseScheduleData>>[
        firstRequest,
        secondRequest,
      ]);

      final CourseScheduleCacheMeta? meta =
          await repo.getCachedMeta(refreshFromStorage: true);
      expect(firstFetchCount, 1);
      expect(secondFetchCount, 1);
      expect(meta?.termKey, '2025-1');
    });

    test('clearCache clears data and meta', () async {
      await repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        termKey: '2025-1',
        fetcher: () async =>
            const CourseScheduleData(items: <CourseScheduleItemData>[]),
      );

      await repo.clearCache();

      expect(await repo.getCached(refreshFromStorage: true), isNull);
      expect(await repo.getCachedMeta(refreshFromStorage: true), isNull);
    });

    test('warmUp loads data and meta from storage', () async {
      await storage
          .save(const CourseScheduleData(items: <CourseScheduleItemData>[]));
      await storage.saveMeta(
        const CourseScheduleCacheMeta(
          lastFetchedAtMillis: 1000,
          termKey: '2025-1',
        ),
      );

      await repo.warmUp();

      final CourseScheduleData? data = await repo.getCached();
      final CourseScheduleCacheMeta? meta = await repo.getCachedMeta();
      expect(data, isNotNull);
      expect(meta?.termKey, '2025-1');
    });
  });
}
