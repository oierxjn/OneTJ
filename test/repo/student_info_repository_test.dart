import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/repo/student_info_repository.dart';

StudentInfoData buildStudentInfo({String deptName = 'Computer Science'}) {
  return StudentInfoData(
    campusCode: '01',
    campusName: 'Main Campus',
    createTime: '2026-01-01 00:00:00',
    currentGrade: 2022,
    deptCode: 'CS',
    deptName: deptName,
    enrolDate: '2022-09-01',
    expGraduationDate: '2026-06-30',
    isIncumbencyCode: null,
    isIncumbencyName: null,
    isMembershipCode: '0',
    isMembershipName: 'No',
    isOverseasCode: '0',
    isOverseasName: 'No',
    leaveSchoolCode: '0',
    leaveSchoolName: 'In School',
    lengthSchooling: '4',
    managementCollege2Code: null,
    managementCollege2Name: null,
    name: 'Test User',
    offSchool: null,
    politicalStatusCode: '01',
    politicalStatusName: '群众',
    registrationStatusCode: '1',
    registrationStatusName: 'Registered',
    schoolCode: 'SDU',
    schoolName: 'Shandong University',
    secondDeptCode: 'CS',
    secondDeptName: 'Computer Science',
    sexCode: '1',
    sexName: 'Male',
    statusCode: '1',
    statusName: 'Normal',
    teacherId: 'T001',
    trainingCategoryCode: 'A',
    trainingCategoryName: 'General',
    trainingLevelCode: 'UG',
    trainingLevelName: 'Undergraduate',
    updateTime: '2026-01-01 00:00:00',
    userId: 'U001',
    userTypeCode: 'STU',
    userTypeName: 'Student',
    viceTeacherId: null,
  );
}

void main() {
  group('StudentInfoRepository', () {
    late InMemoryStudentInfoStorage storage;
    late StudentInfoRepository repo;

    setUp(() {
      StudentInfoRepository.resetInstanceForTest();
      storage = InMemoryStudentInfoStorage();
      repo = StudentInfoRepository.getInstance(storage: storage);
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
