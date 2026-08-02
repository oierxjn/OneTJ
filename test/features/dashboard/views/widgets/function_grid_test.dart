import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/features/dashboard/views/widgets/function_grid.dart';

void main() {
  testWidgets('按既定顺序展示六个功能入口并分发点击事件', (tester) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FunctionGrid(
            timetableLabel: 'timetable',
            physicsLabLabel: 'physics-lab',
            settingsLabel: 'settings',
            gradesLabel: 'grades',
            toolsLabel: 'tools',
            aboutLabel: 'about',
            onTimetableTap: () => selected = 'timetable',
            onPhysicsLabTap: () => selected = 'physics-lab',
            onSettingsTap: () => selected = 'settings',
            onGradesTap: () => selected = 'grades',
            onToolsTap: () => selected = 'tools',
            onAboutTap: () => selected = 'about',
          ),
        ),
      ),
    );

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(6));
    final Offset timetablePosition = tester.getTopLeft(find.text('timetable'));
    final Offset physicsLabPosition = tester.getTopLeft(find.text('physics-lab'));
    final Offset settingsPosition = tester.getTopLeft(find.text('settings'));
    final Offset gradesPosition = tester.getTopLeft(find.text('grades'));
    final Offset toolsPosition = tester.getTopLeft(find.text('tools'));
    final Offset aboutPosition = tester.getTopLeft(find.text('about'));
    expect(physicsLabPosition.dy, timetablePosition.dy);
    expect(settingsPosition.dy, greaterThan(timetablePosition.dy));
    expect(gradesPosition.dy, settingsPosition.dy);
    expect(toolsPosition.dy, greaterThan(settingsPosition.dy));
    expect(aboutPosition.dy, toolsPosition.dy);

    await tester.tap(find.text('grades'));
    expect(selected, 'grades');
  });
}
