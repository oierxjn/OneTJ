import 'package:onetj/models/timetable_index.dart';
import 'package:onetj/repo/course_schedule_repository.dart';

class TimetableIndexBuilder {
  const TimetableIndexBuilder();

  TimetableIndex buildIndex(CourseScheduleData data) {
    final Map<int, List<TimetableEntry>> byDayOfWeek = {};
    final Map<int, Map<int, List<TimetableEntry>>> byWeekThenDay = {};
    final List<TimetableEntry> allEntries = [];
    final List<Object> nonTimetableItems = [];

    for (final CourseScheduleItemData item in data.items) {
      final List<CourseTimeTableItemData>? timeTableList = item.timeTableList;
      if (timeTableList == null || timeTableList.isEmpty) {
        nonTimetableItems.add(item);
        continue;
      }

      for (final CourseTimeTableItemData timeItem in timeTableList) {
        final List<int> weeks = timeItem.weeks ?? const [];
        final TimetableEntry entry = TimetableEntry(
          courseName: item.courseName ?? timeItem.courseName,
          courseCode: item.courseCode ?? timeItem.courseCode,
          classCode: item.classCode ?? timeItem.classCode,
          className: item.className ?? timeItem.className,
          teacherName: timeItem.teacherName ?? item.teacherName,
          campus: timeItem.campus ?? item.campus,
          campusI18n: timeItem.campusI18n ?? item.campusI18n,
          roomId: timeItem.roomId ?? item.classRoom,
          roomIdI18n: timeItem.roomIdI18n ?? item.classRoomI18n,
          dayOfWeek: timeItem.dayOfWeek,
          timeStart: timeItem.timeStart,
          timeEnd: timeItem.timeEnd,
          weeks: weeks,
          weekNum: timeItem.weekNum,
          teachingClassId: timeItem.teachingClassId ?? item.teachingClassId,
        );

        allEntries.add(entry);

        final int? day = entry.dayOfWeek;
        if (day != null) {
          final List<TimetableEntry> dayList =
              byDayOfWeek.putIfAbsent(day, () => []);
          dayList.add(entry);
        }

        if (weeks.isNotEmpty && day != null) {
          for (final int week in weeks) {
            final Map<int, List<TimetableEntry>> weekMap =
                byWeekThenDay.putIfAbsent(week, () => {});
            final List<TimetableEntry> dayList =
                weekMap.putIfAbsent(day, () => []);
            dayList.add(entry);
          }
        }
      }
    }

    return TimetableIndex(
      byDayOfWeek: byDayOfWeek,
      byWeekThenDay: byWeekThenDay,
      allEntries: allEntries,
      nonTimetableItems: nonTimetableItems,
    );
  }
}
