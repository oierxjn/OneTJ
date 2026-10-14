import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/models/student_info_data.dart';
import 'package:onetj/repo/student_info_repository.dart';

import 'student_info_fixtures.dart';

void main() {
  group('StudentInfoRepository', () {
    late InMemoryStudentInfoStorage storage;
    late StudentInfoRepository repo;

    setUp(() {
      storage = InMemoryStudentInfoStorage();
      repo = StudentInfoRepository(storage: storage);
    });

    test('fetches and caches data on first getOrFetch', () async {
      int fetchCount = 0;
      final StudentInfoData data = await repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        versionKey: 'v1',
        fetcher: () async {
          fetchCount += 1;
          return buildStudentInfo();
        },
      );

      // 持久化是 fire-and-forget，断言落盘结果前须显式等队列排空。
      await repo.flush();

      final StudentInfoCacheMeta? meta =
          await repo.getCachedMeta(refreshFromStorage: true);

      expect(fetchCount, 1);
      expect(data.deptName, 'Computer Science');
      expect(meta?.versionKey, 'v1');
      expect(
        meta?.lastFetchedAtMillis,
        DateTime(2026, 1, 1).millisecondsSinceEpoch,
      );
    });

    test('does not refetch when versionKey unchanged and ttl valid', () async {
      int fetchCount = 0;
      Future<StudentInfoData> fetcher() async {
        fetchCount += 1;
        return buildStudentInfo();
      }

      await repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        versionKey: 'v1',
        fetcher: fetcher,
      );
      await repo.getOrFetch(
        now: DateTime(2026, 1, 2),
        versionKey: 'v1',
        fetcher: fetcher,
      );

      expect(fetchCount, 1);
    });

    test('refetches when versionKey changes even before ttl expires', () async {
      int fetchCount = 0;
      Future<StudentInfoData> fetcher() async {
        fetchCount += 1;
        return buildStudentInfo(deptName: 'Dept $fetchCount');
      }

      await repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        versionKey: 'v1',
        fetcher: fetcher,
      );
      final StudentInfoData second = await repo.getOrFetch(
        now: DateTime(2026, 1, 2),
        versionKey: 'v2',
        fetcher: fetcher,
      );

      // 持久化是 fire-and-forget，断言落盘结果前须显式等队列排空。
      await repo.flush();

      final StudentInfoCacheMeta? meta =
          await repo.getCachedMeta(refreshFromStorage: true);
      expect(fetchCount, 2);
      expect(second.deptName, 'Dept 2');
      expect(meta?.versionKey, 'v2');
    });

    test('ttl zero forces refetch', () async {
      int fetchCount = 0;
      Future<StudentInfoData> fetcher() async {
        fetchCount += 1;
        return buildStudentInfo();
      }

      await repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        versionKey: 'v1',
        ttl: Duration.zero,
        fetcher: fetcher,
      );
      await repo.getOrFetch(
        now: DateTime(2026, 1, 1, 0, 0, 1),
        versionKey: 'v1',
        ttl: Duration.zero,
        fetcher: fetcher,
      );

      expect(fetchCount, 2);
    });

    test('refresh forces refetch and updates versionKey', () async {
      int fetchCount = 0;
      Future<StudentInfoData> fetcher() async {
        fetchCount += 1;
        return buildStudentInfo(deptName: 'Dept $fetchCount');
      }

      await repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        versionKey: 'v1',
        fetcher: fetcher,
      );
      final StudentInfoData refreshed = await repo.refresh(
        now: DateTime(2026, 1, 1, 0, 0, 1),
        versionKey: 'v2',
        fetcher: fetcher,
      );

      // 持久化是 fire-and-forget，断言落盘结果前须显式等队列排空。
      await repo.flush();

      final StudentInfoCacheMeta? meta =
          await repo.getCachedMeta(refreshFromStorage: true);
      expect(fetchCount, 2);
      expect(refreshed.deptName, 'Dept 2');
      expect(meta?.versionKey, 'v2');
    });

    test('clearCache clears data and meta', () async {
      await repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        versionKey: 'v1',
        fetcher: () async => buildStudentInfo(),
      );

      await repo.clearCache();

      expect(await repo.getCached(refreshFromStorage: true), isNull);
      expect(await repo.getCachedMeta(refreshFromStorage: true), isNull);
    });

    test('warmUp loads data and meta from storage', () async {
      await storage.save(buildStudentInfo(deptName: 'Stored Dept'));
      await storage.saveMeta(
        const StudentInfoCacheMeta(
          lastFetchedAtMillis: 1000,
          versionKey: 'v1',
        ),
      );

      await repo.warmUp();

      final StudentInfoData? data = await repo.getCached();
      final StudentInfoCacheMeta? meta = await repo.getCachedMeta();
      expect(data?.deptName, 'Stored Dept');
      expect(meta?.versionKey, 'v1');
    });

    test('concurrent getOrFetch shares the same in-flight fetch', () async {
      int fetchCount = 0;
      Future<StudentInfoData> fetcher() async {
        fetchCount += 1;
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return buildStudentInfo();
      }

      final List<StudentInfoData> data = await Future.wait([
        repo.getOrFetch(
          now: DateTime(2026, 1, 1),
          versionKey: 'v1',
          fetcher: fetcher,
        ),
        repo.getOrFetch(
          now: DateTime(2026, 1, 1),
          versionKey: 'v1',
          fetcher: fetcher,
        ),
      ]);

      expect(fetchCount, 1);
      expect(data.length, 2);
      expect(data[0].deptCode, 'CS');
      expect(data[1].deptCode, 'CS');
    });
  });
}
