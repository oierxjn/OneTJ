import 'package:onetj/services/tongji.dart';

import 'package:onetj/repo/course_schedule_repository.dart';

class TimetableModel {
  TimetableModel({TongjiApi? api}) : _api = api ?? TongjiApi();

  final TongjiApi _api;

  Future<CourseScheduleData> fetchCourseSchedule() {
    return _api.fetchStudentTimetable();
  }
}
