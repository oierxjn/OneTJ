import 'package:onetj/services/tongji.dart';

import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/course_schedule_repository.dart';

class DashboardModel {
  DashboardModel({TongjiApi? api}) : _api = api ?? TongjiApi();

  final TongjiApi _api;

  Future<StudentInfoData> fetchStudentInfo() {
    return _api.fetchStudentInfo();
  }

  Future<SchoolCalendarData> fetchSchoolCalendar() {
    return _api.fetchSchoolCalendarCurrentTerm();
  }

  Future<CourseScheduleData> fetchCourseSchedule() {
    return _api.fetchStudentTimetable();
  }

  Future<CourseScheduleData> getCourseSchedule() async {
    final CourseScheduleRepository repo = CourseScheduleRepository.getInstance();
    final SchoolCalendarData? calendar = await SchoolCalendarRepository.getInstance().getSchoolCalendar();
    final String? termKey = calendar == null
        ? null
        : '${calendar.schoolCalendar.year}-${calendar.schoolCalendar.term}';
    return repo.getOrFetch(
      now: DateTime.now(),
      termKey: termKey,
      fetcher: fetchCourseSchedule,
    );
  }
}
