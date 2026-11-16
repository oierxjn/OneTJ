import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/cet_score/application/cet_score_data_service.dart';
import 'package:onetj/features/grades/application/grades_data_service.dart';
import 'package:onetj/features/settings/application/logout_service.dart';
import 'package:onetj/features/settings/models/logout_result.dart';
// LogoutCleanupException 由 logout_service.dart 导出。
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

    test('缓存先于令牌清理（令牌是最后的关键步骤）', () async {
      final List<String> order = <String>[];
      studentInfoStep = _CleanupStep();
      tokenStep = _CleanupStep();
      service = LogoutService(
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
        clearTokenOverride: () async {
          order.add('token');
          await tokenStep.run();
        },
        clearStudentInfoOverride: () async {
          order.add('studentInfo');
          await studentInfoStep.run();
        },
        clearSchoolCalendarOverride: calendarStep.run,
        clearCourseScheduleOverride: courseStep.run,
        clearCookiesOverride: cookieStep.run,
      );

      await service.clearSession();

      expect(order, <String>['studentInfo', 'token']);
    });
  });

  group('LogoutService.clearSession 缓存清理失败：不允许登出', () {
    test('任一缓存失败：异常上抛，令牌未动，状态保持已登录', () async {
      calendarStep = _CleanupStep(error: StateError('disk full'));
      service = buildService();

      await expectLater(
        service.clearSession(),
        throwsA(isA<LogoutCleanupException>()),
      );

      expect(session.status, AuthStatus.authenticated);
      expect(tokenStep.called, isFalse);
      expect(cookieStep.called, isFalse);
    });

    test('多项缓存失败：收集全部失败后上抛，令牌仍未动', () async {
      studentInfoStep = _CleanupStep(error: StateError('e1'));
      gradesStep = _CleanupStep(error: StateError('e2'));
      service = buildService();

      await expectLater(
        service.clearSession(),
        throwsA(isA<LogoutCleanupException>()),
      );

      expect(session.status, AuthStatus.authenticated);
      expect(tokenStep.called, isFalse);
      // 失败不中断其余缓存步骤，便于一次重试清完。
      expect(calendarStep.called, isTrue);
      expect(examStep.called, isTrue);
    });
  });

  group('LogoutService.clearSession 令牌清理失败', () {
    test('缓存已清但令牌删除失败：异常上抛，状态保持已登录', () async {
      tokenStep = _CleanupStep(error: StateError('token store locked'));
      service = buildService();

      await expectLater(
        service.clearSession(),
        throwsA(isA<StateError>()),
      );

      expect(session.status, AuthStatus.authenticated);
      expect(studentInfoStep.called, isTrue);
      expect(cookieStep.called, isFalse);
    });
  });

  group('LogoutService.clearSession Cookie 失败：降级放行', () {
    test('Cookie 失败不阻塞登出：状态翻转，失败记入结果', () async {
      cookieStep = _CleanupStep(error: StateError('cookie platform error'));
      service = buildService();

      final LogoutResult result = await service.clearSession();

      expect(session.status, AuthStatus.guest);
      expect(result.isFullyClean, isFalse);
      expect(result.residualFailures.keys, <String>['cookies']);
      expect(tokenStep.called, isTrue);
    });
  });

  group('LogoutService.clearLocalSessionData（游客路径复用）', () {
    test('成功时不翻转会话状态，由调用方自行决定', () async {
      final LogoutResult result = await service.clearLocalSessionData();

      expect(result.isFullyClean, isTrue);
      expect(session.status, AuthStatus.authenticated);
    });

    test('缓存清理失败时异常上抛且不翻转状态，令牌未动', () async {
      cetStep = _CleanupStep(error: StateError('box closed'));
      service = buildService();

      await expectLater(
        service.clearLocalSessionData(),
        throwsA(isA<LogoutCleanupException>()),
      );

      expect(session.status, AuthStatus.authenticated);
      expect(tokenStep.called, isFalse);
    });

    test('令牌删除失败时异常上抛且不翻转状态', () async {
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
