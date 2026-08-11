import 'package:onetj/services/tongji.dart';

import 'package:onetj/models/student_info_data.dart';
import 'package:onetj/models/school_calendar_data.dart';
import 'package:onetj/models/course_schedule_data.dart';

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
