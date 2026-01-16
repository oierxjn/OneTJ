import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onetj/features/lancher/views/lancher_view.dart';
import 'package:onetj/features/login/views/login_view.dart';

void main() {
  runApp(const OneTJApp());
}

const String appTitle = '一统同济';

class OneTJApp extends StatelessWidget {
  const OneTJApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          name: 'launcher',
          builder: (context, state) => const LancherView(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginView(),
        ),
      ],
    );

    return MaterialApp.router(
      title: appTitle,
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
