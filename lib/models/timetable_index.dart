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

  final String? courseName;
  final String? courseCode;
  final String? classCode;
  final String? className;
  final String? teacherName;
  final String? campus;
  final String? campusI18n;
  final String? roomId;
  final String? roomIdI18n;
  final int? dayOfWeek;
  final int? timeStart;
  final int? timeEnd;
  final List<int> weeks;
  final String? weekNum;
  final int? teachingClassId;
}

class TimetableIndex {
  const TimetableIndex({
    required this.byDayOfWeek,
    required this.byWeekThenDay,
    required this.allEntries,
    required this.nonTimetableItems,
  });

  /// Day of week (1-7) -> entries.
  final Map<int, List<TimetableEntry>> byDayOfWeek;

  /// Week number -> day of week (1-7) -> entries.
  final Map<int, Map<int, List<TimetableEntry>>> byWeekThenDay;

  /// Flattened list of all timetable entries.
  final List<TimetableEntry> allEntries;

  /// Original items whose timeTableList is null.
  final List<Object> nonTimetableItems;
}
