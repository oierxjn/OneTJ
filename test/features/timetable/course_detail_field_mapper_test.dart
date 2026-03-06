import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/features/timetable/models/course_detail_field_mapper.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/services/timetable_index_builder.dart';

void main() {
  group('mapCourseDetailExtraFields', () {
    test('merges item and timetable fields with timetable override', () {
      final CourseScheduleData data = CourseScheduleData(
        items: <CourseScheduleItemData>[
          CourseScheduleItemData(
            courseName: 'Math',
            assessmentMode: 'exam',
            credits: 3,
            roomCategory: 'normal-room',
            remark: '',
            timeTableList: const <CourseTimeTableItemData>[
              CourseTimeTableItemData(
                dayOfWeek: 1,
                timeStart: 1,
                timeEnd: 2,
                teacherCode: 'T001',
                roomCategory: 'lab-room',
                weekstr: '1-16',
              ),
            ],
          ),
        ],
      );

      final index = const TimetableIndexBuilder().buildIndex(data);
      final entry = index.allEntries.single;
      final List<CourseDetailField> fields = mapCourseDetailExtraFields(
        entry: entry,
        index: index,
      );

      final Map<String, String> mapped = <String, String>{
        for (final CourseDetailField f in fields) f.key: f.value,
      };
      expect(mapped['assessmentMode'], 'exam');
      expect(mapped['credits'], '3');
      expect(mapped['teacherCode'], 'T001');
      expect(mapped['weekstr'], '1-16');
      expect(mapped['roomCategory'], 'lab-room');
      expect(mapped.containsKey('remark'), isFalse);
    });
  });
}
