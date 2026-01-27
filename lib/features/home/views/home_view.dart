import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';

class _TabConfig {
  const _TabConfig({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const List<_TabConfig> _tabs = [
  _TabConfig(
    route: RoutePaths.homeDashboard,
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
  ),
  _TabConfig(
    route: RoutePaths.homeTimetable,
    label: 'Timetable',
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month,
  ),
  _TabConfig(
    route: RoutePaths.homeSettings,
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
];

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.child,
  });

  final Widget child;

  int _locationToIndex(String location) {
    final int index =
        _tabs.indexWhere((tab) => location.startsWith(tab.route));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final int currentIndex = _locationToIndex(location);
    final _TabConfig currentTab = _tabs[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTab.label),
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          final String target = _tabs[index].route;
          if (!location.startsWith(target)) {
            context.go(target);
          }
        },
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
