import 'package:onetj/services/tongji.dart';

import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/services/timetable_index_builder.dart';
import 'package:onetj/models/timetable_index.dart';


class TimetableModel {
  TimetableModel({
    TongjiApi? api,
    TimetableIndexBuilder? indexBuilder,
    CourseScheduleRepository? scheduleRepository,
    SchoolCalendarRepository? calendarRepository,
  }) : _api = api ?? TongjiApi(),
       _indexBuilder = indexBuilder ?? const TimetableIndexBuilder(),
       _scheduleRepository = scheduleRepository ?? CourseScheduleRepository.getInstance(),
       _calendarRepository = calendarRepository ?? SchoolCalendarRepository.getInstance();

  final TongjiApi _api;
  final TimetableIndexBuilder _indexBuilder;
  final CourseScheduleRepository _scheduleRepository;
  final SchoolCalendarRepository _calendarRepository;

  /// 获取当前周数
  /// 
  /// 如果获取失败，返回默认值1
  Future<int> getSchoolCalendarCurrentWeek() async {
    final SchoolCalendarData? data = await _calendarRepository.getSchoolCalendar();
    return data?.week ?? 1;
  }

  /// 获取课表索引
  /// 
  /// 如果本地数据库没有数据，从服务器获取并保存
  Future<TimetableIndex> getTimetableIndex() async {
    CourseScheduleData? data = await _scheduleRepository.getCourseSchedule();
    if (data == null) {
      data = await _api.fetchStudentTimetable();
      await _scheduleRepository.saveCourseSchedule(data);
    }
    return _indexBuilder.buildIndex(data);
  }
}
