import 'package:onetj/services/tongji.dart';

import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/course_schedule_repository.dart';

class HomeModel {
  HomeModel({TongjiApi? api}) : _api = api ?? TongjiApi();

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
}
