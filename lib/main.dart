import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/features/home/views/dashboard_view.dart';
import 'package:onetj/features/home/views/home_view.dart';
import 'package:onetj/features/home/views/settings_view.dart';
import 'package:onetj/features/home/views/timetable_view.dart';
import 'package:onetj/features/launcher/views/launcher_view.dart';
import 'package:onetj/features/login/views/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OneTJApp());
}


class OneTJApp extends StatelessWidget {
  const OneTJApp({super.key});

  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: RoutePaths.launcher,
        name: 'launcher',
        builder: (context, state) => const LauncherView(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: 'login',
        builder: (context, state) => const LoginView(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeView(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            redirect: (context, state) => RoutePaths.homeDashboard,
          ),
          GoRoute(
            path: RoutePaths.homeDashboard,
            name: 'home',
            builder: (context, state) => const DashboardView(),
          ),
          GoRoute(
            path: RoutePaths.homeTimetable,
            name: 'timetable',
            builder: (context, state) => const TimetableView(),
          ),
          GoRoute(
            path: RoutePaths.homeSettings,
            name: 'settings',
            builder: (context, state) => const SettingsView(),
          ),
        ],
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(125, 230, 90, 255),
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
