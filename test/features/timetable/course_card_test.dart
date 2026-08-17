import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/features/timetable/views/widgets/course_card.dart';
import 'package:onetj/models/timetable_index.dart';

void main() {
  testWidgets('invokes onTap for the displayed entry', (tester) async {
    final TimetableEntry entry = _entry();
    TimetableEntry? tappedEntry;

    await _pumpCourseCard(
      tester,
      entry: entry,
      onTap: () => tappedEntry = entry,
    );

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    expect(tappedEntry, same(entry));
  });

  testWidgets('renders fallback title and non-empty course details',
      (tester) async {
    await _pumpCourseCard(
      tester,
      entry: _entry(courseName: '', classCode: 'C01'),
      room: 'Room 101',
      teacher: 'Professor Wang',
    );

    expect(
      _cardTexts(tester),
      <String>['Unknown course', 'Room 101', 'Professor Wang', 'C01'],
    );
  });

  testWidgets('omits unavailable room teacher and class code', (tester) async {
    await _pumpCourseCard(
      tester,
      entry: _entry(classCode: ''),
    );

    expect(_cardTexts(tester), <String>['Linear Algebra']);
  });

  testWidgets('does not create a nested scroll view', (tester) async {
    await _pumpCourseCard(
      tester,
      entry: _entry(classCode: 'C01'),
      room: 'Room 101',
      teacher: 'Professor Wang',
    );

    expect(
      find.descendant(
        of: find.byType(CourseCard),
        matching: find.byType(SingleChildScrollView),
      ),
      findsNothing,
    );
  });

  testWidgets('clips overflowing details in a short card', (tester) async {
    await _pumpCourseCard(
      tester,
      entry: _entry(classCode: 'C01'),
      room: 'Room 101',
      teacher: 'Professor Wang',
      height: 40,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('uses padding tiers for narrow and wide cards', (tester) async {
    await _expectPadding(tester, width: 100, expectedPadding: 2);
    await _expectPadding(tester, width: 128, expectedPadding: 6);
    await _expectPadding(tester, width: 129, expectedPadding: 10);
  });
}

TimetableEntry _entry({
  String courseName = 'Linear Algebra',
  String classCode = 'C01',
}) {
  return TimetableEntry(
    courseName: courseName,
    courseCode: 'MATH201',
    classCode: classCode,
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
    weeks: const <int>[1],
    weekNum: '',
    teachingClassId: 123,
    sourceItemIndex: 0,
    sourceTimeTableIndex: 0,
  );
}

Future<void> _pumpCourseCard(
  WidgetTester tester, {
  required TimetableEntry entry,
  String room = '',
  String teacher = '',
  double width = 180,
  double height = 120,
  VoidCallback? onTap,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          height: height,
          child: CourseCard(
            entry: entry,
            roomBuilder: (_) => room,
            teacherBuilder: (_) => teacher,
            onTap: onTap,
          ),
        ),
      ),
    ),
  );
}

List<String> _cardTexts(WidgetTester tester) {
  return tester
      .widgetList<Text>(
        find.descendant(
          of: find.byType(CourseCard),
          matching: find.byType(Text),
        ),
      )
      .map((Text text) => text.data)
      .whereType<String>()
      .toList();
}

Future<void> _expectPadding(
  WidgetTester tester, {
  required double width,
  required double expectedPadding,
}) async {
  await _pumpCourseCard(tester, entry: _entry(), width: width);

  final layoutBuilderFinder = find.descendant(
    of: find.byType(CourseCard),
    matching: find.byType(LayoutBuilder),
  );
  final paddingFinder = find.descendant(
    of: layoutBuilderFinder,
    matching: find.byType(Padding),
  );
  expect(paddingFinder, findsOneWidget);
  expect(
    tester.widget<Padding>(paddingFinder).padding,
    EdgeInsets.all(expectedPadding),
  );
}
