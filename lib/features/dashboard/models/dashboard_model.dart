import 'package:onetj/services/tongji.dart';

import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/models/timetable_index.dart';

class DashboardUpcomingEntryData {
  const DashboardUpcomingEntryData({
    required this.entry,
    required this.isOngoing,
  });

  final TimetableEntry entry;
  final bool isOngoing;
}

class DashboardModel {
  DashboardModel({TongjiApi? api}) : _api = api ?? TongjiApi();

  final TongjiApi _api;

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
    final CourseScheduleRepository repo =
        CourseScheduleRepository.getInstance();
    final SchoolCalendarRepository schoolCalendarRepository =
        SchoolCalendarRepository.getInstance();
    String? termKey;
    try {
      await schoolCalendarRepository.warmUp();
      final SchoolCalendarData calendar =
          await schoolCalendarRepository.getOrFetch(now: DateTime.now(), fetcher: fetchSchoolCalendar);
      termKey =
          '${calendar.schoolCalendar.year}-${calendar.schoolCalendar.term}';
    } catch (_) {
      termKey = null;
    }
    return repo.getOrFetch(
      now: DateTime.now(),
      termKey: termKey,
      fetcher: fetchCourseSchedule,
    );
  }
}
