import 'package:go_router/go_router.dart';

import 'package:onetj/features/grades/routes.dart';
import 'package:onetj/features/home/routes.dart';
import 'package:onetj/features/launcher/routes.dart';
import 'package:onetj/features/login/routes.dart';
import 'package:onetj/features/physics_lab/routes.dart';
import 'package:onetj/features/settings/routes.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    routes: [
      ...launcherRoutes,
      ...loginRoutes,
      ...gradesRoutes,
      ...physicsLabRoutes,
      ...settingsDetailRoutes,
      homeShellRoute,
    ],
  );
}
