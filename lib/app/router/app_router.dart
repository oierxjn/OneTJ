import 'package:go_router/go_router.dart';

import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/app/router/auth_guard.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/cet_score/routes.dart';
import 'package:onetj/features/grades/routes.dart';
import 'package:onetj/features/home/routes.dart';
import 'package:onetj/features/launcher/routes.dart';
import 'package:onetj/features/login/routes.dart';
import 'package:onetj/features/physics_lab/routes.dart';
import 'package:onetj/features/settings/routes.dart';
import 'package:onetj/features/student_exams/routes.dart';

class AppRouter {
  const AppRouter._();

  /// 构建应用路由表。
  ///
  /// [session] 作为 `refreshListenable`（登录态变化时重新求值守卫）。
  /// 这里显式注入而非读取 `appLocator`，使路由表本身可以脱离 DI 单独构造与测试。
  ///
  /// 深链前置条件（见 issue #65）：当前隐含假设应用总是从 `/` 启动，
  /// 由启动页执行引导并调用 `completeBoot` 退出 unknown。启用深链
  /// （intent-filter / Universal Link / web URL）前，必须让引导不依赖
  /// 初始路由——强制 `initialLocation: RoutePaths.launcher`（配合
  /// `overridePlatformDefaultLocation`），或把引导移出启动页路由
  /// （如在 `main()` 中完成），否则深链会绕过引导使状态永远 unknown。
  static GoRouter build({required SessionController session}) {
    return GoRouter(
      refreshListenable: session,
      redirect: (context, state) {
        final AuthRedirectDecision decision = resolveAuthDecision(
          status: session.status,
          location: state.matchedLocation,
        );
        if (decision.redirectTo == null) {
          return null;
        }
        AppLogger.logNavigation(
          from: state.matchedLocation,
          to: decision.redirectTo!,
          context: <String, Object?>{'source': 'auth_guard'},
        );
        return decision.redirectTo;
      },
      routes: [
        ...launcherRoutes,
        ...loginRoutes,

        // Shell 外的独立详情页面。
        ...gradesDetailRoutes,
        ...cetScoreDetailRoutes,
        ...studentExamsDetailRoutes,
        ...physicsLabDetailRoutes,
        ...settingsDetailRoutes,

        // Shell 内的首页、课表、工具与设置一级页面。
        homeShellRoute,
      ],
    );
  }
}
