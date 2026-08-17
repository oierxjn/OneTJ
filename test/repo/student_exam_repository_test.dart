import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/models/student_exam_data.dart';
import 'package:onetj/repo/student_exam_repository.dart';

StudentExamData buildStudentExamData({String courseName = '高等数学'}) {
  return StudentExamData(
    records: <StudentExamRecordData>[
      StudentExamRecordData(
        termName: '2026-2027学年第一学期',
        courseName: courseName,
        courseCode: 'MATH1001',
        roomName: '南楼101',
        examTime: '2026-12-30 08:00-10:00',
        remark: '闭卷考试',
        examSituation: 1,
      ),
    ],
  );
}

void main() {
  test('returns an in-memory payload when its cache is still fresh', () async {
    final StudentExamRepository repository = StudentExamRepository(
      storage: InMemoryStudentExamStorage(),
    );
    final StudentExamData expected = buildStudentExamData();
    var fetchCount = 0;

    final StudentExamData first = await repository.getOrFetch(
      now: DateTime(2026, 8, 15, 10),
      ttl: const Duration(hours: 6),
      fetcher: () async {
        fetchCount += 1;
        return expected;
      },
    );
    final StudentExamData second = await repository.getOrFetch(
      now: DateTime(2026, 8, 15, 12),
      ttl: const Duration(hours: 6),
      fetcher: () async {
        fetchCount += 1;
        return buildStudentExamData(courseName: '不应请求');
      },
    );

    expect(first.records.single.courseName, '高等数学');
    expect(second.records.single.courseName, '高等数学');
    expect(fetchCount, 1);
  });

  test('persists and restores the latest successful payload', () async {
    final InMemoryStudentExamStorage storage = InMemoryStudentExamStorage();
    final StudentExamRepository firstRepository =
        StudentExamRepository(storage: storage);
    final StudentExamData expected = buildStudentExamData();

    await firstRepository.refresh(
      now: DateTime(2026, 8, 15, 10),
      fetcher: () async => expected,
    );

    final StudentExamRepository restoredRepository =
        StudentExamRepository(storage: storage);
    await restoredRepository.warmUp();

    expect(
      (await restoredRepository.getCached())?.records.single.courseName,
      '高等数学',
    );
    expect(
      (await restoredRepository.getCachedMeta())?.lastFetchedAtMillis,
      DateTime(2026, 8, 15, 10).millisecondsSinceEpoch,
    );
  });
}
