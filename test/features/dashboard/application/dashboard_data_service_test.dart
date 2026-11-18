import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/dashboard/application/dashboard_data_service.dart';
import 'package:onetj/models/course_schedule_data.dart';
import 'package:onetj/models/school_calendar_data.dart';
import 'package:onetj/models/token_data.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/auth_token_provider.dart';
import 'package:onetj/services/term_key_resolver.dart';
import 'package:onetj/services/tongji.dart';
import 'package:onetj/services/user_collection_service.dart';

import '../../../repo/student_info_fixtures.dart';

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

/// 数据服务装配：会话状态可控，任何未放行的网络请求都判失败。
class _Harness {
  _Harness({
    required this.service,
    required this.session,
    required this.requests,
    required this.studentInfoStorage,
    required this.calendarStorage,
    required this.scheduleStorage,
  });

  final DashboardDataService service;
  final SessionController session;
  final List<Uri> requests;
  final InMemoryStudentInfoStorage studentInfoStorage;
  final InMemorySchoolCalendarStorage calendarStorage;
  final InMemoryCourseScheduleStorage scheduleStorage;
}

Future<_Harness> _buildHarness({
  required AuthStatus status,
  ApiHttpGet? httpGet,
}) async {
  final SessionController session = SessionController();
  if (status != AuthStatus.unknown) {
    session.completeBoot(status);
  }
  final TokenRepository tokenRepository =
      TokenRepository(storage: InMemoryTokenStorage());
  await tokenRepository.saveToken(_validToken());
  final List<Uri> requests = <Uri>[];
  Future<http.Response> failOnNetwork(Uri uri) async {
    requests.add(uri);
    fail('当前会话不应发起网络请求: $uri');
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
  return _Harness(
    service: DashboardDataService(
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
      userCollectionService: UserCollectionService(
        client: MockClient((http.Request request) async {
          requests.add(request.url);
          return http.Response('{}', 200);
        }),
      ),
      sessionController: session,
    ),
    session: session,
    requests: requests,
    studentInfoStorage: studentInfoStorage,
    calendarStorage: calendarStorage,
    scheduleStorage: scheduleStorage,
  );
}

/// 预置学籍/校历/同学期课表缓存。
///
/// 数据与元数据必须成对写入：仓库把「缺元数据」视为需要重新拉取，
/// 只写数据不构成新鲜缓存。
Future<void> _seedCache(_Harness harness, {String termKey = '2026-1'}) async {
  final int nowMillis = DateTime.now().millisecondsSinceEpoch;
  await harness.studentInfoStorage.save(buildStudentInfo());
  await harness.studentInfoStorage.saveMeta(
    StudentInfoCacheMeta(lastFetchedAtMillis: nowMillis),
  );
  await harness.calendarStorage.save(_calendarData());
  await harness.calendarStorage.saveMeta(
    SchoolCalendarCacheMeta(lastFetchedAtMillis: nowMillis),
  );
  await harness.scheduleStorage.save(
    const CourseScheduleData(items: <CourseScheduleItemData>[]),
  );
  await harness.scheduleStorage.saveMeta(
    CourseScheduleCacheMeta(
      lastFetchedAtMillis: nowMillis,
      termKey: termKey,
    ),
  );
}

void main() {
  group('DashboardDataService 失效态只读缓存', () {
    test('三类数据均取自缓存，全程不联网', () async {
      final _Harness harness =
          await _buildHarness(status: AuthStatus.expired);
      await _seedCache(harness);

      expect((await harness.service.getStudentInfo())?.deptName,
          'Computer Science');
      expect((await harness.service.getSchoolCalendar())?.week, 2);
      expect(await harness.service.getCourseSchedule(), isNotNull);
      expect(harness.requests, isEmpty);
    });

    test('无缓存时返回 null，不回退联网', () async {
      final _Harness harness =
          await _buildHarness(status: AuthStatus.expired);

      expect(await harness.service.getStudentInfo(), isNull);
      expect(await harness.service.getSchoolCalendar(), isNull);
      expect(await harness.service.getCourseSchedule(), isNull);
      expect(harness.requests, isEmpty);
    });

    test('课表缓存学期与当前学期不符时返回 null', () async {
      final _Harness harness =
          await _buildHarness(status: AuthStatus.expired);
      await _seedCache(harness, termKey: '2025-2');

      expect(await harness.service.getCourseSchedule(), isNull);
      expect(harness.requests, isEmpty);
    });

    test('校历缓存缺失时回退课表缓存元数据解析学期 key', () async {
      final _Harness harness =
          await _buildHarness(status: AuthStatus.expired);
      await harness.scheduleStorage.save(
        const CourseScheduleData(items: <CourseScheduleItemData>[]),
      );
      await harness.scheduleStorage.saveMeta(
        CourseScheduleCacheMeta(
          lastFetchedAtMillis: DateTime.now().millisecondsSinceEpoch,
          termKey: '2026-1',
        ),
      );

      expect(await harness.service.getSchoolCalendar(), isNull);
      expect(await harness.service.getCourseSchedule(), isNotNull);
      expect(harness.requests, isEmpty);
    });

    test('埋点在失效态跳过，不发起鉴权请求', () async {
      final _Harness harness =
          await _buildHarness(status: AuthStatus.expired);
      await _seedCache(harness);

      await harness.service.uploadUserCollectionForProduction();

      expect(harness.requests, isEmpty);
    });
  });

  group('DashboardDataService 游客态与 unknown', () {
    test('游客态三类数据返回 null 且不联网', () async {
      final _Harness harness = await _buildHarness(status: AuthStatus.guest);
      // 即便本机残留缓存，游客态也不展示个人数据。
      await _seedCache(harness);

      expect(await harness.service.getStudentInfo(), isNull);
      expect(await harness.service.getSchoolCalendar(), isNull);
      expect(await harness.service.getCourseSchedule(), isNull);
      await harness.service.uploadUserCollectionForProduction();
      expect(harness.requests, isEmpty);
    });

    test('unknown（启动引导未结束）不联网也不读缓存', () async {
      final _Harness harness = await _buildHarness(status: AuthStatus.unknown);
      await _seedCache(harness);

      expect(await harness.service.getStudentInfo(), isNull);
      expect(await harness.service.getSchoolCalendar(), isNull);
      expect(await harness.service.getCourseSchedule(), isNull);
      expect(harness.requests, isEmpty);
    });
  });

  group('DashboardDataService 已登录态', () {
    test('缓存新鲜时直接命中缓存，不联网', () async {
      final _Harness harness =
          await _buildHarness(status: AuthStatus.authenticated);
      await _seedCache(harness);

      expect((await harness.service.getStudentInfo())?.deptName,
          'Computer Science');
      expect((await harness.service.getSchoolCalendar())?.week, 2);
      expect(await harness.service.getCourseSchedule(), isNotNull);
      expect(harness.requests, isEmpty);
    });

    test('无缓存时走联网，失败照常抛出而非静默返回 null', () async {
      final _Harness harness = await _buildHarness(
        status: AuthStatus.authenticated,
        httpGet: (
          Uri uri, {
          Map<String, String>? headers,
          String loggerName = 'Http',
        }) async =>
            http.Response('{"message":"boom"}', 500),
      );

      await expectLater(
        harness.service.getStudentInfo(),
        throwsA(anything),
      );
    });
  });
}