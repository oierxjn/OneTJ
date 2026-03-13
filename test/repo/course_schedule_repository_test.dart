import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/repo/course_schedule_repository.dart';

void main() {
  group('CourseScheduleRepository', () {
    late InMemoryCourseScheduleStorage storage;
    late CourseScheduleRepository repo;

    setUp(() {
      CourseScheduleRepository.resetInstanceForTest();
      storage = InMemoryCourseScheduleStorage();
      repo = CourseScheduleRepository.getInstance(storage: storage);
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
