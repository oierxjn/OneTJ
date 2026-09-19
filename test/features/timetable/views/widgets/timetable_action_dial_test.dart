import 'package:flutter/gestures.dart';
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

    expect(find.byIcon(Icons.today), findsNothing);
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.today), findsOneWidget);

    await tester.tap(find.byIcon(Icons.today));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
    expect(find.byIcon(Icons.today), findsNothing);
  });

  testWidgets('展开与收起时触发器 chevron 旋转 180°', (tester) async {
    await pumpDial(tester, onTap: () {});

    AnimatedRotation rotation() => tester.widget<AnimatedRotation>(
      find.ancestor(of: find.byIcon(Icons.expand_more), matching: find.byType(AnimatedRotation)),
    );

    expect(rotation().turns, 0);
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    expect(rotation().turns, 0.5);

    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    expect(rotation().turns, 0);
  });

  testWidgets('点击面板外任意处收起', (tester) async {
    var tapped = false;
    await pumpDial(tester, onTap: () => tapped = true);

    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.today), findsOneWidget);

    await tester.tapAt(const Offset(400, 300));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.today), findsNothing);
    expect(tapped, isFalse);
  });

  testWidgets('再次点击触发器收起', (tester) async {
    await pumpDial(tester, onTap: () {});

    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.today), findsOneWidget);

    // 触发器图标是同一个 expand_more，展开时只是旋转了 180°。
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.today), findsNothing);
  });

  testWidgets('鼠标悬停动作按钮时文字标签显示在按钮右侧', (tester) async {
    await pumpDial(tester, onTap: () {});

    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    final Offset fabCenter = tester.getCenter(find.byIcon(Icons.today));
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: fabCenter);
    addTearDown(mouse.removePointer);

    // 悬停前无标签文字。
    expect(find.text('回到今天'), findsNothing);
    await mouse.moveTo(fabCenter);
    await tester.pumpAndSettle();
    expect(find.text('回到今天'), findsOneWidget);
    // 标签应出现在按钮右侧：文字左边缘大于按钮右边缘。
    expect(
      tester.getTopLeft(find.text('回到今天')).dx,
      greaterThan(tester.getTopRight(find.byIcon(Icons.today)).dx),
    );

    // 回归：overlay 条目是紧约束，标签 Material 不得撑满全屏。
    final Size labelBox = tester.getSize(
      find
          .ancestor(
            of: find.text('回到今天'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(labelBox.longestSide, lessThan(200));

    await mouse.moveTo(const Offset(400, 300));
    await tester.pumpAndSettle();
    expect(find.text('回到今天'), findsNothing);
  });

  testWidgets('busy 时触发器显示转圈指示器且无 chevron', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TimetableActionDial(
                width: 72,
                busy: true,
                actions: [
                  TimetableDialAction(
                    icon: Icons.today,
                    label: '回到今天',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.expand_more), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 转圈指示器永不静止，不能用 pumpAndSettle；固定推进一帧即可。
    // 触发器仍可点开，动作面板正常工作。
    await tester.tap(find.byType(CircularProgressIndicator));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.today), findsOneWidget);
  });

  testWidgets('触发器框宽被压缩到 35 时两个 FAB 仍保持 40×40', (tester) async {
    // 时间列宽的响应式下限是 35；FAB 的紧约束会被父级约束钳制，
    // 若触发器框不设最小宽度，会被压成 35×40 的胶囊。
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TimetableActionDial(
                width: 35,
                actions: [
                  TimetableDialAction(
                    icon: Icons.today,
                    label: '回到今天',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    final Size trigger = tester.getSize(
      find
          .ancestor(
            of: find.byIcon(Icons.expand_more),
            matching: find.byType(Material),
          )
          .first,
    );
    final Size action = tester.getSize(
      find
          .ancestor(
            of: find.byIcon(Icons.today),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(trigger, const Size(40, 40));
    expect(action, const Size(40, 40));
  });
}
