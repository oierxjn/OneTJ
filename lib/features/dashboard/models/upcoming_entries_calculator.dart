import 'package:onetj/models/dashboard_upcoming_mode.dart';
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/models/timetable_index.dart';
import 'dashboard_model.dart';

/// 储存查询即将到来的课程的参数
///
/// [now] 当前时间
/// [entries] 所有课程
/// [timeSlotRanges] 节次时间范围
/// [currentWeek] 当前周数
/// [maxWeek] 最大周数
/// [mode] 显示模式
/// [count] 最多显示课程数，仅在 [DashboardUpcomingMode.count] 模式下生效
class UpcomingEntriesQuery {
  const UpcomingEntriesQuery({
    required this.now,
    required this.entries,
    required this.timeSlotRanges,
    required this.currentWeek,
    required this.maxWeek,
    required this.mode,
    required this.count,
  });

  final DateTime now;
  final List<TimetableEntry> entries;
  final List<TimePeriodRangeData> timeSlotRanges;
  final int currentWeek;
  final int maxWeek;
  final DashboardUpcomingMode mode;
  final int count;
}

class UpcomingEntriesCalculator {
  const UpcomingEntriesCalculator._();

  static bool isEntryOngoing({
    required TimetableEntry entry,
    required DateTime now,
    required List<TimePeriodRangeData> timeSlotRanges,
  }) {
    final int startIndex = entry.timeStart - 1;
    final int endIndex = entry.timeEnd - 1;
    if (startIndex < 0 ||
        startIndex >= timeSlotRanges.length ||
        endIndex < 0 ||
        endIndex >= timeSlotRanges.length) {
      return false;
    }
    final int startMinute = timeSlotRanges[startIndex].startMinutes;
    final int endMinute = timeSlotRanges[endIndex].endMinutes;
    final int nowMinutes = now.hour * 60 + now.minute;
    return startMinute <= nowMinutes && nowMinutes < endMinute;
  }

  static List<DashboardUpcomingEntryData> calculate(UpcomingEntriesQuery query) {
    final List<TimetableEntry> entries = calculateEntry(query);
    return entries.map((e) => DashboardUpcomingEntryData(
      entry: e,
      isOngoing: isEntryOngoing(
        entry: e,
        now: query.now,
        timeSlotRanges: query.timeSlotRanges,
      ),
    )).toList();
  }

  static List<TimetableEntry> calculateEntry(UpcomingEntriesQuery query) {
    switch (query.mode) {
      case DashboardUpcomingMode.thisWeek:
        return _upcomingThisWeek(query);
      case DashboardUpcomingMode.today:
        return _upcomingToday(query);
      case DashboardUpcomingMode.count:
        return _upcomingByCount(query);
    }
  }

  static List<TimetableEntry> _upcomingToday(UpcomingEntriesQuery query) {
    if (query.entries.isEmpty) {
      return const [];
    }
    return _entriesForWeekDay(
      query: query,
      week: query.currentWeek,
      day: query.now.weekday,
      onlyAfterNow: true,
    );
  }

  static List<TimetableEntry> _upcomingThisWeek(UpcomingEntriesQuery query) {
    if (query.entries.isEmpty) {
      return const [];
    }
    final int today = query.now.weekday;
    final List<TimetableEntry> result = [];
    for (int day = today; day <= 7; day += 1) {
      result.addAll(
        _entriesForWeekDay(
          query: query,
          week: query.currentWeek,
          day: day,
          onlyAfterNow: day == today,
        ),
      );
    }
    return result;
  }

  static List<TimetableEntry> _upcomingByCount(UpcomingEntriesQuery query) {
    if (query.entries.isEmpty ||
        query.count <= 0 ||
        query.currentWeek > query.maxWeek) {
      return const [];
    }
    final List<TimetableEntry> result = [];
    for (int week = query.currentWeek;
        week <= query.maxWeek && result.length < query.count;
        week += 1) {
      final int startDay = week == query.currentWeek ? query.now.weekday : 1;
      for (int day = startDay;
          day <= 7 && result.length < query.count;
          day += 1) {
        final List<TimetableEntry> dayEntries = _entriesForWeekDay(
          query: query,
          week: week,
          day: day,
          onlyAfterNow: week == query.currentWeek && day == query.now.weekday,
        );
        for (final TimetableEntry entry in dayEntries) {
          result.add(entry);
          if (result.length >= query.count) {
            break;
          }
        }
      }
    }
    return result;
  }

  static List<TimetableEntry> _entriesForWeekDay({
    required UpcomingEntriesQuery query,
    required int week,
    required int day,
    required bool onlyAfterNow,
  }) {
    final List<TimetableEntry> dayEntries = query.entries
        .where((entry) => entry.dayOfWeek == day && _matchesWeek(entry, week))
        .toList()
      ..sort((a, b) => a.timeStart.compareTo(b.timeStart));
    if (!onlyAfterNow) {
      return dayEntries;
    }
    dayEntries.removeWhere(
      (entry) => !_isOngoingOrAfterNow(entry, query.now, query.timeSlotRanges),
    );
    return dayEntries;
  }

  static bool _matchesWeek(TimetableEntry entry, int week) {
    if (entry.weeks.isEmpty) {
      return true;
    }
    return entry.weeks.contains(week);
  }

  static bool _isOngoingOrAfterNow(
    TimetableEntry entry,
    DateTime now,
    List<TimePeriodRangeData> timeSlotRanges,
  ) {
    return isEntryOngoing(
          entry: entry,
          now: now,
          timeSlotRanges: timeSlotRanges,
        ) ||
        _isAfterNow(entry, now, timeSlotRanges);
  }

  static bool _isAfterNow(
    TimetableEntry entry,
    DateTime now,
    List<TimePeriodRangeData> timeSlotRanges,
  ) {
    final int index = entry.timeStart - 1;
    if (index < 0 || index >= timeSlotRanges.length) {
      return true;
    }
    final int startMinute = timeSlotRanges[index].startMinutes;
    final int nowMinutes = now.hour * 60 + now.minute;
    return nowMinutes < startMinute;
  }
}
