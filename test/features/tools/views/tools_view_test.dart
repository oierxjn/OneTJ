import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/features/home/views/widgets/home_shell_layout_scope.dart';
import 'package:onetj/features/tools/views/tools_view.dart';
import 'package:onetj/l10n/app_localizations.dart';
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
    expect(find.text('工具'), findsOneWidget);
    expect(find.text('该功能暂未开放，请等待信息办恢复。'), findsOneWidget);
  });

  testWidgets('窗口高度低于阈值时隐藏标题栏且内容仍可见', (tester) async {
    // setSurfaceSize 不影响 MediaQuery 读到的 view 尺寸，需直接设置 view。
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 540);
    addTearDown(tester.view.reset);
    await pumpSubject(tester);

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('工具'), findsNothing);
    expect(find.text('常用工具与实验计算会集中在这里。'), findsOneWidget);
  });
}
