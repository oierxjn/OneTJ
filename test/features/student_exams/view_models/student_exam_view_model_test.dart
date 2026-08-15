import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/student_exams/application/student_exam_data_service.dart';
import 'package:onetj/features/student_exams/models/student_exam_view_data.dart';
import 'package:onetj/features/student_exams/view_models/student_exam_view_model.dart';
import 'package:onetj/models/student_exam_data.dart';

class _FakeStudentExamDataSource implements StudentExamDataSource {
  _FakeStudentExamDataSource({
    this.loadResult,
    this.loadError,
    this.refreshError,
  });

  StudentExamLoadResult? loadResult;
  Object? loadError;
  Object? refreshError;

  @override
  Future<StudentExamLoadResult> load() async {
    if (loadError != null) throw loadError!;
    return loadResult!;
  }

  @override
  Future<StudentExamLoadResult> refresh() async {
    if (refreshError != null) throw refreshError!;
    return loadResult!;
  }
}

StudentExamData buildStudentExamData() {
  return const StudentExamData(
    records: <StudentExamRecordData>[
      StudentExamRecordData(
        termName: '2026-2027学年第一学期',
        courseName: '课程作业',
        courseCode: 'HOME1001',
        roomName: null,
        examTime: null,
        remark: '提交报告',
        examSituation: 0,
      ),
      StudentExamRecordData(
        termName: '2026-2027学年第一学期',
        courseName: '高等数学',
        courseCode: 'MATH1001',
        roomName: '南楼101',
        examTime: '2026-12-30 08:00-10:00',
        remark: '闭卷考试',
        examSituation: 1,
      ),
      StudentExamRecordData(
        termName: '2026-2027学年第一学期',
        courseName: '大学物理',
        courseCode: 'PHYS1001',
        roomName: '北楼204',
        examTime: '2026-12-25 08:00-10:00',
        remark: null,
        examSituation: 1,
      ),
    ],
  );
}

void main() {
  test('load sorts formal exams before non-exam arrangements', () async {
    final StudentExamViewModel viewModel = StudentExamViewModel(
      dataSource: _FakeStudentExamDataSource(
        loadResult: StudentExamLoadResult(data: buildStudentExamData()),
      ),
    );

    await viewModel.load();

    expect(viewModel.loading, isFalse);
    expect(
      viewModel.records.map((StudentExamViewRecord item) => item.courseName),
      <String>['大学物理', '高等数学', '课程作业'],
    );
    expect(viewModel.termName, '2026-2027学年第一学期');
    viewModel.dispose();
  });

  test('load emits a cache fallback event when the latest fetch fails',
      () async {
    final StudentExamViewModel viewModel = StudentExamViewModel(
      dataSource: _FakeStudentExamDataSource(
        loadResult: StudentExamLoadResult(
          data: buildStudentExamData(),
          latestFetchFailed: true,
        ),
      ),
    );
    final Future<StudentExamFetchFailedEvent> event = viewModel.events
        .where((event) => event is StudentExamFetchFailedEvent)
        .cast<StudentExamFetchFailedEvent>()
        .first;

    await viewModel.load();

    expect(viewModel.loading, isFalse);
    expect(viewModel.records, isNotEmpty);
    expect((await event).showingCachedData, isTrue);
    viewModel.dispose();
  });

  test('refresh failure preserves current records and emits a retry event',
      () async {
    final _FakeStudentExamDataSource dataSource = _FakeStudentExamDataSource(
      loadResult: StudentExamLoadResult(data: buildStudentExamData()),
      refreshError: StateError('offline'),
    );
    final StudentExamViewModel viewModel = StudentExamViewModel(
      dataSource: dataSource,
    );
    await viewModel.load();
    final Future<StudentExamFetchFailedEvent> event = viewModel.events
        .where((event) => event is StudentExamFetchFailedEvent)
        .cast<StudentExamFetchFailedEvent>()
        .first;

    await viewModel.refresh();

    expect(viewModel.loading, isFalse);
    expect(viewModel.records, isNotEmpty);
    expect((await event).showingCachedData, isFalse);
    viewModel.dispose();
  });

  test('load emits a retry event when no data can be fetched', () async {
    final StudentExamViewModel viewModel = StudentExamViewModel(
      dataSource: _FakeStudentExamDataSource(loadError: StateError('offline')),
    );
    final Future<StudentExamFetchFailedEvent> event = viewModel.events
        .where((event) => event is StudentExamFetchFailedEvent)
        .cast<StudentExamFetchFailedEvent>()
        .first;

    await viewModel.load();

    expect(viewModel.loading, isFalse);
    expect(viewModel.records, isEmpty);
    expect((await event).showingCachedData, isFalse);
    viewModel.dispose();
  });
}
