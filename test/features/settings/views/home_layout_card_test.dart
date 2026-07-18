import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/settings/views/widgets/home_layout_card.dart';
import 'package:onetj/models/theme_preferences.dart';

void main() {
  Future<void> pumpHomeLayoutCard(
    WidgetTester tester, {
    required ValueChanged<HomeLayout> onChanged,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: HomeLayoutCard(
              l10n: AppLocalizations.of(context),
              layout: HomeLayout.bottomNavigation,
              enabled: true,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('展开后显示两个主页布局选项，并通知选择结果', (tester) async {
    HomeLayout? selectedLayout;
    await pumpHomeLayoutCard(
      tester,
      onChanged: (layout) => selectedLayout = layout,
    );

    expect(find.text('主页布局'), findsOneWidget);
    await tester.tap(find.text('主页布局'));
    await tester.pumpAndSettle();

    expect(find.text('底部导航'), findsWidgets);
    expect(find.text('功能网格主页'), findsOneWidget);

    await tester.tap(find.text('功能网格主页'));
    await tester.pumpAndSettle();

    expect(selectedLayout, HomeLayout.functionGrid);
  });
}
