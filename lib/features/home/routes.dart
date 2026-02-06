import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/features/home/views/home_view.dart';
import 'package:onetj/features/settings/views/settings_view.dart';
import 'package:onetj/features/dashboard/views/dashboard_view.dart';
import 'package:onetj/features/timetable/views/timetable_view.dart';

final StatefulShellRoute homeShellRoute = StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      HomeView(navigationShell: navigationShell),
  branches: [
    StatefulShellBranch(
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
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: RoutePaths.homeTimetable,
          name: 'timetable',
          builder: (context, state) => const TimetableView(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: RoutePaths.homeSettings,
          name: 'settings',
          builder: (context, state) => const SettingsView(),
        ),
      ],
    ),
  ],
);
