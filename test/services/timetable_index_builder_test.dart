import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/services/timetable_index_builder.dart';

void main() {
  group('TimetableIndexBuilder source references', () {
    test('stores source indices and keeps sourceData for back-reference', () {
      final CourseScheduleData data = CourseScheduleData(
        items: <CourseScheduleItemData>[
          CourseScheduleItemData(
            courseName: 'Math',
            timeTableList: const <CourseTimeTableItemData>[
              CourseTimeTableItemData(dayOfWeek: 1, timeStart: 1, timeEnd: 2),
              CourseTimeTableItemData(dayOfWeek: 2, timeStart: 3, timeEnd: 4),
            ],
          ),
        ],
      );

      final TimetableIndexBuilder builder = TimetableIndexBuilder();
      final index = builder.buildIndex(data);

      expect(index.sourceData, same(data));
      expect(index.allEntries, hasLength(2));
      expect(index.allEntries[0].sourceItemIndex, 0);
      expect(index.allEntries[0].sourceTimeTableIndex, 0);
      expect(index.allEntries[1].sourceItemIndex, 0);
      expect(index.allEntries[1].sourceTimeTableIndex, 1);
    });
  });
}
