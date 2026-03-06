import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/features/timetable/views/widgets/course_card.dart';
import 'package:onetj/models/timetable_index.dart';

void main() {
  testWidgets('invokes onTap when card is tapped', (tester) async {
    bool tapped = false;
    const TimetableEntry entry = TimetableEntry(
      courseName: 'Linear Algebra',
      courseCode: 'MATH201',
      classCode: 'C01',
      className: 'Class C01',
      teacherName: 'Teacher',
      campus: '',
      campusI18n: '',
      roomId: '',
      roomIdI18n: '',
      roomLabel: '',
      dayOfWeek: 1,
      timeStart: 1,
      timeEnd: 2,
      weeks: <int>[1],
      weekNum: '',
      teachingClassId: 123,
      sourceItemIndex: 0,
      sourceTimeTableIndex: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 120,
            child: CourseCard(
              entry: entry,
              roomBuilder: (_) => '',
              teacherBuilder: (_) => '',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(CourseCard));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}
