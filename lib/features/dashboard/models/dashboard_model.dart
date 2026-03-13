import 'package:onetj/services/tongji.dart';

import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/models/timetable_index.dart';
import 'package:onetj/services/term_key_resolver.dart';

class DashboardUpcomingEntryData {
  const DashboardUpcomingEntryData({
    required this.entry,
    required this.isOngoing,
  });

  final TimetableEntry entry;
  final bool isOngoing;
}

class DashboardModel {
  DashboardModel({
    TongjiApi? api,
    TermKeyResolver? termKeyResolver,
  })  : _api = api ?? TongjiApi(),
        _termKeyResolver = termKeyResolver ?? TermKeyResolver();

  final TongjiApi _api;
  final TermKeyResolver _termKeyResolver;

  Future<StudentInfoData> fetchStudentInfo() {
    return _api.fetchStudentInfo();
  }

  Future<StudentInfoData> getStudentInfo() async {
    final StudentInfoRepository repo = StudentInfoRepository.getInstance();
    await repo.warmUp();
    return repo.getOrFetch(
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
    final CourseScheduleRepository repo =
        CourseScheduleRepository.getInstance();
    await repo.warmUp();
    final String? termKey = await _termKeyResolver.resolveCurrentTermKey(
      now: now,
      fetchSchoolCalendar: fetchSchoolCalendar,
    );
    return repo.getOrFetch(
      now: now,
      termKey: termKey,
      fetcher: fetchCourseSchedule,
    );
  }
}
