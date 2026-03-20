import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/dashboard/models/dashboard_model.dart';
import 'package:onetj/features/dashboard/models/upcoming_entries_calculator.dart';
import 'package:onetj/models/dashboard_upcoming_mode.dart';
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/models/timetable_index.dart';

void main() {
  const List<TimePeriodRangeData> ranges = <TimePeriodRangeData>[
    TimePeriodRangeData(startMinutes: 8 * 60, endMinutes: 8 * 60 + 45),
    TimePeriodRangeData(startMinutes: 9 * 60, endMinutes: 9 * 60 + 45),
    TimePeriodRangeData(startMinutes: 10 * 60, endMinutes: 10 * 60 + 45),
  ];

  TimetableEntry entry({
    required String id,
    required int day,
    required int start,
    required List<int> weeks,
  }) {
    return TimetableEntry(
      courseName: id,
      courseCode: id,
      classCode: id,
      className: id,
      teacherName: 't',
      campus: '',
      campusI18n: '',
      roomId: '',
      roomIdI18n: '',
      roomLabel: '',
      dayOfWeek: day,
      timeStart: start,
      timeEnd: start,
      weeks: weeks,
      weekNum: '',
      teachingClassId: null,
      sourceItemIndex: 0,
      sourceTimeTableIndex: 0,
    );
  }

  group('UpcomingEntriesCalculator', () {
    test('today mode returns only today entries after now', () {
      final List<TimetableEntry> entries = <TimetableEntry>[
        entry(id: 'today-past', day: 1, start: 1, weeks: <int>[5]),
        entry(id: 'today-future', day: 1, start: 3, weeks: <int>[5]),
        entry(id: 'tomorrow', day: 2, start: 1, weeks: <int>[5]),
      ];
      final UpcomingEntriesQuery query = UpcomingEntriesQuery(
        now: DateTime(2026, 1, 26, 9, 30), // Monday
        entries: entries,
        timeSlotRanges: ranges,
        currentWeek: 5,
        maxWeek: 20,
        mode: DashboardUpcomingMode.today,
        count: 3,
      );

      final List<DashboardUpcomingEntryData> result =
          UpcomingEntriesCalculator.calculate(query);

      expect(result.map((e) => e.entry.courseName), <String>['today-future']);
      expect(result.first.isOngoing, isFalse);
    });

    test('thisWeek mode returns remaining entries in current week', () {
      final List<TimetableEntry> entries = <TimetableEntry>[
        entry(id: 'today-past', day: 1, start: 1, weeks: <int>[5]),
        entry(id: 'today-future', day: 1, start: 3, weeks: <int>[5]),
        entry(id: 'wed', day: 3, start: 1, weeks: <int>[5]),
        entry(id: 'next-week', day: 1, start: 1, weeks: <int>[6]),
      ];
      final UpcomingEntriesQuery query = UpcomingEntriesQuery(
        now: DateTime(2026, 1, 26, 9, 30), // Monday
        entries: entries,
        timeSlotRanges: ranges,
        currentWeek: 5,
        maxWeek: 20,
        mode: DashboardUpcomingMode.thisWeek,
        count: 3,
      );

      final List<DashboardUpcomingEntryData> result =
          UpcomingEntriesCalculator.calculate(query);

      expect(
        result.map((e) => e.entry.courseName),
        <String>['today-future', 'wed'],
      );
      expect(result.first.isOngoing, isFalse);
      expect(result[1].isOngoing, isFalse);
    });

    test('count mode fills across weeks up to count', () {
      final List<TimetableEntry> entries = <TimetableEntry>[
        entry(id: 'w5-mon', day: 1, start: 3, weeks: <int>[5]),
        entry(id: 'w5-tue', day: 2, start: 1, weeks: <int>[5]),
        entry(id: 'w6-mon', day: 1, start: 1, weeks: <int>[6]),
        entry(id: 'w6-wed', day: 3, start: 1, weeks: <int>[6]),
      ];
      final UpcomingEntriesQuery query = UpcomingEntriesQuery(
        now: DateTime(2026, 1, 26, 9, 30), // Monday week 5
        entries: entries,
        timeSlotRanges: ranges,
        currentWeek: 5,
        maxWeek: 20,
        mode: DashboardUpcomingMode.count,
        count: 3,
      );

      final List<DashboardUpcomingEntryData> result =
          UpcomingEntriesCalculator.calculate(query);

      expect(
        result.map((e) => e.entry.courseName),
        <String>['w5-mon', 'w5-tue', 'w6-mon'],
      );
      expect(result.first.isOngoing, isTrue);
      expect(result[1].isOngoing, isFalse);
      expect(result[2].isOngoing, isFalse);
    });

    test('first item is not ongoing when it is not today', () {
      final List<TimetableEntry> entries = <TimetableEntry>[
        entry(id: 'tomorrow-first', day: 2, start: 3, weeks: <int>[5]),
        entry(id: 'wed-second', day: 3, start: 3, weeks: <int>[5]),
      ];
      final UpcomingEntriesQuery query = UpcomingEntriesQuery(
        now: DateTime(2026, 1, 26, 10, 10), // Monday week 5
        entries: entries,
        timeSlotRanges: ranges,
        currentWeek: 5,
        maxWeek: 20,
        mode: DashboardUpcomingMode.thisWeek,
        count: 2,
      );

      final List<DashboardUpcomingEntryData> result =
          UpcomingEntriesCalculator.calculate(query);

      expect(
        result.map((e) => e.entry.courseName),
        <String>['tomorrow-first', 'wed-second'],
      );
      expect(result.first.isOngoing, isFalse);
      expect(result[1].isOngoing, isFalse);
    });

    test('isEntryOngoing returns false when currentWeek does not match', () {
      final TimetableEntry mondayWeekSix = entry(
        id: 'w6-mon',
        day: 1,
        start: 3,
        weeks: <int>[6],
      );

      final bool ongoing = UpcomingEntriesCalculator.isEntryOngoing(
        entry: mondayWeekSix,
        now: DateTime(2026, 1, 26, 10, 10), // Monday week 5 time in slot 3
        currentWeek: 5,
        timeSlotRanges: ranges,
      );

      expect(ongoing, isFalse);
    });

    test('count mode returns empty when currentWeek > maxWeek', () {
      final UpcomingEntriesQuery query = UpcomingEntriesQuery(
        now: DateTime(2026, 1, 26, 9, 30),
        entries: <TimetableEntry>[
          entry(id: 'a', day: 1, start: 3, weeks: <int>[8]),
        ],
        timeSlotRanges: ranges,
        currentWeek: 8,
        maxWeek: 7,
        mode: DashboardUpcomingMode.count,
        count: 3,
      );

      final List<DashboardUpcomingEntryData> result =
          UpcomingEntriesCalculator.calculate(query);

      expect(result, isEmpty);
    });
  });
}
