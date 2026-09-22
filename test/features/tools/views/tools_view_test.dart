import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/features/home/views/widgets/home_shell_layout_scope.dart';
import 'package:onetj/features/tools/views/tools_view.dart';
import 'package:onetj/l10n/app_localizations.dart';
import 'package:onetj/models/theme_preferences.dart';
import 'package:onetj/repo/theme_repository.dart';

void main() {
  late ThemeChangeNotifier themeChangeNotifier;

  setUp(() async {
    final ThemeRepository repository =
        ThemeRepository(storage: InMemoryThemeStorage());
    await repository.initialize();
    themeChangeNotifier = ThemeChangeNotifier(repository: repository);
  });

  tearDown(() {
    themeChangeNotifier.dispose();
  });

  Future<void> pumpSubject(WidgetTester tester) {
    return tester.pumpWidget(
      HomeShellLayoutScope(
        notifier: themeChangeNotifier,
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ToolsView(),
        ),
      ),
    );
  }

  testWidgets('点击我的考试时提示功能暂未开放且保持在工具页', (tester) async {
    await pumpSubject(tester);

    await tester.tap(find.text('我的考试'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('该功能暂未开放，请等待信息办恢复。'), findsOneWidget);
  });

  testWidgets('底部导航布局下页面顶部无标题行', (tester) async {
    await pumpSubject(tester);

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('工具'), findsNothing);
    expect(find.text('常用工具与实验计算会集中在这里。'), findsOneWidget);
  });

  testWidgets('无 AppBar 时仍为状态栏保留高度', (tester) async {
    tester.view.padding = FakeViewPadding(top: 40);
    addTearDown(tester.view.reset);
    await pumpSubject(tester);

    final Finder subtitle = find.text('常用工具与实验计算会集中在这里。');
    expect(subtitle, findsOneWidget);
    // 40 需大于列表自带 padding 16 + 12，否则断言无法区分是否占位。
    expect(tester.getTopLeft(subtitle).dy, greaterThan(40));
  });

  testWidgets('网格布局下顶部显示返回入口与页面标题', (tester) async {
    await themeChangeNotifier.setHomeLayout(HomeLayout.functionGrid);
    await pumpSubject(tester);

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('返回主页'), findsOneWidget);
    expect(find.text('工具'), findsOneWidget);
    expect(find.text('常用工具与实验计算会集中在这里。'), findsOneWidget);
  });
}
