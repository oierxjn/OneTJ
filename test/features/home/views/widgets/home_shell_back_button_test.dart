import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:onetj/features/home/views/widgets/home_shell_back_button.dart';
import 'package:onetj/features/home/views/widgets/home_shell_layout_scope.dart';
import 'package:onetj/app/theme/theme_change_notifier.dart';
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

  tearDown(() async {
    themeChangeNotifier.dispose();
  });

  Future<void> pumpTestApp(WidgetTester tester) {
    final GoRouter router = GoRouter(
      initialLocation: '/page',
      routes: [
        GoRoute(
          path: '/page',
          builder: (context, state) {
            final Widget? homeBackButton = buildHomeShellBackButton(context);
            return Scaffold(
              appBar: AppBar(
                leading: homeBackButton,
                leadingWidth: homeBackButton == null
                    ? null
                    : homeShellBackButtonLeadingWidth,
              ),
            );
          },
        ),
      ],
    );
    return tester.pumpWidget(
      HomeShellLayoutScope(
        notifier: themeChangeNotifier,
        child: MaterialApp.router(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
  }

  testWidgets('缺少主页布局作用域时抛出明确的 FlutterError', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            buildHomeShellBackButton(context);
            return const SizedBox();
          },
        ),
      ),
    );

    final Object? exception = tester.takeException();
    expect(exception, isA<FlutterError>());
    expect(exception.toString(), contains('HomeShellLayoutScope'));
  });
  testWidgets('布局切换后会在应用栏显示返回入口', (tester) async {
    await pumpTestApp(tester);
    final appBarFinder = find.byType(AppBar);
    expect(tester.widget<AppBar>(appBarFinder).leading, isNull);

    await themeChangeNotifier.setHomeLayout(HomeLayout.functionGrid);
    await tester.pump();
    expect(tester.widget<AppBar>(appBarFinder).leading, isNotNull);
  });
}
