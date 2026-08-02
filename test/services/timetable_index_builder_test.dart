import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/services/timetable_index_builder.dart';

void main() {
  group('TimetableIndexBuilder', () {
    test('builds day and week indexes while preserving source references', () {
      final CourseScheduleData data = CourseScheduleData(
        items: <CourseScheduleItemData>[
          CourseScheduleItemData(
            courseName: 'Math',
            timeTableList: const <CourseTimeTableItemData>[
              CourseTimeTableItemData(
                dayOfWeek: 1,
                timeStart: 1,
                timeEnd: 2,
                weeks: <int>[1, 3],
              ),
              CourseTimeTableItemData(
                dayOfWeek: 3,
                timeStart: 3,
                timeEnd: 4,
              ),
            ],
          ),
          const CourseScheduleItemData(courseName: 'Without timetable'),
          const CourseScheduleItemData(
            courseName: 'Empty timetable',
            timeTableList: <CourseTimeTableItemData>[],
          ),
        ],
      );

      final index = const TimetableIndexBuilder().buildIndex(data);
      final mondayEntry = index.allEntries[0];
      final wednesdayEntry = index.allEntries[1];

      expect(index.sourceData, same(data));
      expect(index.allEntries, hasLength(2));
      expect(mondayEntry.sourceItemIndex, 0);
      expect(mondayEntry.sourceTimeTableIndex, 0);
      expect(wednesdayEntry.sourceItemIndex, 0);
      expect(wednesdayEntry.sourceTimeTableIndex, 1);

      expect(index.byDayOfWeek.keys, unorderedEquals(<int>[1, 3]));
      expect(index.byDayOfWeek[1], hasLength(1));
      expect(index.byDayOfWeek[1]!.single, same(mondayEntry));
      expect(index.byDayOfWeek[3], hasLength(1));
      expect(index.byDayOfWeek[3]!.single, same(wednesdayEntry));

      expect(index.byWeekThenDay.keys, unorderedEquals(<int>[1, 3]));
      expect(index.byWeekThenDay[1]![1], hasLength(1));
      expect(index.byWeekThenDay[1]![1]!.single, same(mondayEntry));
      expect(index.byWeekThenDay[3]![1], hasLength(1));
      expect(index.byWeekThenDay[3]![1]!.single, same(mondayEntry));
      expect(index.byWeekThenDay.containsKey(2), isFalse);

      expect(
        index.nonTimetableItems,
        <CourseScheduleItemData>[data.items[1], data.items[2]],
      );
    });

    test('uses scheduling fallbacks when timetable fields are missing', () {
      final CourseScheduleData data = CourseScheduleData(
        items: <CourseScheduleItemData>[
          const CourseScheduleItemData(
            timeTableList: <CourseTimeTableItemData>[
              CourseTimeTableItemData(),
            ],
          ),
        ],
      );

      final index = const TimetableIndexBuilder().buildIndex(data);
      final entry = index.allEntries.single;

      expect(entry.courseName, isEmpty);
      expect(entry.dayOfWeek, 7);
      expect(entry.timeStart, 1);
      expect(entry.timeEnd, 1);
      expect(entry.weeks, isEmpty);
      expect(index.byDayOfWeek[7], hasLength(1));
      expect(index.byDayOfWeek[7]!.single, same(entry));
      expect(index.byWeekThenDay, isEmpty);
    });
  });
}
