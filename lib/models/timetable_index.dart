import 'package:onetj/repo/course_schedule_repository.dart';

/// 课程条目
/// 
/// 用于UI数据源，包含课程的所有信息
class TimetableEntry {
  const TimetableEntry({
    required this.courseName,
    required this.courseCode,
    required this.classCode,
    required this.className,
    required this.teacherName,
    required this.campus,
    required this.campusI18n,
    required this.roomId,
    required this.roomIdI18n,
    required this.dayOfWeek,
    required this.timeStart,
    required this.timeEnd,
    required this.weeks,
    required this.weekNum,
    required this.teachingClassId,
  });

  final String courseName;
  final String courseCode;
  final String classCode;
  final String className;
  final String teacherName;
  final String campus;
  final String campusI18n;
  final String roomId;
  final String roomIdI18n;
  final int dayOfWeek;
  final int timeStart;
  final int timeEnd;
  final List<int> weeks;
  final String weekNum;
  final int? teachingClassId;
}
/// 课程表索引
/// 
/// 用于UI数据源，快速查询课程
class TimetableIndex {
  const TimetableIndex({
    required this.byDayOfWeek,
    required this.byWeekThenDay,
    required this.allEntries,
    required this.nonTimetableItems,
  });

  /// 索引：一周的第 `n` 天 -> 课程列表
  final Map<int, List<TimetableEntry>> byDayOfWeek;

  /// 索引：第 `m` 周 -> 一周的星期 `n` -> 课程列表
  final Map<int, Map<int, List<TimetableEntry>>> byWeekThenDay;

  /// 扁平化的所有课程条目
  final List<TimetableEntry> allEntries;

  /// 原始数据中，timeTableList 为空的项
  final List<CourseScheduleItemData> nonTimetableItems;
}
