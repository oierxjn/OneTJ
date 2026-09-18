import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/features/timetable/views/widgets/timetable_action_dial.dart';

void main() {
  Future<void> pumpDial(WidgetTester tester, {required VoidCallback onTap}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TimetableActionDial(
                width: 72,
                actions: [
                  TimetableDialAction(
                    icon: Icons.today,
                    label: '回到今天',
                    onTap: onTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('点击触发器展开动作面板，选择后触发回调并收起', (tester) async {
    var tapped = false;
    await pumpDial(tester, onTap: () => tapped = true);

    expect(find.text('回到今天'), findsNothing);
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    expect(find.text('回到今天'), findsOneWidget);

    await tester.tap(find.text('回到今天'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
    expect(find.text('回到今天'), findsNothing);
  });

  testWidgets('点击面板外任意处收起', (tester) async {
    var tapped = false;
    await pumpDial(tester, onTap: () => tapped = true);

    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    expect(find.text('回到今天'), findsOneWidget);

    await tester.tapAt(const Offset(400, 300));
    await tester.pumpAndSettle();
    expect(find.text('回到今天'), findsNothing);
    expect(tapped, isFalse);
  });

  testWidgets('再次点击触发器收起', (tester) async {
    await pumpDial(tester, onTap: () {});

    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    expect(find.text('回到今天'), findsOneWidget);

    // 触发器图标是同一个 expand_more，展开时只是旋转了 180°。
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    expect(find.text('回到今天'), findsNothing);
  });
}
