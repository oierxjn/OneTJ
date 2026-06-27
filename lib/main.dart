import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/app/app_lifecycle_host.dart';
import 'package:onetj/app/router/app_router.dart';
import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/services/app_update_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: 初始化流程重构 —— Hive.initFlutter()、configureDependencies()、
  // ThemeChangeNotifier.initialize() 等应统一收敛到 AppBootstrap 或
  // configureDependencies 中，确保 runApp 之前所有异步初始化完成，
  // OneTJApp 可恢复为 StatelessWidget。
  Hive.initFlutter();
  configureDependencies();
  runApp(
    AppLifecycleHost(
      appUpdateService: appLocator<AppUpdateService>(),
      child: const OneTJApp(),
    ),
  );
}

class OneTJApp extends StatefulWidget {
  const OneTJApp({super.key});

  @override
  State<OneTJApp> createState() => _OneTJAppState();
}

class _OneTJAppState extends State<OneTJApp> {
  late final ThemeChangeNotifier _themeNotifier;

  @override
  void initState() {
    super.initState();
    // TODO: 初始化流程重构后，此行应移至 runApp 之前
    _themeNotifier = appLocator<ThemeChangeNotifier>();
    _themeNotifier.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeNotifier,
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
            colorScheme: _themeNotifier.lightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: _themeNotifier.darkColorScheme,
            useMaterial3: true,
          ),
          themeMode: _themeNotifier.themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
