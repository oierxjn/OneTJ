import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/repo/undergraduate_score_repository.dart';

UndergraduateScoreData buildUndergraduateScore({String? totalGradePoint}) {
  return UndergraduateScoreData(
    totalGradePoint: totalGradePoint ?? '3.80',
    actualCredit: '24',
    failingCredits: '0',
    failingCourseCount: '0',
    term: <UndergraduateScoreTermData>[
      UndergraduateScoreTermData(
        termcode: '2025-1',
        termName: '2025-2026-1',
        calName: '2025 Fall',
        averagePoint: '3.8',
        creditInfo: <UndergraduateScoreCreditInfoData>[
          UndergraduateScoreCreditInfoData(
            id: 1,
            year: '2025',
            term: 1,
            calName: '2025 Fall',
            studentId: '20250001',
            studentName: 'Test User',
            courseCode: 'CS101',
            courseName: 'Programming',
            score: '95',
            gradePoint: 4,
            isPass: 1,
            credit: 4,
          ),
        ],
      ),
    ],
  );
}

void main() {
  group('UndergraduateScoreRepository', () {
    late InMemoryUndergraduateScoreStorage storage;
    late UndergraduateScoreRepository repo;

    setUp(() {
      UndergraduateScoreRepository.resetInstanceForTest();
      storage = InMemoryUndergraduateScoreStorage();
      repo = UndergraduateScoreRepository.getInstance(storage: storage);
    });

    test('fetches and caches data on first getOrFetch', () async {
      int fetchCount = 0;
      final UndergraduateScoreData data = await repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        versionKey: 'v1',
        fetcher: () async {
          fetchCount += 1;
          return buildUndergraduateScore();
        },
      );

      final UndergraduateScoreCacheMeta? meta =
          await repo.getCachedMeta(refreshFromStorage: true);

      expect(fetchCount, 1);
      expect(data.totalGradePoint, '3.80');
      expect(meta?.versionKey, 'v1');
      expect(
        meta?.lastFetchedAtMillis,
        DateTime(2026, 1, 1).millisecondsSinceEpoch,
      );
    });

    test('does not refetch when versionKey unchanged and ttl valid', () async {
      int fetchCount = 0;
      Future<UndergraduateScoreData> fetcher() async {
        fetchCount += 1;
        return buildUndergraduateScore();
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
      Future<UndergraduateScoreData> fetcher() async {
        fetchCount += 1;
        return buildUndergraduateScore(totalGradePoint: '3.8$fetchCount');
      }

      await repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        versionKey: 'v1',
        fetcher: fetcher,
      );
      final UndergraduateScoreData second = await repo.getOrFetch(
        now: DateTime(2026, 1, 2),
        versionKey: 'v2',
        fetcher: fetcher,
      );

      final UndergraduateScoreCacheMeta? meta =
          await repo.getCachedMeta(refreshFromStorage: true);
      expect(fetchCount, 2);
      expect(second.totalGradePoint, '3.82');
      expect(meta?.versionKey, 'v2');
    });

    test('ttl zero forces refetch', () async {
      int fetchCount = 0;
      Future<UndergraduateScoreData> fetcher() async {
        fetchCount += 1;
        return buildUndergraduateScore();
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
      Future<UndergraduateScoreData> fetcher() async {
        fetchCount += 1;
        return buildUndergraduateScore(totalGradePoint: '3.8$fetchCount');
      }

      await repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        versionKey: 'v1',
        fetcher: fetcher,
      );
      final UndergraduateScoreData refreshed = await repo.refresh(
        now: DateTime(2026, 1, 1, 0, 0, 1),
        versionKey: 'v2',
        fetcher: fetcher,
      );

      final UndergraduateScoreCacheMeta? meta =
          await repo.getCachedMeta(refreshFromStorage: true);
      expect(fetchCount, 2);
      expect(refreshed.totalGradePoint, '3.82');
      expect(meta?.versionKey, 'v2');
    });

    test('concurrent refresh shares the same in-flight fetch', () async {
      int fetchCount = 0;
      Future<UndergraduateScoreData> fetcher() async {
        fetchCount += 1;
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return buildUndergraduateScore();
      }

      final List<UndergraduateScoreData> result = await Future.wait([
        repo.refresh(
          now: DateTime(2026, 1, 1),
          versionKey: 'v1',
          fetcher: fetcher,
        ),
        repo.refresh(
          now: DateTime(2026, 1, 1),
          versionKey: 'v1',
          fetcher: fetcher,
        ),
      ]);

      expect(fetchCount, 1);
      expect(result.length, 2);
    });

    test('clearCache clears data and meta', () async {
      await repo.getOrFetch(
        now: DateTime(2026, 1, 1),
        versionKey: 'v1',
        fetcher: () async => buildUndergraduateScore(),
      );

      await repo.clearCache();

      expect(await repo.getCached(refreshFromStorage: true), isNull);
      expect(await repo.getCachedMeta(refreshFromStorage: true), isNull);
    });

    test('warmUp loads data and meta from storage', () async {
      await storage.save(buildUndergraduateScore(totalGradePoint: '3.90'));
      await storage.saveMeta(
        const UndergraduateScoreCacheMeta(
          lastFetchedAtMillis: 1000,
          versionKey: 'v1',
        ),
      );

      await repo.warmUp();

      final UndergraduateScoreData? data = await repo.getCached();
      final UndergraduateScoreCacheMeta? meta = await repo.getCachedMeta();
      expect(data?.totalGradePoint, '3.90');
      expect(meta?.versionKey, 'v1');
    });

    test('concurrent getOrFetch shares the same in-flight fetch', () async {
      int fetchCount = 0;
      Future<UndergraduateScoreData> fetcher() async {
        fetchCount += 1;
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return buildUndergraduateScore();
      }

      final List<UndergraduateScoreData> result = await Future.wait([
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
      expect(result.length, 2);
      expect(result[0].actualCredit, '24');
      expect(result[1].actualCredit, '24');
    });
  });
}
