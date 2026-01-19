import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/home/views/home_view.dart';
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
        path: '/',
        name: 'launcher',
        builder: (context, state) => const LauncherView(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeView(),
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
