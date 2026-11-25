import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/models/course_schedule_data.dart';
import 'package:onetj/models/school_calendar_data.dart';
import 'package:onetj/models/settings_data.dart';
import 'package:onetj/models/student_info_data.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/services/term_key_resolver.dart';
import 'package:onetj/services/tongji.dart';
import 'package:onetj/services/user_collection_service.dart';

/// 仪表盘平台数据的取数编排。
///
/// 按会话选择展示策略：已登录按 TTL 走缓存或联网；失效态展示缓存，
/// 无缓存返回 null；游客态与 unknown 返回 null。
///
/// 返回 null 表示「当前会话下没有可展示的数据」，
/// 真正的取数失败仍抛异常，由调用方分类处理。
class DashboardDataService {
  DashboardDataService({
    required TongjiApi api,
    required TermKeyResolver termKeyResolver,
    required StudentInfoRepository studentInfoRepository,
    required CourseScheduleRepository courseScheduleRepository,
    required SchoolCalendarRepository schoolCalendarRepository,
    required SettingsRepository settingsRepository,
    required UserCollectionService userCollectionService,
    required SessionController sessionController,
  })  : _api = api,
        _termKeyResolver = termKeyResolver,
        _studentInfoRepository = studentInfoRepository,
        _courseScheduleRepository = courseScheduleRepository,
        _schoolCalendarRepository = schoolCalendarRepository,
        _settingsRepository = settingsRepository,
        _userCollectionService = userCollectionService,
        _sessionController = sessionController;

  final TongjiApi _api;
  final TermKeyResolver _termKeyResolver;
  final StudentInfoRepository _studentInfoRepository;
  final CourseScheduleRepository _courseScheduleRepository;
  final SchoolCalendarRepository _schoolCalendarRepository;
  final SettingsRepository _settingsRepository;
  final UserCollectionService _userCollectionService;
  final SessionController _sessionController;

  bool get _canGoOnline => _sessionController.isAuthenticated;

  Future<StudentInfoData> fetchStudentInfo() {
    return _api.fetchStudentInfo();
  }

  Future<StudentInfoData?> getStudentInfo() async {
    if (!_canGoOnline) {
      // 失效态展示缓存（不论新旧）；游客/unknown 无可展示数据。
      return _sessionController.status == AuthStatus.expired
          ? _readCachedStudentInfo()
          : null;
    }
    await _studentInfoRepository.warmUp();
    return _studentInfoRepository.getOrFetch(
      now: DateTime.now(),
      fetcher: fetchStudentInfo,
      ttl: const Duration(days: 1),
    );
  }

  Future<SchoolCalendarData> fetchSchoolCalendar() {
    return _api.fetchSchoolCalendarCurrentTerm();
  }

  Future<SchoolCalendarData?> getSchoolCalendar() async {
    if (!_canGoOnline) {
      return _sessionController.status == AuthStatus.expired
          ? _readCachedSchoolCalendar()
          : null;
    }
    await _schoolCalendarRepository.warmUp();
    return _schoolCalendarRepository.getOrFetch(
      now: DateTime.now(),
      fetcher: fetchSchoolCalendar,
    );
  }

  Future<CourseScheduleData> fetchCourseSchedule() {
    return _api.fetchStudentTimetable();
  }

  Future<CourseScheduleData?> getCourseSchedule() async {
    if (!_canGoOnline) {
      return _sessionController.status == AuthStatus.expired
          ? _readCachedCourseSchedule()
          : null;
    }
    final DateTime now = DateTime.now();
    await _courseScheduleRepository.warmUp();
    final String? termKey = await _termKeyResolver.resolveCurrentTermKey(
      now: now,
      fetchSchoolCalendar: fetchSchoolCalendar,
    );
    return _courseScheduleRepository.getOrFetch(
      now: now,
      termKey: termKey,
      fetcher: fetchCourseSchedule,
    );
  }

  Future<StudentInfoData?> _readCachedStudentInfo() async {
    await _studentInfoRepository.warmUp();
    return _studentInfoRepository.getCached();
  }

  Future<SchoolCalendarData?> _readCachedSchoolCalendar() async {
    await _schoolCalendarRepository.warmUp();
    return _schoolCalendarRepository.getCached();
  }

  /// 缓存课表须与缓存解析出的当前学期一致才展示，避免跨学期串数据。
  /// 学期只认校历缓存，解析不出则不展示课表。
  Future<CourseScheduleData?> _readCachedCourseSchedule() async {
    await _courseScheduleRepository.warmUp();
    final String? termKey =
        await _termKeyResolver.resolveCurrentTermKeyFromCache();
    final CourseScheduleCacheMeta? meta =
        await _courseScheduleRepository.getCachedMeta();
    if (termKey == null || meta?.termKey != termKey) {
      return null;
    }
    return _courseScheduleRepository.getCached();
  }

  /// 学生信息加载后按用户采集策略上报一次埋点。
  ///
  /// 组合学生信息与当前设置；失败由调用方决定如何处理。
  /// 非已登录态直接跳过：埋点依赖鉴权取数，失效态发请求注定失败。
  ///
  /// 这里刻意不复用 [getStudentInfo]：那条路径会先 `warmUp()` 读一次存储，
  /// 而埋点只需要内存缓存/网络结果，保持与原有行为一致以避免多余的 I/O。
  Future<void> uploadUserCollectionForProduction() async {
    if (!_canGoOnline) {
      return;
    }
    final StudentInfoData studentInfo = await _studentInfoRepository.getOrFetch(
      now: DateTime.now(),
      fetcher: fetchStudentInfo,
      ttl: const Duration(days: 1),
    );
    final SettingsData settings = await _settingsRepository.getSettings();
    await _userCollectionService.uploadForProduction(
      studentInfo: studentInfo,
      settings: settings,
    );
  }
}
