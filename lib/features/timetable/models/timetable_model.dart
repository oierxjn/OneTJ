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
  })  : _api = api ?? TongjiApi(),
        _indexBuilder = indexBuilder ?? const TimetableIndexBuilder(),
        _scheduleRepository =
            scheduleRepository ?? CourseScheduleRepository.getInstance(),
        _calendarRepository =
            calendarRepository ?? SchoolCalendarRepository.getInstance();

  final TongjiApi _api;
  final TimetableIndexBuilder _indexBuilder;
  final CourseScheduleRepository _scheduleRepository;
  final SchoolCalendarRepository _calendarRepository;

  /// 获取当前周数
  ///
  /// 如果获取失败，返回默认值1
  Future<int> getSchoolCalendarCurrentWeek() async {
    await _calendarRepository.warmUp();
    final SchoolCalendarData data = await _calendarRepository.getOrFetch(
      now: DateTime.now(),
      fetcher: _api.fetchSchoolCalendarCurrentTerm,
    );
    return data.week;
  }

  /// 获取课表索引
  ///
  /// 如果本地数据库没有数据，从服务器获取并保存
  Future<TimetableIndex> getTimetableIndex() async {
    await _scheduleRepository.warmUp();
    final CourseScheduleData data = await _scheduleRepository.getOrFetch(
      now: DateTime.now(),
      fetcher: _api.fetchStudentTimetable,
    );
    return _indexBuilder.buildIndex(data);
  }

  Future<DateTime?> getLastFetchedAt() async {
    final CourseScheduleCacheMeta? meta =
        await _scheduleRepository.getCachedMeta(refreshFromStorage: false);
    if (meta == null || meta.lastFetchedAtMillis <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(meta.lastFetchedAtMillis)
        .toLocal();
  }
}
