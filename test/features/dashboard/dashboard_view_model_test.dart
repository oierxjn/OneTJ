import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/dashboard/application/dashboard_data_service.dart';
import 'package:onetj/features/dashboard/models/event.dart';
import 'package:onetj/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/models/app_update_info.dart';
import 'package:onetj/models/course_schedule_data.dart';
import 'package:onetj/models/school_calendar_data.dart';
import 'package:onetj/models/token_data.dart';
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

TokenData _validToken() {
  return TokenData(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    tokenType: 'Bearer',
    scope: 'scope',
    idToken: 'id-token',
    sessionState: 'session-state',
    accessTokenExpiresIn: 3600,
    refreshTokenExpiresIn: 7200,
    issuedAt: DateTime.now(),
  );
}

SchoolCalendarData _calendarData() {
  return SchoolCalendarData(
    schoolCalendar: SchoolCalendarItemData(
      id: 1,
      year: 2026,
      term: 1,
      beginDay: 1789468800000,
      endDay: 1796035200000,
      weekNum: 16,
      weekBeginDay: 2,
      createdAt: null,
      updatedAt: null,
      deleteFlag: null,
    ),
    week: 2,
    simpleName: '26-27秋',
    now: '2026年9月',
    name: '2026-2027学年秋季学期',
  );
}

/// 依赖显式注入的测试装配；未放行的网络请求一律判失败。
class _Harness {
  _Harness({
    required this.viewModel,
    required this.session,
    required this.requests,
    required this.studentInfoStorage,
    required this.calendarStorage,
    required this.scheduleStorage,
  });

  final DashboardViewModel viewModel;
  final SessionController session;
  final List<Uri> requests;
  final InMemoryStudentInfoStorage studentInfoStorage;
  final InMemorySchoolCalendarStorage calendarStorage;
  final InMemoryCourseScheduleStorage scheduleStorage;
}

Future<_Harness> _buildHarness({
  AuthStatus initialStatus = AuthStatus.authenticated,
  ApiHttpGet? httpGet,
  TestDashboardAppUpdateService? appUpdateService,
}) async {
  final SessionController session = SessionController()
    ..completeBoot(initialStatus);
  final TokenRepository tokenRepository =
      TokenRepository(storage: InMemoryTokenStorage());
  await tokenRepository.saveToken(_validToken());
  final List<Uri> requests = <Uri>[];
  // 未显式放行的请求一律判失败，覆盖数据拉取与令牌刷新等潜在路径。
  Future<http.Response> failOnNetwork(Uri uri) async {
    requests.add(uri);
    fail('测试中不应发起网络请求: $uri');
  }

  final InMemoryStudentInfoStorage studentInfoStorage =
      InMemoryStudentInfoStorage();
  final InMemorySchoolCalendarStorage calendarStorage =
      InMemorySchoolCalendarStorage();
  final InMemoryCourseScheduleStorage scheduleStorage =
      InMemoryCourseScheduleStorage();
  final SchoolCalendarRepository calendarRepository =
      SchoolCalendarRepository(storage: calendarStorage);
  final CourseScheduleRepository scheduleRepository =
      CourseScheduleRepository(storage: scheduleStorage);
  final TongjiApi api = TongjiApi(
    auth: AuthTokenProvider(
      repository: tokenRepository,
      httpPost: (
        Uri uri, {
        Map<String, String>? headers,
        Object? body,
        Encoding? encoding,
        String loggerName = 'Http',
      }) =>
          failOnNetwork(uri),
    ),
    sessionController: session,
    httpGet: httpGet ??
        (
          Uri uri, {
          Map<String, String>? headers,
          String loggerName = 'Http',
        }) =>
            failOnNetwork(uri),
    httpPost: (
      Uri uri, {
      Map<String, String>? headers,
      Object? body,
      Encoding? encoding,
      String loggerName = 'Http',
    }) =>
        failOnNetwork(uri),
  );
  final DashboardViewModel viewModel = DashboardViewModel(
    dataService: DashboardDataService(
      api: api,
      termKeyResolver: TermKeyResolver(
        calendarRepository: calendarRepository,
        scheduleRepository: scheduleRepository,
      ),
      studentInfoRepository:
          StudentInfoRepository(storage: studentInfoStorage),
      courseScheduleRepository: scheduleRepository,
      schoolCalendarRepository: calendarRepository,
      settingsRepository:
          SettingsRepository(storage: InMemorySettingsStorage()),
      // 埋点走真实 HTTP 客户端，用 MockClient 隔离，避免测试触网。
      userCollectionService: UserCollectionService(
        client: MockClient((http.Request request) async {
          requests.add(request.url);
          return http.Response('{}', 200);
        }),
      ),
      sessionController: session,
    ),
    settingsRepository: SettingsRepository(
      storage: InMemorySettingsStorage(),
    ),
    appUpdateService: appUpdateService ?? TestDashboardAppUpdateService(),
    sessionController: session,
  );
  return _Harness(
    viewModel: viewModel,
    session: session,
    requests: requests,
    studentInfoStorage: studentInfoStorage,
    calendarStorage: calendarStorage,
    scheduleStorage: scheduleStorage,
  );
}

