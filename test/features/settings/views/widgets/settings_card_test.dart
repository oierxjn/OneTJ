import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/settings/views/widgets/expandable_radio_card.dart';
import 'package:onetj/features/settings/views/widgets/settings_card.dart';
import 'package:onetj/features/settings/views/widgets/settings_card_visual_state.dart';

void main() {
  /// 切换状态后先 pump 到动画中间帧，再 pump 到结束，
  /// 保证颜色插值路径上不抛异常（回归防护：泛型 Tween lerp Color 崩溃）。
  Future<void> pumpStatusTransition(
    WidgetTester tester,
    Widget Function(SettingsCardStatus status) build,
  ) async {
    SettingsCardStatus status = SettingsCardStatus.normal;
    late StateSetter setStatus;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              setStatus = setState;
              return build(status);
            },
          ),
        ),
      ),
    );

    setStatus(() => status = SettingsCardStatus.success);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);

    setStatus(() => status = SettingsCardStatus.error);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  }

  testWidgets('SettingsCard 状态色过渡动画期间不抛异常', (WidgetTester tester) async {
    await pumpStatusTransition(
      tester,
      (status) => SettingsCard(status: status, title: const Text('标题')),
    );
  });

  testWidgets('ExpandableRadioCard 状态色过渡动画期间不抛异常', (WidgetTester tester) async {
    await pumpStatusTransition(
      tester,
      (status) => ExpandableRadioCard<String>(
        title: '标题',
        summaryText: '摘要',
        value: 'a',
        options: const <RadioOption<String>>[
          RadioOption<String>(value: 'a', title: '选项A'),
          RadioOption<String>(value: 'b', title: '选项B'),
        ],
        onChanged: (_) {},
        status: status,
      ),
    );
  });
}
