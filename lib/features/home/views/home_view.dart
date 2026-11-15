import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onetj/l10n/app_localizations.dart';

import 'package:onetj/app/constant/layout_constants.dart';
import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/session/session_controller.dart';
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
    required this.themeChangeNotifier,
    required this.sessionController,
  });

  final StatefulNavigationShell navigationShell;
  final ThemeChangeNotifier themeChangeNotifier;
  final SessionController sessionController;

  @override
  Widget build(BuildContext context) {
    return HomeShellLayoutScope(
      notifier: themeChangeNotifier,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[
          themeChangeNotifier,
          sessionController,
        ]),
        builder: (context, _) {
          final int currentIndex = navigationShell.currentIndex;
          final bool useBottomNavigation =
              themeChangeNotifier.preferences.homeLayout ==
                  HomeLayout.bottomNavigation;

          return Scaffold(
            body: Column(
              children: [
                if (sessionController.status == AuthStatus.expired)
                  _SessionExpiredBanner(
                    onRelogin: () => context.push(RoutePaths.login),
                  ),
                Expanded(child: navigationShell),
              ],
            ),
            bottomNavigationBar: useBottomNavigation
                ? NavigationBar(
                    height: kHomeBottomNavigationBarHeight,
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

/// 会话失效横幅：仅在 [AuthStatus.expired] 时出现在首页壳层顶部。
///
/// 失效态不强制跳转（缓存仍可读），由用户点击「重新登录」自行决定。
class _SessionExpiredBanner extends StatelessWidget {
  const _SessionExpiredBanner({required this.onRelogin});

  final VoidCallback onRelogin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.onErrorContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.sessionExpiredBanner,
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              ),
              TextButton(
                onPressed: onRelogin,
                child: Text(l10n.sessionExpiredRelogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}