/// 预置个人数据缓存（学籍/校历/同学期课表）。
Future<void> _seedPersonalCache(_Harness harness) async {
  await harness.studentInfoStorage.save(buildStudentInfo());
  await harness.calendarStorage.save(_calendarData());
  await harness.scheduleStorage.save(
    const CourseScheduleData(items: <CourseScheduleItemData>[]),
  );
  await harness.scheduleStorage.saveMeta(
    CourseScheduleCacheMeta(
      lastFetchedAtMillis: DateTime.now().millisecondsSinceEpoch,
      termKey: '2026-1',
    ),
  );
}

/// 记录一轮加载的全部事件（broadcast 流先订阅再触发）。
List<UiEvent> _recordEvents(DashboardViewModel viewModel) {
  final List<UiEvent> events = <UiEvent>[];
  viewModel.events.listen(events.add);
  return events;
}

/// broadcast 事件经微任务投递，断言前先落定。
Future<void> _flushEvents() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  group('DashboardViewModel.skipUpdateVersion', () {
    test('returns true when skip version succeeds', () async {
      final TestDashboardAppUpdateService service =
          TestDashboardAppUpdateService(
        onSkipVersion: (_) async {},
      );
      final _Harness harness =
          await _buildHarness(appUpdateService: service);
      final DashboardViewModel viewModel = harness.viewModel;

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
      final _Harness harness =
          await _buildHarness(appUpdateService: service);
      final DashboardViewModel viewModel = harness.viewModel;

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
      final _Harness harness =
          await _buildHarness(initialStatus: AuthStatus.guest);
      final DashboardViewModel viewModel = harness.viewModel;

      await viewModel.load();

      expect(viewModel.departmentName, isNull);
      expect(viewModel.calendar, isNull);
      expect(viewModel.timetableEntries, isEmpty);
      expect(viewModel.studentLoading, isFalse);
      expect(viewModel.calendarLoading, isFalse);
      expect(viewModel.timetableLoading, isFalse);
      expect(harness.requests, isEmpty);
      viewModel.dispose();
    });

    test('登出进入游客态时清空内存中的个人数据', () async {
      final _Harness harness =
          await _buildHarness(initialStatus: AuthStatus.expired);
      await _seedPersonalCache(harness);
      final DashboardViewModel viewModel = harness.viewModel;
      // 失效态先展示缓存，再登出：indexedStack 使视图模型存活，
      // 必须清内存，否则游客会看到上一账号的课程。
      await viewModel.load();
      expect(viewModel.departmentName, isNotNull);

      harness.session.markSignedOut();

      expect(viewModel.departmentName, isNull);
      expect(viewModel.calendar, isNull);
      expect(viewModel.timetableEntries, isEmpty);
      viewModel.dispose();
    });

    test('重新登录成功后自动重载（不再停留在游客空态）', () async {
      final _Harness harness = await _buildHarness(
        initialStatus: AuthStatus.guest,
        httpGet: (
          Uri uri, {
          Map<String, String>? headers,
          String loggerName = 'Http',
        }) async =>
            http.Response('{}', 500),
      );
      final DashboardViewModel viewModel = harness.viewModel;
      await viewModel.load();
      expect(viewModel.timetableEntries, isEmpty);

      harness.session.markAuthenticated();
      // 让自动重载的异步流程跑完；拉取失败但 loading 会落定。
      await _flushEvents();

      expect(viewModel.studentLoading, isFalse);
      viewModel.dispose();
    });
  });

  group('DashboardViewModel 失效态只读展示', () {
    test('失效态 load 展示缓存数据，全程不联网也不提示', () async {
      final _Harness harness =
          await _buildHarness(initialStatus: AuthStatus.expired);
      await _seedPersonalCache(harness);
      final DashboardViewModel viewModel = harness.viewModel;
      final List<UiEvent> events = _recordEvents(viewModel);

      await viewModel.load();
      await _flushEvents();

      expect(harness.requests, isEmpty);
      expect(viewModel.departmentName, 'Computer Science');
      expect(viewModel.calendar?.week, 2);
      expect(viewModel.timetableIndex, isNotNull);
      expect(viewModel.studentLoading, isFalse);
      expect(viewModel.calendarLoading, isFalse);
      expect(viewModel.timetableLoading, isFalse);
      expect(events.whereType<DashboardLoadFailedEvent>(), isEmpty);
      expect(events.whereType<ShowSnackBarEvent>(), isEmpty);
      viewModel.dispose();
    });

    test('失效态无缓存时保持空态，不联网也不提示', () async {
      final _Harness harness =
          await _buildHarness(initialStatus: AuthStatus.expired);
      final DashboardViewModel viewModel = harness.viewModel;
      final List<UiEvent> events = _recordEvents(viewModel);

      await viewModel.load();
      await _flushEvents();

      expect(harness.requests, isEmpty);
      expect(viewModel.departmentName, isNull);
      expect(viewModel.calendar, isNull);
      expect(viewModel.timetableEntries, isEmpty);
      expect(events.whereType<DashboardLoadFailedEvent>(), isEmpty);
      expect(events.whereType<ShowSnackBarEvent>(), isEmpty);
      viewModel.dispose();
    });

    test('运行中转入失效态后，前台恢复不再发起校历同步', () async {
      final _Harness harness = await _buildHarness(
        httpGet: (
          Uri uri, {
          Map<String, String>? headers,
          String loggerName = 'Http',
        }) async =>
            http.Response('{}', 500),
      );
      final DashboardViewModel viewModel = harness.viewModel;
      await viewModel.load();
      harness.requests.clear();

      harness.session.markUnauthenticated(reason: 'http_401');
      await viewModel.onAppResumed();

      expect(harness.requests, isEmpty);
      viewModel.dispose();
    });
  });

  group('DashboardViewModel 加载失败提示', () {
    test('凭证失败（401）只记日志：不弹提示且会话转失效', () async {
      final _Harness harness = await _buildHarness(
        httpGet: (
          Uri uri, {
          Map<String, String>? headers,
          String loggerName = 'Http',
        }) async =>
            http.Response('{"error":"unauthorized"}', 401),
      );
      final DashboardViewModel viewModel = harness.viewModel;
      final List<UiEvent> events = _recordEvents(viewModel);

      await viewModel.load();
      await _flushEvents();

      expect(harness.session.status, AuthStatus.expired);
      expect(events.whereType<DashboardLoadFailedEvent>(), isEmpty);
      expect(events.whereType<ShowSnackBarEvent>(), isEmpty);
      viewModel.dispose();
    });

    test('多个数据源瞬时失败只合并为一条语义事件', () async {
      final _Harness harness = await _buildHarness(
        httpGet: (
          Uri uri, {
          Map<String, String>? headers,
          String loggerName = 'Http',
        }) async =>
            http.Response('{"message":"boom"}', 500),
      );
      final DashboardViewModel viewModel = harness.viewModel;
      final List<UiEvent> events = _recordEvents(viewModel);

      await viewModel.load();
      await _flushEvents();

      expect(harness.session.status, AuthStatus.authenticated);
      expect(events.whereType<DashboardLoadFailedEvent>(), hasLength(1));
      expect(events.whereType<ShowSnackBarEvent>(), isEmpty);
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
  Future<AppUpdateCheckResult> checkForUpdate({
    bool force = false,
    Duration throttleWindow = const Duration(hours: 6),
  }) async {
    // 测试聚焦数据加载，更新检查恒为「无更新」，不触网。
    return AppUpdateCheckResult.notChecked;
  }

  @override
  void logUpdateFailure(Object error, StackTrace stackTrace) {
    loggedErrors.add(error);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}