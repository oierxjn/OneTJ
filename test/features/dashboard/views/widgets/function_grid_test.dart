import 'package:flutter/material.dart';
import 'package:full_svg_flutter/full_svg_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

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
          toolsLabel: 'tools',
          aboutLabel: 'about',
          onTimetableTap: () => onTap('timetable'),
          onPhysicsLabTap: () => onTap('physics-lab'),
          onSettingsTap: () => onTap('settings'),
          onGradesTap: () => onTap('grades'),
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

  testWidgets('窄屏按两列展示六个功能入口并分发点击事件', (tester) async {
    await tester.binding.setSurfaceSize(const Size(640, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    String? selected;
    await tester
        .pumpWidget(buildFunctionGrid(onTap: (value) => selected = value));

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(6));
    expect(crossAxisCount(tester), 2);

    final Offset timetablePosition = tester.getTopLeft(find.text('timetable'));
    final Offset physicsLabPosition =
        tester.getTopLeft(find.text('physics-lab'));
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

  testWidgets('宽屏图标会随卡片可用空间扩大', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(buildFunctionGrid(onTap: (_) {}));

    final List<FSvgPicture> icons =
        tester.widgetList<FSvgPicture>(find.byType(FSvgPicture)).toList();
    expect(icons, hasLength(6));
    for (final FSvgPicture icon in icons) {
      expect(icon.width, greaterThan(96));
      expect(icon.height, greaterThan(96));
      expect(icon.fit, BoxFit.contain);
    }
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
