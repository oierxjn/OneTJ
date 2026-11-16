import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/dashboard/application/dashboard_data_service.dart';
import 'package:onetj/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/models/course_schedule_data.dart';
import 'package:onetj/models/school_calendar_data.dart';
import 'package:onetj/models/student_info_data.dart';
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

import '../../repo/student_info_fixtures.dart';

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

    test('登录成功强刷学籍/校历/课表，冷启动判定已登录走缓存优先', () async {
      final SessionController session = SessionController()
        ..completeBoot(AuthStatus.guest);
      final _RecordingDashboardDataService dataService =
          _RecordingDashboardDataService();
      final DashboardViewModel viewModel = DashboardViewModel(
        dataService: dataService,
        settingsRepository: SettingsRepository(
          storage: InMemorySettingsStorage(),
        ),
        appUpdateService: TestDashboardAppUpdateService(),
        sessionController: session,
      );

      session.markAuthenticated();
      await Future<void>.delayed(Duration.zero);
      await pumpEventQueue();

      expect(dataService.refreshStudentInfoCount, 1);
      expect(dataService.refreshSchoolCalendarCount, 1);
      expect(dataService.refreshCourseScheduleCount, 1);
      expect(dataService.getStudentInfoCount, 0);
      expect(dataService.getSchoolCalendarCount, 0);
      expect(dataService.getCourseScheduleCount, 0);
      viewModel.dispose();

      final SessionController bootSession = SessionController();
      final _RecordingDashboardDataService bootService =
          _RecordingDashboardDataService();
      final DashboardViewModel bootViewModel = DashboardViewModel(
        dataService: bootService,
        settingsRepository: SettingsRepository(
          storage: InMemorySettingsStorage(),
        ),
        appUpdateService: TestDashboardAppUpdateService(),
        sessionController: bootSession,
      );

      bootSession.completeBoot(AuthStatus.authenticated);
      await Future<void>.delayed(Duration.zero);
      await pumpEventQueue();

      expect(bootService.getStudentInfoCount, 1);
      expect(bootService.getSchoolCalendarCount, 1);
      expect(bootService.getCourseScheduleCount, 1);
      expect(bootService.refreshStudentInfoCount, 0);
      expect(bootService.refreshSchoolCalendarCount, 0);
      expect(bootService.refreshCourseScheduleCount, 0);
      bootViewModel.dispose();
    });
  });
}

/// 记录缓存优先取数与强刷调用次数的首页数据服务替身。
///
/// 其余成员（埋点上报等）经 noSuchMethod 兜底，本测试不关心其行为。
class _RecordingDashboardDataService implements DashboardDataService {
  int getStudentInfoCount = 0;
  int getSchoolCalendarCount = 0;
  int getCourseScheduleCount = 0;
  int refreshStudentInfoCount = 0;
  int refreshSchoolCalendarCount = 0;
  int refreshCourseScheduleCount = 0;

  @override
  Future<StudentInfoData> getStudentInfo() async {
    getStudentInfoCount += 1;
    return buildStudentInfo(deptName: '缓存院系');
  }

  @override
  Future<StudentInfoData> refreshStudentInfo() async {
    refreshStudentInfoCount += 1;
    return buildStudentInfo(deptName: '新账号院系');
  }

  @override
  Future<SchoolCalendarData> getSchoolCalendar() async {
    getSchoolCalendarCount += 1;
    return _buildCalendar(week: 1);
  }

  @override
  Future<SchoolCalendarData> refreshSchoolCalendar() async {
    refreshSchoolCalendarCount += 1;
    return _buildCalendar(week: 2);
  }

  @override
  Future<CourseScheduleData> getCourseSchedule() async {
    getCourseScheduleCount += 1;
    return const CourseScheduleData(items: <CourseScheduleItemData>[]);
  }

  @override
  Future<CourseScheduleData> refreshCourseSchedule() async {
    refreshCourseScheduleCount += 1;
    return const CourseScheduleData(items: <CourseScheduleItemData>[]);
  }

  @override
  Future<void> uploadUserCollectionForProduction() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SchoolCalendarData _buildCalendar({required int week}) {
  return SchoolCalendarData(
    schoolCalendar: const SchoolCalendarItemData(
      id: 1,
      year: 2026,
      term: 1,
      beginDay: 20260901,
      endDay: 20270117,
      weekNum: 20,
      weekBeginDay: 20260907,
      createdAt: null,
      updatedAt: null,
      deleteFlag: null,
    ),
    week: week,
    simpleName: '2026-2027-1',
    now: '2026-11-16',
    name: '2026-2027学年第一学期',
  );
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
