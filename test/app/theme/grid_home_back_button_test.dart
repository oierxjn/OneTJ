import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/app/theme/grid_home_back_button.dart';
import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/models/theme_preferences.dart';
import 'package:onetj/repo/theme_repository.dart';

void main() {
  late ThemeChangeNotifier themeChangeNotifier;

  setUp(() async {
    await appLocator.reset();
    ThemeRepository.resetForTesting(storage: InMemoryThemeStorage());
    final ThemeRepository repository = ThemeRepository.getInstance();
    await repository.initialize();
    themeChangeNotifier = ThemeChangeNotifier(repository: repository);
    appLocator.registerSingleton<ThemeChangeNotifier>(themeChangeNotifier);
  });

  tearDown(() async {
    themeChangeNotifier.dispose();
    await appLocator.reset();
  });

  Future<void> pumpTestApp(WidgetTester tester) {
    final GoRouter router = GoRouter(
      initialLocation: '/page',
      routes: [
        GoRoute(
          path: '/page',
          builder: (context, state) {
            final Widget? homeBackButton = buildGridHomeBackButton(context);
            return Scaffold(
              appBar: AppBar(
                leading: homeBackButton,
                leadingWidth: homeBackButton == null ? null : 112,
              ),
            );
          },
        ),
        GoRoute(
          path: '/home/dashboard',
          builder: (context, state) => const Scaffold(body: Text('dashboard')),
        ),
      ],
    );
    return tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  testWidgets('仅在功能网格布局中显示并可返回主页', (tester) async {
    await pumpTestApp(tester);
    expect(find.text('返回主页'), findsNothing);

    await themeChangeNotifier.setHomeLayout(HomeLayout.functionGrid);
    await pumpTestApp(tester);
    expect(find.text('返回主页'), findsOneWidget);

    await tester.tap(find.text('返回主页'));
    await tester.pumpAndSettle();

    expect(find.text('dashboard'), findsOneWidget);
  });
}
