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
            timetableLabel: '课表',
            physicsLabLabel: '物理实验',
            settingsLabel: '设置',
            gradesLabel: '成绩查询',
            toolsLabel: '工具',
            aboutLabel: '关于',
            onTimetableTap: () => selected = '课表',
            onPhysicsLabTap: () => selected = '物理实验',
            onSettingsTap: () => selected = '设置',
            onGradesTap: () => selected = '成绩查询',
            onToolsTap: () => selected = '工具',
            onAboutTap: () => selected = '关于',
          ),
        ),
      ),
    );

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(6));
    final Offset timetablePosition = tester.getTopLeft(find.text('课表'));
    final Offset physicsLabPosition = tester.getTopLeft(find.text('物理实验'));
    final Offset settingsPosition = tester.getTopLeft(find.text('设置'));
    final Offset gradesPosition = tester.getTopLeft(find.text('成绩查询'));
    final Offset toolsPosition = tester.getTopLeft(find.text('工具'));
    final Offset aboutPosition = tester.getTopLeft(find.text('关于'));
    expect(physicsLabPosition.dy, timetablePosition.dy);
    expect(settingsPosition.dy, greaterThan(timetablePosition.dy));
    expect(gradesPosition.dy, settingsPosition.dy);
    expect(toolsPosition.dy, greaterThan(settingsPosition.dy));
    expect(aboutPosition.dy, toolsPosition.dy);

    await tester.tap(find.text('成绩查询'));
    expect(selected, '成绩查询');
  });
}
