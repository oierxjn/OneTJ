import 'package:onetj/models/course_schedule_data.dart';
import 'package:onetj/models/school_calendar_data.dart';
import 'package:onetj/models/student_info_data.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/services/term_key_resolver.dart';
import 'package:onetj/services/tongji.dart';

class DashboardDataService {
  DashboardDataService({
    required TongjiApi api,
    required TermKeyResolver termKeyResolver,
    required StudentInfoRepository studentInfoRepository,
    required CourseScheduleRepository courseScheduleRepository,
  })  : _api = api,
        _termKeyResolver = termKeyResolver,
        _studentInfoRepository = studentInfoRepository,
        _courseScheduleRepository = courseScheduleRepository;

  final TongjiApi _api;
  final TermKeyResolver _termKeyResolver;
  final StudentInfoRepository _studentInfoRepository;
  final CourseScheduleRepository _courseScheduleRepository;

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
}
