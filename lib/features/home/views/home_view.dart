import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onetj/l10n/app_localizations.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/features/home/views/widgets/home_shell_layout_scope.dart';
import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/models/theme_preferences.dart';

class _TabConfig {
  const _TabConfig({
    required this.route,
    required this.labelBuilder,
    required this.icon,
    required this.selectedIcon,
  });

  final String route;
  final String Function(BuildContext) labelBuilder;
  final IconData icon;
  final IconData selectedIcon;
}

final List<_TabConfig> _tabs = [
  _TabConfig(
    route: RoutePaths.homeDashboard,
    labelBuilder: (context) => AppLocalizations.of(context).tabDashboard,
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
  ),
  _TabConfig(
    route: RoutePaths.homeTimetable,
    labelBuilder: (context) => AppLocalizations.of(context).tabTimetable,
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month,
  ),
  _TabConfig(
    route: RoutePaths.homeTools,
    labelBuilder: (context) => AppLocalizations.of(context).tabTools,
    icon: Icons.build_outlined,
    selectedIcon: Icons.build,
  ),
  _TabConfig(
    route: RoutePaths.homeSettings,
    labelBuilder: (context) => AppLocalizations.of(context).tabSettings,
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
];

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final ThemeChangeNotifier themeChangeNotifier =
        appLocator<ThemeChangeNotifier>();
    return HomeShellLayoutScope(
      notifier: themeChangeNotifier,
      child: AnimatedBuilder(
        animation: themeChangeNotifier,
        builder: (context, _) {
          final int currentIndex = navigationShell.currentIndex;
          final bool useBottomNavigation =
              themeChangeNotifier.preferences.homeLayout ==
                  HomeLayout.bottomNavigation;

          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: useBottomNavigation
                ? NavigationBar(
                    selectedIndex: currentIndex,
                    onDestinationSelected: navigationShell.goBranch,
                    destinations: [
                      for (final tab in _tabs)
                        NavigationDestination(
                          icon: Icon(tab.icon),
                          selectedIcon: Icon(tab.selectedIcon),
                          label: tab.labelBuilder(context),
                        ),
                    ],
                  )
                : null,
          );
        },
      ),
    );
  }
}
