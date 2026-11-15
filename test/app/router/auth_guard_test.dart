import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/router/auth_guard.dart';
import 'package:onetj/app/session/session_controller.dart';

/// 游客态放行的公开路径（含设置子页与物理实验）。
const List<String> _publicLocations = <String>[
  RoutePaths.home,
  RoutePaths.homeDashboard,
  RoutePaths.homeTools,
  RoutePaths.homePhysicsLab,
  RoutePaths.homePhysicsLabMichelson,
  RoutePaths.homeSettings,
  RoutePaths.homeSettingsAbout,
  RoutePaths.homeSettingsDeveloper,
];

/// 游客态需要登录的数据页路径。
const List<String> _protectedLocations = <String>[
  RoutePaths.homeTimetable,
  RoutePaths.homeGrades,
  RoutePaths.homeCetScore,
  RoutePaths.homeStudentExams,
];

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

  group('resolveAuthDecision 游客态（guest）', () {
    test('启动页跳向首页而非登录页，登录与否由用户决定', () {
      final AuthRedirectDecision decision = resolveAuthDecision(
        status: AuthStatus.guest,
        location: RoutePaths.launcher,
      );

      expect(decision.redirectTo, RoutePaths.home);
      expect(decision.rememberLocation, isFalse);
    });

    test('登录页放行，不会重定向到自身', () {
      final AuthRedirectDecision decision = resolveAuthDecision(
        status: AuthStatus.guest,
        location: RoutePaths.login,
      );

      expect(decision.redirectTo, isNull);
    });

    test('公开页面一律放行', () {
      for (final String location in _publicLocations) {
        final AuthRedirectDecision decision = resolveAuthDecision(
          status: AuthStatus.guest,
          location: location,
        );

        expect(decision.redirectTo, isNull, reason: 'location=$location');
        expect(decision.rememberLocation, isFalse,
            reason: 'location=$location');
      }
    });

    test('数据页重定向到登录页并记下当前位置', () {
      for (final String location in _protectedLocations) {
        final AuthRedirectDecision decision = resolveAuthDecision(
          status: AuthStatus.guest,
          location: location,
        );

        expect(decision.redirectTo, RoutePaths.login,
            reason: 'location=$location');
        expect(decision.rememberLocation, isTrue, reason: 'location=$location');
      }
    });
  });

  group('resolveAuthDecision 失效态（expired）', () {
    test('数据页与公开页一律放行，不打断用户当前操作', () {
      for (final String location in <String>[
        ..._publicLocations,
        ..._protectedLocations,
      ]) {
        final AuthRedirectDecision decision = resolveAuthDecision(
          status: AuthStatus.expired,
          location: location,
        );

        expect(decision.redirectTo, isNull, reason: 'location=$location');
      }
    });

    test('登录页放行，重新登录入口必须可达', () {
      final AuthRedirectDecision decision = resolveAuthDecision(
        status: AuthStatus.expired,
        location: RoutePaths.login,
      );

      // 失效态不强制跳转：停在登录页等待用户完成重新登录，
      // 登录成功后由 authenticated 分支按待回跳位置离开。
      expect(decision.redirectTo, isNull);
      expect(decision.consumePendingLocation, isFalse);
    });

    test('停留在启动页时进入首页', () {
      final AuthRedirectDecision decision = resolveAuthDecision(
        status: AuthStatus.expired,
        location: RoutePaths.launcher,
      );

      expect(decision.redirectTo, RoutePaths.home);
    });
  });

  group('resolveAuthDecision 已登录', () {
    test('所有页面一律放行', () {
      for (final String location in <String>[
        ..._publicLocations,
        ..._protectedLocations,
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
      expect(decision.consumePendingLocation, isFalse);
    });

    test('停留在登录页时回到待回跳页面', () {
      final AuthRedirectDecision decision = resolveAuthDecision(
        status: AuthStatus.authenticated,
        location: RoutePaths.login,
        pendingLocation: RoutePaths.homeTimetable,
      );

      expect(decision.redirectTo, RoutePaths.homeTimetable);
      // 使用后必须消费，否则该值会残留到下一次登出/失效。
      expect(decision.consumePendingLocation, isTrue);
    });

    test('待回跳页面为空时回到首页', () {
      final AuthRedirectDecision decision = resolveAuthDecision(
        status: AuthStatus.authenticated,
        location: RoutePaths.login,
        pendingLocation: '',
      );

      expect(decision.redirectTo, RoutePaths.home);
      expect(decision.consumePendingLocation, isFalse);
    });
  });

  group('requiresAuthentication 路由分级', () {
    test('数据页需要登录', () {
      for (final String location in _protectedLocations) {
        expect(requiresAuthentication(location), isTrue,
            reason: 'location=$location');
      }
    });

    test('公开页不需要登录', () {
      for (final String location in <String>[
        ..._publicLocations,
        RoutePaths.launcher,
        RoutePaths.login,
      ]) {
        expect(requiresAuthentication(location), isFalse,
            reason: 'location=$location');
      }
    });
  });

  test('游客 → 数据页 → 登录页 → 已登录 不会产生重定向循环', () {
    // 第一步：从数据页被拦到登录页，并记下原位置。
    final AuthRedirectDecision blocked = resolveAuthDecision(
      status: AuthStatus.guest,
      location: RoutePaths.homeTimetable,
    );
    expect(blocked.redirectTo, RoutePaths.login);
    expect(blocked.rememberLocation, isTrue);

    // 第二步：登录页在游客状态下必须放行，否则会不停重定向到自身。
    final AuthRedirectDecision onLogin = resolveAuthDecision(
      status: AuthStatus.guest,
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