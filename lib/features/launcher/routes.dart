import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/features/launcher/views/launcher_view.dart';

final List<GoRoute> launcherRoutes = [
  GoRoute(
    path: RoutePaths.launcher,
    name: 'launcher',
    builder: (context, state) => const LauncherView(),
  ),
];
