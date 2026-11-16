import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/cet_score/application/cet_score_data_service.dart';
import 'package:onetj/features/grades/application/grades_data_service.dart';
import 'package:onetj/features/login/application/login_data_service.dart';
import 'package:onetj/features/login/models/login_model.dart';
import 'package:onetj/features/login/view_models/login_view_model.dart';
import 'package:onetj/features/settings/application/logout_service.dart';
import 'package:onetj/features/settings/models/event.dart';
import 'package:onetj/features/settings/models/logout_result.dart';
import 'package:onetj/features/student_exams/application/student_exam_data_service.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/cet_score_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/student_exam_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/repo/undergraduate_score_repository.dart';
import 'package:onetj/services/auth_token_provider.dart';
import 'package:onetj/services/cookie_clearer.dart';
import 'package:onetj/services/tongji.dart';

/// 只覆写清理方法的登出服务桩：记录调用次数，可注入失败。
///
/// 其余依赖用内存存储真实构造（清理被覆写，不会触碰它们）。
class _FakeLogoutService extends LogoutService {
  _FakeLogoutService({this.clearError, this.clearResult})
      : super(
          tokenRepository: TokenRepository(storage: InMemoryTokenStorage()),
          studentInfoRepository:
              StudentInfoRepository(storage: InMemoryStudentInfoStorage()),
          schoolCalendarRepository:
              SchoolCalendarRepository(storage: InMemorySchoolCalendarStorage()),
          courseScheduleRepository:
              CourseScheduleRepository(storage: InMemoryCourseScheduleStorage()),
          cetScoreDataService: CetScoreDataService(
            api: _api(),
            repository: CetScoreRepository(storage: InMemoryCetScoreStorage()),
          ),
          gradesDataService: GradesDataService(
            api: _api(),
            repository: UndergraduateScoreRepository(
              storage: InMemoryUndergraduateScoreStorage(),
            ),
          ),
          studentExamDataService: StudentExamDataService(
            api: _api(),
            repository:
                StudentExamRepository(storage: InMemoryStudentExamStorage()),
          ),
          cookieClearer: _NoopCookieClearer(),
          sessionController: SessionController(),
        );

  final Object? clearError;
  final LogoutResult? clearResult;
  int clearCallCount = 0;

  @override
  Future<LogoutResult> clearLocalSessionData() async {
    clearCallCount += 1;
    if (clearError != null) {
      throw clearError!;
    }
    return clearResult ?? LogoutResult();
  }
}

TongjiApi _api() => TongjiApi(
      auth: AuthTokenProvider(
        repository: TokenRepository(storage: InMemoryTokenStorage()),
      ),
    );

/// 无操作 Cookie 清理替身：本测试不覆盖 Cookie 路径。
class _NoopCookieClearer implements CookieClearer {
  @override
  Future<void> deleteAllCookies() async {}
}

LoginViewModel _buildViewModel({
  required SessionController session,
  required LogoutService logoutService,
}) {
  return LoginViewModel(
    dataService: LoginDataService(
      model: LoginModel(),
      authTokenProvider: AuthTokenProvider(
        repository: TokenRepository(storage: InMemoryTokenStorage()),
      ),
    ),
    sessionController: session,
    logoutService: logoutService,
  );
}

void main() {
  test('登录跳转日志不记录查询参数值', () {
    const String authorizationCode = 'authorization-code-should-not-be-logged';
    const String state = 'state-should-not-be-logged';
    final Map<String, Object?> context = LoginViewModel.redirectUriLogContext(
      WebUri(
        'https://example.com/oauth/callback?code=$authorizationCode&state=$state',
      ),
    );

    expect(context['scheme'], 'https');
    expect(context['host'], 'example.com');
    expect(context['path'], '/oauth/callback');
    expect(context['queryParameterNames'], <String>['code', 'state']);
    expect(context.values.join(), isNot(contains(authorizationCode)));
    expect(context.values.join(), isNot(contains(state)));
  });

  group('LoginViewModel.continueAsGuest', () {
    test('失效态：先清缓存再进入游客态', () async {
      final SessionController session = SessionController()
        ..completeBoot(AuthStatus.expired);
      final _FakeLogoutService logout = _FakeLogoutService();
      final LoginViewModel viewModel =
          _buildViewModel(session: session, logoutService: logout);

      final bool success = await viewModel.continueAsGuest();

      expect(success, isTrue);
      expect(logout.clearCallCount, 1);
      expect(session.status, AuthStatus.guest);
      viewModel.dispose();
    });

    test('已是游客：幂等返回，不清缓存', () async {
      final SessionController session = SessionController()
        ..completeBoot(AuthStatus.guest);
      final _FakeLogoutService logout = _FakeLogoutService();
      final LoginViewModel viewModel =
          _buildViewModel(session: session, logoutService: logout);

      final bool success = await viewModel.continueAsGuest();

      expect(success, isTrue);
      expect(logout.clearCallCount, 0);
      expect(session.status, AuthStatus.guest);
      viewModel.dispose();
    });

    test('清理失败：停留原态、返回 false 并提示', () async {
      final SessionController session = SessionController()
        ..completeBoot(AuthStatus.expired);
      final _FakeLogoutService logout =
          _FakeLogoutService(clearError: StateError('disk full'));
      final LoginViewModel viewModel =
          _buildViewModel(session: session, logoutService: logout);
      final Future<UiEvent> event = viewModel.events.first;

      final bool success = await viewModel.continueAsGuest();

      expect(success, isFalse);
      expect(session.status, AuthStatus.expired);
      expect(await event, isA<ShowSnackBarEvent>());
      viewModel.dispose();
    });

    test('残留清理失败：仍进入游客态并发出警告事件', () async {
      final SessionController session = SessionController()
        ..completeBoot(AuthStatus.expired);
      final _FakeLogoutService logout = _FakeLogoutService(
        clearResult: LogoutResult(
          residualFailures: <String, Object>{
            'cookies': StateError('cookie platform error'),
          },
        ),
      );
      final LoginViewModel viewModel =
          _buildViewModel(session: session, logoutService: logout);
      final Future<UiEvent> event = viewModel.events.first;

      final bool success = await viewModel.continueAsGuest();

      expect(success, isTrue);
      expect(session.status, AuthStatus.guest);
      final UiEvent emitted = await event;
      expect(emitted, isA<LogoutCompletedWithWarningEvent>());
      expect(
        (emitted as LogoutCompletedWithWarningEvent).failedSteps,
        <String>['cookies'],
      );
      viewModel.dispose();
    });
  });
}
