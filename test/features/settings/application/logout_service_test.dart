import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/cet_score/application/cet_score_data_service.dart';
import 'package:onetj/features/grades/application/grades_data_service.dart';
import 'package:onetj/features/settings/application/logout_service.dart';
import 'package:onetj/features/settings/models/logout_result.dart';
import 'package:onetj/features/student_exams/application/student_exam_data_service.dart';
import 'package:onetj/repo/cet_score_repository.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/student_exam_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/repo/undergraduate_score_repository.dart';
import 'package:onetj/services/auth_token_provider.dart';
import 'package:onetj/services/cookie_clearer.dart';
import 'package:onetj/services/tongji.dart';

/// 可注入清理失败的存储：继承内存实现，仅覆写 clear。
///
/// 失败经真实仓库代码（clearCache/clearToken → 存储）传播到登出编排，
/// 不绕过任何生产逻辑。[order] 记录清理发生顺序。
class _FailingTokenStorage extends InMemoryTokenStorage {
  _FailingTokenStorage(this.order);

  final List<String> order;
  bool failClear = false;

  @override
  Future<void> clear() async {
    order.add('token');
    if (failClear) throw StateError('token store locked');
    await super.clear();
  }
}

class _FailingStudentInfoStorage extends InMemoryStudentInfoStorage {
  _FailingStudentInfoStorage(this.order);

  final List<String> order;
  bool failClear = false;

  @override
  Future<void> clear() async {
    order.add('studentInfo');
    if (failClear) throw StateError('disk full');
    await super.clear();
  }
}

class _FailingSchoolCalendarStorage extends InMemorySchoolCalendarStorage {
  _FailingSchoolCalendarStorage(this.order);

  final List<String> order;
  bool failClear = false;

  @override
  Future<void> clear() async {
    order.add('schoolCalendar');
    if (failClear) throw StateError('disk full');
    await super.clear();
  }
}

class _FailingCourseScheduleStorage extends InMemoryCourseScheduleStorage {
  _FailingCourseScheduleStorage(this.order);

  final List<String> order;
  bool failClear = false;

  @override
  Future<void> clear() async {
    order.add('courseSchedule');
    if (failClear) throw StateError('disk full');
    await super.clear();
  }
}

class _FailingCetScoreStorage extends InMemoryCetScoreStorage {
  _FailingCetScoreStorage(this.order);

  final List<String> order;
  bool failClear = false;

  @override
  Future<void> clear() async {
    order.add('cetScore');
    if (failClear) throw StateError('box closed');
    await super.clear();
  }
}

class _FailingUndergraduateScoreStorage
    extends InMemoryUndergraduateScoreStorage {
  _FailingUndergraduateScoreStorage(this.order);

  final List<String> order;
  bool failClear = false;

  @override
  Future<void> clear() async {
    order.add('grades');
    if (failClear) throw StateError('box closed');
    await super.clear();
  }
}

class _FailingStudentExamStorage extends InMemoryStudentExamStorage {
  _FailingStudentExamStorage(this.order);

  final List<String> order;
  bool failClear = false;

  @override
  Future<void> clear() async {
    order.add('studentExams');
    if (failClear) throw StateError('box closed');
    await super.clear();
  }
}

/// Cookie 清理替身：正常注入依赖，可注入失败。
class _FakeCookieClearer implements CookieClearer {
  _FakeCookieClearer(this.order);

  final List<String> order;
  Object? error;

  @override
  Future<void> deleteAllCookies() async {
    order.add('cookies');
    if (error != null) throw error!;
  }
}

TongjiApi _api() => TongjiApi(
      auth: AuthTokenProvider(
        repository: TokenRepository(storage: InMemoryTokenStorage()),
      ),
    );

