import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/cet_score/application/cet_score_data_service.dart';
import 'package:onetj/features/grades/application/grades_data_service.dart';
import 'package:onetj/features/settings/application/logout_service.dart';
import 'package:onetj/features/settings/models/logout_result.dart';
import 'package:onetj/features/student_exams/application/student_exam_data_service.dart';
import 'package:onetj/models/cet_score_data.dart';
import 'package:onetj/models/undergraduate_score_data.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/webview_environment_service.dart';

/// 可注入失败的清理步骤替身：记录是否被调用。
class _CleanupStep {
  _CleanupStep({this.error});

  final Object? error;
  bool called = false;

  Future<void> run() async {
    called = true;
    if (error != null) {
      throw error!;
    }
  }
}

class _FakeCetScoreDataService implements CetScoreDataService {
  _FakeCetScoreDataService(this.step);

  final _CleanupStep step;

  @override
  Future<CetScoreData> load() async => throw UnimplementedError();

  @override
  Future<CetScoreData> refresh() async => throw UnimplementedError();

  @override
  Future<void> clearCachedData() => step.run();
}

class _FakeGradesDataService implements GradesDataService {
  _FakeGradesDataService(this.step);

  final _CleanupStep step;

  @override
  Future<UndergraduateScoreData> fetchUndergraduateScore({int? calendarId}) =>
      throw UnimplementedError();

  @override
  Future<UndergraduateScoreData> getUndergraduateScore() async =>
      throw UnimplementedError();

  @override
  Future<void> warmUpCache() async {}

  @override
  Future<void> clearCachedData() => step.run();

  @override
  Future<UndergraduateScoreData> refreshUndergraduateScore() async =>
      throw UnimplementedError();
}

class _FakeStudentExamDataService implements StudentExamDataService {
  _FakeStudentExamDataService(this.step);

  final _CleanupStep step;

  @override
  Future<StudentExamLoadResult> load() async => throw UnimplementedError();

  @override
  Future<StudentExamLoadResult> refresh() async => throw UnimplementedError();

  @override
  Future<void> clearCachedData() => step.run();
}

void main() {
  late _CleanupStep tokenStep;
  late _CleanupStep studentInfoStep;
  late _CleanupStep calendarStep;
  late _CleanupStep courseStep;
  late _CleanupStep cetStep;
  late _CleanupStep gradesStep;
  late _CleanupStep examStep;
  late _CleanupStep cookieStep;
  late SessionController session;
  late LogoutService service;

  /// 用可注入失败的步骤替身装配登出服务；会话先发布为已登录。
  LogoutService buildService() {
    return LogoutService(
      tokenRepository: TokenRepository(storage: InMemoryTokenStorage()),
      studentInfoRepository:
          StudentInfoRepository(storage: InMemoryStudentInfoStorage()),
      schoolCalendarRepository:
          SchoolCalendarRepository(storage: InMemorySchoolCalendarStorage()),
      courseScheduleRepository:
          CourseScheduleRepository(storage: InMemoryCourseScheduleStorage()),
      cetScoreDataService: _FakeCetScoreDataService(cetStep),
      gradesDataService: _FakeGradesDataService(gradesStep),
      studentExamDataService: _FakeStudentExamDataService(examStep),
      webViewEnvironmentService: WebViewEnvironmentService(),
      sessionController: session,
      clearTokenOverride: tokenStep.run,
      clearStudentInfoOverride: studentInfoStep.run,
      clearSchoolCalendarOverride: calendarStep.run,
      clearCourseScheduleOverride: courseStep.run,
      clearCookiesOverride: cookieStep.run,
    );
  }

  setUp(() {
    tokenStep = _CleanupStep();
    studentInfoStep = _CleanupStep();
    calendarStep = _CleanupStep();
    courseStep = _CleanupStep();
    cetStep = _CleanupStep();
    gradesStep = _CleanupStep();
    examStep = _CleanupStep();
    cookieStep = _CleanupStep();
    session = SessionController()..completeBoot(AuthStatus.authenticated);
    service = buildService();
  });

  group('LogoutService.clearSession 成功路径', () {
    test('全部清理成功：进入游客态，结果无残留失败', () async {
      final LogoutResult result = await service.clearSession();

      expect(session.status, AuthStatus.guest);
      expect(session.lastReason, 'sign_out');
      expect(result.isFullyClean, isTrue);
      expect(tokenStep.called, isTrue);
      expect(cookieStep.called, isTrue);
    });
  });

  group('LogoutService.clearSession 部分失败路径', () {
    test('Cookie 清理失败：其余步骤仍执行，状态仍翻转为游客态', () async {
      cookieStep = _CleanupStep(error: StateError('cookie platform error'));
      service = buildService();

      final LogoutResult result = await service.clearSession();

      expect(session.status, AuthStatus.guest);
      expect(result.isFullyClean, isFalse);
      expect(result.residualFailures.keys, contains('cookies'));
      expect(examStep.called, isTrue);
    });

    test('中间缓存清理失败：不中断后续步骤，失败被记入结果', () async {
      calendarStep = _CleanupStep(error: StateError('disk full'));
      gradesStep = _CleanupStep(error: StateError('box closed'));
      service = buildService();

      final LogoutResult result = await service.clearSession();

      expect(session.status, AuthStatus.guest);
      expect(result.residualFailures.keys,
          containsAll(<String>['schoolCalendar', 'grades']));
      expect(courseStep.called, isTrue);
      expect(cetStep.called, isTrue);
      expect(examStep.called, isTrue);
      expect(cookieStep.called, isTrue);
    });

    test('全部尽力步骤失败：状态仍翻转，结果记录所有失败', () async {
      studentInfoStep = _CleanupStep(error: StateError('e1'));
      calendarStep = _CleanupStep(error: StateError('e2'));
      courseStep = _CleanupStep(error: StateError('e3'));
      cetStep = _CleanupStep(error: StateError('e4'));
      gradesStep = _CleanupStep(error: StateError('e5'));
      examStep = _CleanupStep(error: StateError('e6'));
      cookieStep = _CleanupStep(error: StateError('e7'));
      service = buildService();

      final LogoutResult result = await service.clearSession();

      expect(session.status, AuthStatus.guest);
      expect(result.residualFailures.length, 7);
    });
  });

  group('LogoutService.clearSession 关键步骤失败', () {
    test('token 清理失败：异常上抛，状态不变，后续步骤不执行', () async {
      tokenStep = _CleanupStep(error: StateError('token store locked'));
      service = buildService();

      await expectLater(
        service.clearSession(),
        throwsA(isA<StateError>()),
      );

      expect(session.status, AuthStatus.authenticated);
      expect(studentInfoStep.called, isFalse);
      expect(cookieStep.called, isFalse);
    });
  });

  group('LogoutService.clearLocalSessionData（游客路径复用）', () {
    test('成功时不翻转会话状态，由调用方自行决定', () async {
      final LogoutResult result = await service.clearLocalSessionData();

      expect(result.isFullyClean, isTrue);
      expect(session.status, AuthStatus.authenticated);
    });

    test('token 清理失败时异常上抛且不翻转状态', () async {
      tokenStep = _CleanupStep(error: StateError('token store locked'));
      service = buildService();

      await expectLater(
        service.clearLocalSessionData(),
        throwsA(isA<StateError>()),
      );

      expect(session.status, AuthStatus.authenticated);
    });
  });
}
