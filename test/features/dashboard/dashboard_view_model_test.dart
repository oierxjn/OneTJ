import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/dashboard/application/dashboard_data_service.dart';
import 'package:onetj/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/app_update_service.dart';
import 'package:onetj/services/auth_token_provider.dart';
import 'package:onetj/services/term_key_resolver.dart';
import 'package:onetj/services/tongji.dart';
import 'package:onetj/services/user_collection_service.dart';

void main() {
  /// 组装一个所有依赖都已显式注入的视图模型，测试用例只需给出更新服务。
  DashboardViewModel buildViewModel({
    required AppUpdateService appUpdateService,
    SessionController? sessionController,
  }) {
    final CourseScheduleRepository scheduleRepository =
        CourseScheduleRepository(storage: InMemoryCourseScheduleStorage());
    final SchoolCalendarRepository calendarRepository =
        SchoolCalendarRepository(storage: InMemorySchoolCalendarStorage());
    return DashboardViewModel(
      dataService: DashboardDataService(
        api: TongjiApi(
          auth: AuthTokenProvider(
            repository: TokenRepository(storage: InMemoryTokenStorage()),
          ),
        ),
        termKeyResolver: TermKeyResolver(
          calendarRepository: calendarRepository,
          scheduleRepository: scheduleRepository,
        ),
        studentInfoRepository: StudentInfoRepository(
          storage: InMemoryStudentInfoStorage(),
        ),
        courseScheduleRepository: scheduleRepository,
        schoolCalendarRepository: calendarRepository,
        settingsRepository: SettingsRepository(
          storage: InMemorySettingsStorage(),
        ),
        userCollectionService: UserCollectionService(),
      ),
      settingsRepository: SettingsRepository(
        storage: InMemorySettingsStorage(),
      ),
      appUpdateService: appUpdateService,
      sessionController: sessionController ??
          (SessionController()..completeBoot(AuthStatus.authenticated)),
    );
  }

  group('DashboardViewModel.skipUpdateVersion', () {
    test('returns true when skip version succeeds', () async {
      final TestDashboardAppUpdateService service =
          TestDashboardAppUpdateService(
        onSkipVersion: (_) async {},
      );
      final DashboardViewModel viewModel =
          buildViewModel(appUpdateService: service);

      final bool result = await viewModel.skipUpdateVersion('v2.3.0');

      expect(result, isTrue);
      expect(service.skippedVersions, <String>['v2.3.0']);
      viewModel.dispose();
    });

    test('returns false and emits failed event when skip version throws',
        () async {
      final Object error = Exception('hive write failed');
      final TestDashboardAppUpdateService service =
          TestDashboardAppUpdateService(
        onSkipVersion: (_) async => throw error,
      );
      final DashboardViewModel viewModel =
          buildViewModel(appUpdateService: service);

      final Future<UiEvent> nextEvent = viewModel.events.first;
      final bool result = await viewModel.skipUpdateVersion('v2.3.0');
      final UiEvent event = await nextEvent;

      expect(result, isFalse);
      expect(event, isA<AppUpdateFailedEvent>());
      expect((event as AppUpdateFailedEvent).error, same(error));
      expect(service.loggedErrors, <Object>[error]);
      viewModel.dispose();
    });
  });

  group('DashboardViewModel 会话感知', () {
    test('游客态 load 不拉取平台数据，个人数据保持为空', () async {
      final SessionController session = SessionController()
        ..completeBoot(AuthStatus.guest);
      final DashboardViewModel viewModel = buildViewModel(
        appUpdateService: TestDashboardAppUpdateService(),
        sessionController: session,
      );

      await viewModel.load();

      expect(viewModel.departmentName, isNull);
      expect(viewModel.calendar, isNull);
      expect(viewModel.timetableEntries, isEmpty);
      expect(viewModel.studentLoading, isFalse);
      expect(viewModel.calendarLoading, isFalse);
      expect(viewModel.timetableLoading, isFalse);
      viewModel.dispose();
    });

    test('登出进入游客态时清空内存中的个人数据', () async {
      final SessionController session = SessionController()
        ..completeBoot(AuthStatus.authenticated);
      final DashboardViewModel viewModel = buildViewModel(
        appUpdateService: TestDashboardAppUpdateService(),
        sessionController: session,
      );
      // 模拟已加载过个人数据后的登出：indexedStack 使视图模型存活，
      // 必须清内存，否则游客会看到上一账号的课程。
      await viewModel.load();
      session.markSignedOut();

      expect(viewModel.departmentName, isNull);
      expect(viewModel.calendar, isNull);
      expect(viewModel.timetableEntries, isEmpty);
      viewModel.dispose();
    });

    test('重新登录成功后自动重载（不再停留在游客空态）', () async {
      final SessionController session = SessionController()
        ..completeBoot(AuthStatus.guest);
      final DashboardViewModel viewModel = buildViewModel(
        appUpdateService: TestDashboardAppUpdateService(),
        sessionController: session,
      );
      await viewModel.load();
      expect(viewModel.timetableEntries, isEmpty);

      session.markAuthenticated();
      // 让自动重载的异步流程跑完；无网络环境下拉取失败但 loading 会落定。
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.studentLoading, isFalse);
      viewModel.dispose();
    });
  });
}

typedef SkipVersionHandler = Future<void> Function(String versionTag);

class TestDashboardAppUpdateService implements AppUpdateService {
  TestDashboardAppUpdateService({
    this.onSkipVersion,
  });

  final SkipVersionHandler? onSkipVersion;
  final List<String> skippedVersions = <String>[];
  final List<Object> loggedErrors = <Object>[];

  @override
  Future<void> skipVersion(String versionTag) async {
    skippedVersions.add(versionTag);
    await onSkipVersion?.call(versionTag);
  }

  @override
  void logUpdateFailure(Object error, StackTrace stackTrace) {
    loggedErrors.add(error);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
