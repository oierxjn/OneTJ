import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:full_svg_flutter/full_svg_flutter.dart';

import 'package:onetj/features/dashboard/views/widgets/function_grid.dart';

void main() {
  Widget buildFunctionGrid({required void Function(String) onTap}) {
    return MaterialApp(
      home: Scaffold(
        body: FunctionGrid(
          timetableLabel: 'timetable',
          physicsLabLabel: 'physics-lab',
          settingsLabel: 'settings',
          gradesLabel: 'grades',
          cetScoreLabel: 'cet-score',
          studentExamsLabel: 'student-exams',
          toolsLabel: 'tools',
          aboutLabel: 'about',
          onTimetableTap: () => onTap('timetable'),
          onPhysicsLabTap: () => onTap('physics-lab'),
          onSettingsTap: () => onTap('settings'),
          onGradesTap: () => onTap('grades'),
          onCetScoreTap: () => onTap('cet-score'),
          onStudentExamsTap: () => onTap('student-exams'),
          onToolsTap: () => onTap('tools'),
          onAboutTap: () => onTap('about'),
        ),
      ),
    );
  }

  int crossAxisCount(WidgetTester tester) {
    final GridView gridView = tester.widget<GridView>(find.byType(GridView));
    return (gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
        .crossAxisCount;
  }

  testWidgets('窄屏按两列展示八个功能入口并分发点击事件', (tester) async {
    await tester.binding.setSurfaceSize(const Size(640, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    String? selected;
    await tester
        .pumpWidget(buildFunctionGrid(onTap: (value) => selected = value));

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(8));
    expect(crossAxisCount(tester), 2);

    final Offset timetablePosition = tester.getTopLeft(find.text('timetable'));
    final Offset physicsLabPosition =
        tester.getTopLeft(find.text('physics-lab'));
    final Offset settingsPosition = tester.getTopLeft(find.text('settings'));
    final Offset gradesPosition = tester.getTopLeft(find.text('grades'));
    final Offset cetScorePosition = tester.getTopLeft(find.text('cet-score'));
    final Offset studentExamsPosition =
        tester.getTopLeft(find.text('student-exams'));
    final Offset toolsPosition = tester.getTopLeft(find.text('tools'));
    final Offset aboutPosition = tester.getTopLeft(find.text('about'));
    expect(physicsLabPosition.dy, timetablePosition.dy);
    expect(settingsPosition.dy, greaterThan(timetablePosition.dy));
    expect(gradesPosition.dy, settingsPosition.dy);
    expect(cetScorePosition.dy, greaterThan(settingsPosition.dy));
    expect(studentExamsPosition.dy, cetScorePosition.dy);
    expect(toolsPosition.dy, greaterThan(cetScorePosition.dy));
    expect(aboutPosition.dy, toolsPosition.dy);

    await tester.tap(find.text('student-exams'));
    expect(selected, 'student-exams');
  });

  testWidgets('宽屏使用预渲染位图而不是运行时 SVG', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(buildFunctionGrid(onTap: (_) {}));

    expect(find.byType(FSvgPicture), findsNothing);
    expect(find.byType(Icon), findsNothing);

    final List<Image> images =
        tester.widgetList<Image>(find.byType(Image)).toList();
    expect(images, hasLength(8));
    expect(
      images
          .map((Image image) => (image.image as AssetImage).assetName)
          .toList(),
      <String>[
        'assets/icons/function_grid/alarm_clock_3d.png',
        'assets/icons/function_grid/memo_3d.png',
        'assets/icons/function_grid/gear_3d.png',
        'assets/icons/function_grid/anguished_face_3d.png',
        'assets/icons/function_grid/input_latin_letters_3d.png',
        'assets/icons/function_grid/memo_3d.png',
        'assets/icons/function_grid/desktop_computer_3d.png',
        'assets/icons/function_grid/teddy_bear_3d.png',
      ],
    );
  });
  testWidgets('宽屏按三列展示功能入口', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(buildFunctionGrid(onTap: (_) {}));

    expect(crossAxisCount(tester), 3);

    final Offset timetablePosition = tester.getTopLeft(find.text('timetable'));
    final Offset physicsLabPosition =
        tester.getTopLeft(find.text('physics-lab'));
    final Offset settingsPosition = tester.getTopLeft(find.text('settings'));
    final Offset gradesPosition = tester.getTopLeft(find.text('grades'));
    expect(physicsLabPosition.dy, timetablePosition.dy);
    expect(settingsPosition.dy, timetablePosition.dy);
    expect(gradesPosition.dy, greaterThan(timetablePosition.dy));
  });
}
