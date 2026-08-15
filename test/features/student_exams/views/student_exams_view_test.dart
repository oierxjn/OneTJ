import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/features/student_exams/application/student_exam_data_service.dart';
import 'package:onetj/features/student_exams/view_models/student_exam_view_model.dart';
import 'package:onetj/features/student_exams/views/student_exams_view.dart';
import 'package:onetj/l10n/app_localizations.dart';
import 'package:onetj/models/student_exam_data.dart';

class _FakeStudentExamDataSource implements StudentExamDataSource {
  const _FakeStudentExamDataSource(this.loadResult);

  final StudentExamLoadResult loadResult;

  @override
  Future<StudentExamLoadResult> load() async => loadResult;

  @override
  Future<StudentExamLoadResult> refresh() async => loadResult;
}

StudentExamData buildStudentExamData() {
  return const StudentExamData(
    records: <StudentExamRecordData>[
      StudentExamRecordData(
        termName: '2026-2027学年第一学期',
        courseName: '大学物理',
        courseCode: 'PHYS1001',
        roomName: '北楼204',
        examTime: '2026-12-25 08:00-10:00',
        remark: '请携带计算器',
        examSituation: 1,
      ),
      StudentExamRecordData(
        termName: '2026-2027学年第一学期',
        courseName: '课程作业',
        courseCode: 'HOME1001',
        roomName: null,
        examTime: null,
        remark: '提交报告',
        examSituation: 0,
      ),
    ],
  );
}

Widget buildSubject({bool latestFetchFailed = false}) {
  return MaterialApp(
    locale: const Locale('zh'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: StudentExamsView(
      viewModel: StudentExamViewModel(
        dataSource: _FakeStudentExamDataSource(
          StudentExamLoadResult(
            data: buildStudentExamData(),
            latestFetchFailed: latestFetchFailed,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('展示考试安排和非正式安排的关键字段', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('我的考试'), findsOneWidget);
    expect(find.textContaining('2026-2027学年第一学期'), findsOneWidget);
    expect(find.text('大学物理'), findsOneWidget);
    expect(find.text('课程作业'), findsOneWidget);
    expect(find.text('正式考试'), findsOneWidget);
    expect(find.text('课程安排'), findsOneWidget);
    expect(find.text('PHYS1001'), findsOneWidget);
    expect(find.text('北楼204'), findsOneWidget);
    expect(find.text('请携带计算器'), findsOneWidget);
  });

  testWidgets('最新拉取失败时显示缓存数据警示', (tester) async {
    await tester.pumpWidget(buildSubject(latestFetchFailed: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('大学物理'), findsOneWidget);
    expect(
      find.text('最新考试安排拉取失败，当前显示的是缓存数据。'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
  });
}
