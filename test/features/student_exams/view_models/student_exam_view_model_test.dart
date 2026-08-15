import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/features/student_exams/application/student_exam_data_service.dart';
import 'package:onetj/features/student_exams/models/student_exam_view_data.dart';
import 'package:onetj/features/student_exams/view_models/student_exam_view_model.dart';
import 'package:onetj/models/student_exam_data.dart';

class _FakeStudentExamDataSource implements StudentExamDataSource {
  _FakeStudentExamDataSource({
    this.loadResult,
    this.loadError,
  });

  StudentExamData? loadResult;
  Object? loadError;

  @override
  Future<StudentExamData> load() async {
    if (loadError != null) throw loadError!;
    return loadResult!;
  }

  @override
  Future<StudentExamData> refresh() async => loadResult!;
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
      dataSource:
          _FakeStudentExamDataSource(loadResult: buildStudentExamData()),
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

  test('load reports errors through UiEvent', () async {
    final StudentExamViewModel viewModel = StudentExamViewModel(
      dataSource: _FakeStudentExamDataSource(loadError: StateError('offline')),
    );
    final Future<UiEvent> event = viewModel.events.first;

    await viewModel.load();

    expect(viewModel.loading, isFalse);
    expect(viewModel.records, isEmpty);
    expect(await event, isA<ShowSnackBarEvent>());
    viewModel.dispose();
  });
}
