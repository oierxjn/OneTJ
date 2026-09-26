import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/features/app_update/app_update_flow_coordinator.dart';
import 'package:onetj/features/dashboard/application/dashboard_data_service.dart';
import 'package:onetj/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:onetj/features/settings/routes.dart';
import 'package:onetj/features/home/views/home_view.dart';
import 'package:onetj/features/dashboard/views/dashboard_view.dart';
import 'package:onetj/features/timetable/application/timetable_data_service.dart';
import 'package:onetj/features/timetable/view_models/timetable_view_model.dart';
import 'package:onetj/features/timetable/views/timetable_view.dart';
import 'package:onetj/features/tools/routes.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/services/app_update_service.dart';
import 'package:onetj/services/external_launcher_service.dart';
import 'package:onetj/services/user_collection_service.dart';

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
          builder: (context, state) => DashboardView(
            viewModel: DashboardViewModel(
              dataService: appLocator<DashboardDataService>(),
              settingsRepository: appLocator<SettingsRepository>(),
              studentInfoRepository: appLocator<StudentInfoRepository>(),
              schoolCalendarRepository: appLocator<SchoolCalendarRepository>(),
              userCollectionService: appLocator<UserCollectionService>(),
              appUpdateService: appLocator<AppUpdateService>(),
            ),
            themeChangeNotifier: appLocator<ThemeChangeNotifier>(),
            appUpdateCoordinator: AppUpdateFlowCoordinator(
              appUpdateService: appLocator<AppUpdateService>(),
              externalLauncherService: appLocator<ExternalLauncherService>(),
            ),
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: RoutePaths.homeTimetable,
          name: 'timetable',
          builder: (context, state) => TimetableView(
            viewModel: TimetableViewModel(
              dataService: appLocator<TimetableDataService>(),
              settingsRepository: appLocator<SettingsRepository>(),
            ),
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        ...toolsShellRoutes,
      ],
    ),
    StatefulShellBranch(
      routes: [
        ...settingsShellRoutes,
      ],
    ),
  ],
);
