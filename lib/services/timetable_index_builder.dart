import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/models/timetable_index.dart';
import 'package:onetj/repo/course_schedule_repository.dart';

/// 课程表索引构建器
///
/// 用于构建课程表索引
class TimetableIndexBuilder {
  const TimetableIndexBuilder();

  TimetableIndex buildIndex(CourseScheduleData data) {
    /// 索引：一周的星期`n` -> 课程列表
    final Map<int, List<TimetableEntry>> byDayOfWeek = {};

    /// 索引：第 `m` 周 -> 一周的星期 `n` -> 课程列表
    final Map<int, Map<int, List<TimetableEntry>>> byWeekThenDay = {};

    /// 所有课程条目
    final List<TimetableEntry> allEntries = [];

    /// 原始数据中，timeTableList为空的项
    final List<CourseScheduleItemData> nonTimetableItems = [];

    for (int itemIndex = 0; itemIndex < data.items.length; itemIndex += 1) {
      final CourseScheduleItemData item = data.items[itemIndex];
      final List<CourseTimeTableItemData>? timeTableList = item.timeTableList;
      // 将没有时间表的项添加到nonTimetableItems
      if (timeTableList == null || timeTableList.isEmpty) {
        nonTimetableItems.add(item);
        continue;
      }

      for (int timeIndex = 0;
          timeIndex < timeTableList.length;
          timeIndex += 1) {
        final CourseTimeTableItemData timeItem = timeTableList[timeIndex];
        // 将Timetable中每节课程都看作一个独立的课程，即使他们的课程代码、班级代码、班级名称相同
        final List<int> weeks = timeItem.weeks ?? const [];
        final List<String> missingFields = <String>[
          if (timeItem.dayOfWeek == null) 'dayOfWeek',
          if (timeItem.timeStart == null) 'timeStart',
          if (timeItem.timeEnd == null) 'timeEnd',
        ];
        if (missingFields.isNotEmpty) {
          AppLogger.warning(
            'Course timetable entry missing required scheduling fields; using fallback defaults',
            loggerName: 'TimetableIndexBuilder',
            code: 'TIMETABLE_INDEX_MISSING_FIELDS',
            context: <String, Object?>{
              'missingFields': missingFields.join(','),
              'courseName': item.courseName ?? timeItem.courseName ?? '',
              'courseCode': item.courseCode ?? timeItem.courseCode ?? '',
              'weekNum': timeItem.weekNum ?? '',
              'weeks': weeks.join(','),
              'sourceItemIndex': itemIndex,
              'sourceTimeTableIndex': timeIndex,
              'dayOfWeek': timeItem.dayOfWeek,
              'timeStart': timeItem.timeStart,
              'timeEnd': timeItem.timeEnd,
            },
          );
        }
        final TimetableEntry entry = TimetableEntry(
          courseName: item.courseName ?? timeItem.courseName ?? '',
          courseCode: item.courseCode ?? timeItem.courseCode ?? '',
          classCode: item.classCode ?? timeItem.classCode ?? '',
          className: item.className ?? timeItem.className ?? '',
          teacherName: timeItem.teacherName ?? item.teacherName ?? '',
          campus: timeItem.campus ?? item.campus ?? '',
          campusI18n: timeItem.campusI18n ?? item.campusI18n ?? '',
          roomId: timeItem.roomId ?? item.classRoom ?? '',
          roomIdI18n: timeItem.roomIdI18n ?? item.classRoomI18n ?? '',
          roomLabel: timeItem.roomLabel ?? item.roomLabel ?? '',
          dayOfWeek: timeItem.dayOfWeek ?? 7,
          timeStart: timeItem.timeStart ?? 1,
          timeEnd: timeItem.timeEnd ?? timeItem.timeStart ?? 1,
          weeks: weeks,
          weekNum: timeItem.weekNum ?? '',
          teachingClassId: timeItem.teachingClassId ?? item.teachingClassId,
          sourceItemIndex: itemIndex,
          sourceTimeTableIndex: timeIndex,
        );

        allEntries.add(entry);

        // 记录这节课是星期几的课程
        final int day = entry.dayOfWeek;
        // 将这节课添加到 byDayOfWeek 索引中
        final List<TimetableEntry> dayList =
            byDayOfWeek.putIfAbsent(day, () => []);
        dayList.add(entry);

        if (weeks.isNotEmpty) {
          // 将这节课添加到 byWeekThenDay 索引中
          for (final int week in weeks) {
            final Map<int, List<TimetableEntry>> weekMap =
                byWeekThenDay.putIfAbsent(week, () => {});
            final List<TimetableEntry> weekDayList =
                weekMap.putIfAbsent(day, () => []);
            weekDayList.add(entry);
          }
        }
      }
    }

    return TimetableIndex(
      byDayOfWeek: byDayOfWeek,
      byWeekThenDay: byWeekThenDay,
      allEntries: allEntries,
      nonTimetableItems: nonTimetableItems,
      sourceData: data,
    );
  }
}
