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

class DashboardDataService {
  DashboardDataService({
    required TongjiApi api,
    required TermKeyResolver termKeyResolver,
    required StudentInfoRepository studentInfoRepository,
    required CourseScheduleRepository courseScheduleRepository,
    required SchoolCalendarRepository schoolCalendarRepository,
    required SettingsRepository settingsRepository,
    required UserCollectionService userCollectionService,
  })  : _api = api,
        _termKeyResolver = termKeyResolver,
        _studentInfoRepository = studentInfoRepository,
        _courseScheduleRepository = courseScheduleRepository,
        _schoolCalendarRepository = schoolCalendarRepository,
        _settingsRepository = settingsRepository,
        _userCollectionService = userCollectionService;

  final TongjiApi _api;
  final TermKeyResolver _termKeyResolver;
  final StudentInfoRepository _studentInfoRepository;
  final CourseScheduleRepository _courseScheduleRepository;
  final SchoolCalendarRepository _schoolCalendarRepository;
  final SettingsRepository _settingsRepository;
  final UserCollectionService _userCollectionService;

  Future<StudentInfoData> fetchStudentInfo() {
    return _api.fetchStudentInfo();
  }

  Future<StudentInfoData> getStudentInfo() async {
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

  Future<SchoolCalendarData> getSchoolCalendar() async {
    await _schoolCalendarRepository.warmUp();
    return _schoolCalendarRepository.getOrFetch(
      now: DateTime.now(),
      fetcher: fetchSchoolCalendar,
    );
  }

  Future<CourseScheduleData> fetchCourseSchedule() {
    return _api.fetchStudentTimetable();
  }

  Future<CourseScheduleData> getCourseSchedule() async {
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

  /// 学生信息加载后按用户采集策略上报一次埋点。
  ///
  /// 组合学生信息与当前设置；失败由调用方决定如何处理。
  Future<void> uploadUserCollectionForProduction() async {
    final StudentInfoData studentInfo = await getStudentInfo();
    final SettingsData settings = await _settingsRepository.getSettings();
    await _userCollectionService.uploadForProduction(
      studentInfo: studentInfo,
      settings: settings,
    );
  }
}
