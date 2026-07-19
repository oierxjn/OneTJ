import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/router/app_router.dart';
import 'package:onetj/features/physics_lab/routes.dart';
import 'package:onetj/features/settings/routes.dart';
import 'package:onetj/features/tools/routes.dart';

void main() {
  test('主页 Shell 只保留工具和设置两个一级页面', () {
    expect(toolsShellRoutes, hasLength(1));
    expect(toolsShellRoutes.single.path, RoutePaths.homeTools);
    expect(toolsShellRoutes.single.routes, isEmpty);

    expect(settingsShellRoutes, hasLength(1));
    expect(settingsShellRoutes.single.path, RoutePaths.homeSettings);
    expect(settingsShellRoutes.single.routes, isEmpty);
  });

  test('物理实验保留原 URL 并作为顶层详情路由', () {
    expect(physicsLabDetailRoutes, hasLength(1));
    expect(physicsLabDetailRoutes.single.path, RoutePaths.homePhysicsLab);
  });

  test('应用根路由注册全部详情页面', () {
    final Iterable<String> topLevelPaths = AppRouter.router.configuration.routes
        .whereType<GoRoute>()
        .map((GoRoute route) => route.path);

    expect(
      topLevelPaths,
      containsAll(<String>[
        RoutePaths.homeGrades,
        RoutePaths.homePhysicsLab,
        ...settingsDetailRoutes.map((GoRoute route) => route.path),
      ]),
    );
  });
  test('设置编辑页保留原 URL 并作为顶层详情路由', () {
    expect(
      settingsDetailRoutes.map((GoRoute route) => route.path),
      orderedEquals(<String>[
        RoutePaths.homeSettingsAbout,
        RoutePaths.homeSettingsTimeSlots,
        RoutePaths.homeSettingsLaunchWallpaper,
        RoutePaths.homeSettingsDeveloper,
        RoutePaths.homeSettingsDeveloperLogs,
        RoutePaths.homeSettingsUserCollectionPolicy,
        RoutePaths.homeSettingsColorPicker,
      ]),
    );
  });
}
