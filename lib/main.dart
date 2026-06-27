import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/app/app_lifecycle_host.dart';
import 'package:onetj/app/router/app_router.dart';
import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/services/app_update_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(
    AppLifecycleHost(
      appUpdateService: appLocator<AppUpdateService>(),
      child: const OneTJApp(),
    ),
  );
}

class OneTJApp extends StatelessWidget {
  const OneTJApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeChangeNotifier themeNotifier =
        appLocator<ThemeChangeNotifier>();
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp.router(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'CN'),
            Locale('en'),
          ],
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          theme: ThemeData(
            colorScheme: themeNotifier.lightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: themeNotifier.darkColorScheme,
            useMaterial3: true,
          ),
          themeMode: themeNotifier.themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
