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
  /// [session] 既作为 `refreshListenable`（登录态变化时重新求值守卫），
  /// 也在守卫判定需要回跳时记录当前位置。这里显式注入而非读取
  /// `appLocator`，使路由表本身可以脱离 DI 单独构造与测试。
  static GoRouter build({required SessionController session}) {
    return GoRouter(
      refreshListenable: session,
      redirect: (context, state) {
        final AuthRedirectDecision decision = resolveAuthDecision(
          status: session.status,
          location: state.matchedLocation,
          pendingLocation: session.pendingLocation,
        );
        if (decision.rememberLocation) {
          session.rememberPendingLocation(state.matchedLocation);
        }
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
