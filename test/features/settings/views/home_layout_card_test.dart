import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/l10n/app_localizations.dart';

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

    final headerTile = find
        .descendant(
          of: find.byType(HomeLayoutCard),
          matching: find.byType(ListTile),
        )
        .first;
    await tester.tap(headerTile);
    await tester.pumpAndSettle();

    final options = find.byWidgetPredicate(
      (Widget widget) => widget is RadioListTile<HomeLayout>,
    );
    final functionGridOption = find.byWidgetPredicate(
      (Widget widget) =>
          widget is RadioListTile<HomeLayout> &&
          widget.value == HomeLayout.functionGrid,
    );
    expect(options, findsNWidgets(2));

    await tester.tap(functionGridOption);
    await tester.pumpAndSettle();

    expect(selectedLayout, HomeLayout.functionGrid);
  });
}
