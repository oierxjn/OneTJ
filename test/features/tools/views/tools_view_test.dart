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
}
