import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/router/auth_guard.dart';
import 'package:onetj/app/session/session_controller.dart';

void main() {
  group('resolveAuthDecision 启动引导中（unknown）', () {
    test('任何路径都放行，停留在启动页', () {
      for (final String location in <String>[
        RoutePaths.launcher,
        RoutePaths.login,
        RoutePaths.home,
        RoutePaths.homeDashboard,
        RoutePaths.homeTimetable,
        RoutePaths.homeGrades,
      ]) {
        final AuthRedirectDecision decision = resolveAuthDecision(
          status: AuthStatus.unknown,
          location: location,
        );

        expect(decision.redirectTo, isNull, reason: 'location=$location');
        expect(decision.rememberLocation, isFalse, reason: 'location=$location');
      }
    });
  });

  group('resolveAuthDecision 未登录', () {
    test('启动页重定向到登录页，且不记入回跳目标（避免循环）', () {
      final AuthRedirectDecision decision = resolveAuthDecision(
        status: AuthStatus.unauthenticated,
        location: RoutePaths.launcher,
      );

      expect(decision.redirectTo, RoutePaths.login);
      expect(decision.rememberLocation, isFalse);
    });

    test('登录页放行，不会重定向到自身', () {
      final AuthRedirectDecision decision = resolveAuthDecision(
        status: AuthStatus.unauthenticated,
        location: RoutePaths.login,
      );

      expect(decision.redirectTo, isNull);
    });

    test('受保护页面重定向到登录页并记下当前位置', () {
      final AuthRedirectDecision decision = resolveAuthDecision(
        status: AuthStatus.unauthenticated,
        location: RoutePaths.homeTimetable,
      );

      expect(decision.redirectTo, RoutePaths.login);
      expect(decision.rememberLocation, isTrue);
    });
  });

  group('resolveAuthDecision 已登录', () {
    test('受保护页面一律放行', () {
      for (final String location in <String>[
        RoutePaths.home,
        RoutePaths.homeDashboard,
        RoutePaths.homeSettings,
        RoutePaths.homeGrades,
      ]) {
        final AuthRedirectDecision decision = resolveAuthDecision(
          status: AuthStatus.authenticated,
          location: location,
        );

        expect(decision.redirectTo, isNull, reason: 'location=$location');
      }
    });

    test('停留在启动页时进入首页', () {
      final AuthRedirectDecision decision = resolveAuthDecision(
        status: AuthStatus.authenticated,
        location: RoutePaths.launcher,
      );

      expect(decision.redirectTo, RoutePaths.home);
    });

    test('停留在登录页时回到待回跳页面', () {
      final AuthRedirectDecision decision = resolveAuthDecision(
        status: AuthStatus.authenticated,
        location: RoutePaths.login,
        pendingLocation: RoutePaths.homeTimetable,
      );

      expect(decision.redirectTo, RoutePaths.homeTimetable);
    });

    test('待回跳页面为空时回到首页', () {
      final AuthRedirectDecision decision = resolveAuthDecision(
        status: AuthStatus.authenticated,
        location: RoutePaths.login,
        pendingLocation: '',
      );

      expect(decision.redirectTo, RoutePaths.home);
    });
  });

  test('未登录 → 登录页 → 已登录 不会产生重定向循环', () {
    // 第一步：从受保护页面被拦到登录页，并记下原位置。
    final AuthRedirectDecision blocked = resolveAuthDecision(
      status: AuthStatus.unauthenticated,
      location: RoutePaths.homeTimetable,
    );
    expect(blocked.redirectTo, RoutePaths.login);
    expect(blocked.rememberLocation, isTrue);

    // 第二步：登录页在未登录状态下必须放行，否则会不停重定向到自身。
    final AuthRedirectDecision onLogin = resolveAuthDecision(
      status: AuthStatus.unauthenticated,
      location: RoutePaths.login,
    );
    expect(onLogin.redirectTo, isNull);

    // 第三步：登录成功后从登录页离开，回到原页面。
    final AuthRedirectDecision resumed = resolveAuthDecision(
      status: AuthStatus.authenticated,
      location: RoutePaths.login,
      pendingLocation: RoutePaths.homeTimetable,
    );
    expect(resumed.redirectTo, RoutePaths.homeTimetable);
  });
}
