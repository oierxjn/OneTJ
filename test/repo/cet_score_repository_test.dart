import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/models/cet_score_data.dart';
import 'package:onetj/repo/cet_score_repository.dart';

CetScoreData buildCetScoreData({String score = '520'}) {
  return CetScoreData(
    records: <CetScoreRecordData>[
      CetScoreRecordData(
        cetType: '1',
        termName: '2025年12月',
        score: score,
        ticketNumber: '123456',
        studentName: '张三',
        studentId: '12345678',
        subjectName: '英语四级',
        oralScore: 'A',
      ),
    ],
  );
}

void main() {
  group('CetScoreRepository', () {
    late InMemoryCetScoreStorage storage;
    late CetScoreRepository repository;

    setUp(() {
      storage = InMemoryCetScoreStorage();
      repository = CetScoreRepository(storage: storage);
    });

    test('returns cached data while it is within the default ttl', () async {
      int fetchCount = 0;
      Future<CetScoreData> fetcher() async {
        fetchCount += 1;
        return buildCetScoreData(score: '5$fetchCount');
      }

      await repository.getOrFetch(
        now: DateTime(2026, 1, 1),
        fetcher: fetcher,
      );
      final CetScoreData second = await repository.getOrFetch(
        now: DateTime(2026, 1, 2),
        fetcher: fetcher,
      );

      expect(fetchCount, 1);
      expect(second.records.single.score, '51');
    });

    test('clears in-memory and persisted data', () async {
      await repository.getOrFetch(
        now: DateTime(2026, 1, 1),
        fetcher: () async => buildCetScoreData(),
      );
      await repository.flush();

      await repository.clearCache();

      expect(await repository.getCached(), isNull);
      expect(await storage.read(), isNull);
    });
    test('refreshes data and persists the new value', () async {
      await repository.getOrFetch(
        now: DateTime(2026, 1, 1),
        fetcher: () async => buildCetScoreData(score: '500'),
      );

      final CetScoreData refreshed = await repository.refresh(
        now: DateTime(2026, 1, 2),
        fetcher: () async => buildCetScoreData(score: '600'),
      );

      await repository.flush();
      expect(refreshed.records.single.score, '600');
      expect((await storage.read())?.records.single.score, '600');
    });
  });
}