void main() {
  late List<String> order;
  late _FailingTokenStorage tokenStorage;
  late _FailingStudentInfoStorage studentInfoStorage;
  late _FailingSchoolCalendarStorage calendarStorage;
  late _FailingCourseScheduleStorage courseStorage;
  late _FailingCetScoreStorage cetStorage;
  late _FailingUndergraduateScoreStorage gradesStorage;
  late _FailingStudentExamStorage examStorage;
  late _FakeCookieClearer cookieClearer;
  late SessionController session;
  late LogoutService service;

  setUp(() {
    order = <String>[];
    tokenStorage = _FailingTokenStorage(order);
    studentInfoStorage = _FailingStudentInfoStorage(order);
    calendarStorage = _FailingSchoolCalendarStorage(order);
    courseStorage = _FailingCourseScheduleStorage(order);
    cetStorage = _FailingCetScoreStorage(order);
    gradesStorage = _FailingUndergraduateScoreStorage(order);
    examStorage = _FailingStudentExamStorage(order);
    cookieClearer = _FakeCookieClearer(order);
    session = SessionController()..completeBoot(AuthStatus.authenticated);
    service = LogoutService(
      tokenRepository: TokenRepository(storage: tokenStorage),
      studentInfoRepository: StudentInfoRepository(storage: studentInfoStorage),
      schoolCalendarRepository:
          SchoolCalendarRepository(storage: calendarStorage),
      courseScheduleRepository:
          CourseScheduleRepository(storage: courseStorage),
      cetScoreDataService: CetScoreDataService(
        api: _api(),
        repository: CetScoreRepository(storage: cetStorage),
      ),
      gradesDataService: GradesDataService(
        api: _api(),
        repository: UndergraduateScoreRepository(storage: gradesStorage),
      ),
      studentExamDataService: StudentExamDataService(
        api: _api(),
        repository: StudentExamRepository(storage: examStorage),
      ),
      cookieClearer: cookieClearer,
      sessionController: session,
    );
  });

  group('LogoutService.clearSession 成功路径', () {
    test('全部清理成功：进入游客态，结果无残留失败', () async {
      final LogoutResult result = await service.clearSession();

      expect(session.status, AuthStatus.guest);
      expect(session.lastReason, 'sign_out');
      expect(result.isFullyClean, isTrue);
      expect(order, contains('token'));
      expect(order, contains('cookies'));
    });

    test('全部缓存先于令牌，Cookie 最后（清理顺序不变式）', () async {
      await service.clearSession();

      const List<String> cacheSteps = <String>[
        'studentInfo',
        'schoolCalendar',
        'courseSchedule',
        'cetScore',
        'grades',
        'studentExams',
      ];
      final int tokenIndex = order.indexOf('token');
      for (final String step in cacheSteps) {
        expect(order.indexOf(step), lessThan(tokenIndex),
            reason: '$step 应先于 token 清理');
      }
      expect(order.last, 'cookies');
    });

    test('缓存清理失败后重试成功：完整清完并进入游客态', () async {
      calendarStorage.failClear = true;
      await expectLater(
        service.clearSession(),
        throwsA(isA<LogoutCleanupException>()),
      );
      expect(session.status, AuthStatus.authenticated);

      // 故障消失后同一服务实例重试（幂等）。
      calendarStorage.failClear = false;
      final LogoutResult result = await service.clearSession();

      expect(result.isFullyClean, isTrue);
      expect(session.status, AuthStatus.guest);
    });
  });

  group('LogoutService.clearSession 缓存清理失败：不允许登出', () {
    test('任一缓存失败：异常上抛，令牌未动，状态保持已登录', () async {
      calendarStorage.failClear = true;

      await expectLater(
        service.clearSession(),
        throwsA(isA<LogoutCleanupException>()),
      );

      expect(session.status, AuthStatus.authenticated);
      expect(order, isNot(contains('token')));
      expect(order, isNot(contains('cookies')));
    });

    test('多项缓存失败：收集全部失败后上抛，令牌仍未动', () async {
      studentInfoStorage.failClear = true;
      gradesStorage.failClear = true;

      Object? caught;
      try {
        await service.clearSession();
      } catch (error) {
        caught = error;
      }

      expect(caught, isA<LogoutCleanupException>());
      expect(
        (caught as LogoutCleanupException).failedSteps,
        containsAll(<String>['studentInfo', 'grades']),
      );
      expect(session.status, AuthStatus.authenticated);
      expect(order, isNot(contains('token')));
      // 失败不中断其余缓存步骤，便于一次重试清完。
      expect(order, contains('schoolCalendar'));
      expect(order, contains('studentExams'));
    });
  });

  group('LogoutService.clearSession 令牌清理失败', () {
    test('缓存已清但令牌删除失败：异常上抛，状态保持已登录', () async {
      tokenStorage.failClear = true;

      await expectLater(
        service.clearSession(),
        throwsA(isA<StateError>()),
      );

      expect(session.status, AuthStatus.authenticated);
      expect(order, contains('studentInfo'));
      expect(order, isNot(contains('cookies')));
    });
  });

  group('LogoutService.clearSession Cookie 失败：降级放行', () {
    test('Cookie 失败不阻塞登出：状态翻转，失败记入结果', () async {
      cookieClearer.error = StateError('cookie platform error');

      final LogoutResult result = await service.clearSession();

      expect(session.status, AuthStatus.guest);
      expect(result.isFullyClean, isFalse);
      expect(result.residualFailures.keys, <String>['cookies']);
      expect(order, contains('token'));
    });
  });

  group('LogoutService.clearLocalSessionData（游客路径复用）', () {
    test('成功时不翻转会话状态，由调用方自行决定', () async {
      final LogoutResult result = await service.clearLocalSessionData();

      expect(result.isFullyClean, isTrue);
      expect(session.status, AuthStatus.authenticated);
    });

    test('缓存清理失败时异常上抛且不翻转状态，令牌未动', () async {
      cetStorage.failClear = true;

      await expectLater(
        service.clearLocalSessionData(),
        throwsA(isA<LogoutCleanupException>()),
      );

      expect(session.status, AuthStatus.authenticated);
      expect(order, isNot(contains('token')));
    });

    test('令牌删除失败时异常上抛且不翻转状态', () async {
      tokenStorage.failClear = true;

      await expectLater(
        service.clearLocalSessionData(),
        throwsA(isA<StateError>()),
      );

      expect(session.status, AuthStatus.authenticated);
    });
  });
}
