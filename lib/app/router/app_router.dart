import 'package:go_router/go_router.dart';

import 'package:onetj/features/home/routes.dart';
import 'package:onetj/features/launcher/routes.dart';
import 'package:onetj/features/login/routes.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    routes: [
      ...launcherRoutes,
      ...loginRoutes,
      homeShellRoute,
    ],
  );
}
