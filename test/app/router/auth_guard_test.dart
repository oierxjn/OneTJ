import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/router/auth_guard.dart';
import 'package:onetj/app/session/session_controller.dart';

/// 所有业务路径（数据页 + 公开页），守卫对已登录/失效/游客均应放行。
const List<String> _businessLocations = <String>[
  RoutePaths.home,
  RoutePaths.homeDashboard,
  RoutePaths.homeTimetable,
  RoutePaths.homeGrades,
  RoutePaths.homeCetScore,
  RoutePaths.homeStudentExams,
  RoutePaths.homeTools,
  RoutePaths.homePhysicsLab,
  RoutePaths.homeSettings,
  RoutePaths.homeSettingsAbout,
];

void main() {
  group('resolveAuthDecision 启动引导中（unknown）', () {
    test('任何路径都放行，停留在启动页', () {
      for (final String location in <String>[
        RoutePaths.launcher,
        RoutePaths.login,
        ..._businessLocations,
      ]) {
        final AuthRedirectDecision decision = resolveAuthDecision(
          status: AuthStatus.unknown,
          location: location,
        );

        expect(decision.redirectTo, isNull, reason: 'location=$location');
      }
    });
  });

  group('resolveAuthDecision 已登录', () {
    test('业务页面一律放行', () {
      for (final String location in _businessLocations) {
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

    test('停留在登录页时回首页（登录成功出口）', () {
      final AuthRedirectDecision decision = resolveAuthDecision(
        status: AuthStatus.authenticated,
        location: RoutePaths.login,
      );

      expect(decision.redirectTo, RoutePaths.home);
    });
  });

  group('resolveAuthDecision 失效态（expired）', () {
    test('业务页面与登录页一律放行，不打断用户', () {
      for (final String location in <String>[
        ..._businessLocations,
        RoutePaths.login,
      ]) {
        final AuthRedirectDecision decision = resolveAuthDecision(
          status: AuthStatus.expired,
          location: location,
        );

        expect(decision.redirectTo, isNull, reason: 'location=$location');
      }
    });

    test('停留在启动页时进入首页', () {
      final AuthRedirectDecision decision = resolveAuthDecision(
        status: AuthStatus.expired,
        location: RoutePaths.launcher,
      );

      expect(decision.redirectTo, RoutePaths.home);
    });
  });

  group('resolveAuthDecision 游客态（guest）', () {
    test('业务页面（含数据页）与登录页一律放行，门禁下沉到页面', () {
      for (final String location in <String>[
        ..._businessLocations,
        RoutePaths.login,
      ]) {
        final AuthRedirectDecision decision = resolveAuthDecision(
          status: AuthStatus.guest,
          location: location,
        );

        expect(decision.redirectTo, isNull, reason: 'location=$location');
      }
    });

    test('停留在启动页时进入首页而非登录页', () {
      final AuthRedirectDecision decision = resolveAuthDecision(
        status: AuthStatus.guest,
        location: RoutePaths.launcher,
      );

      expect(decision.redirectTo, RoutePaths.home);
    });
  });

  test('游客访问数据页不再被重定向（页内门禁）', () {
    for (final String location in <String>[
      RoutePaths.homeTimetable,
      RoutePaths.homeGrades,
      RoutePaths.homeCetScore,
      RoutePaths.homeStudentExams,
    ]) {
      final AuthRedirectDecision decision = resolveAuthDecision(
        status: AuthStatus.guest,
        location: location,
      );

      expect(decision.redirectTo, isNull, reason: 'location=$location');
    }
  });

  test('登录成功出口无重定向循环', () {
    // 游客在登录页放行；登录成功后从登录页回首页；首页放行。
    expect(
      resolveAuthDecision(status: AuthStatus.guest, location: RoutePaths.login)
          .redirectTo,
      isNull,
    );
    expect(
      resolveAuthDecision(
        status: AuthStatus.authenticated,
        location: RoutePaths.login,
      ).redirectTo,
      RoutePaths.home,
    );
    expect(
      resolveAuthDecision(
        status: AuthStatus.authenticated,
        location: RoutePaths.home,
      ).redirectTo,
      isNull,
    );
  });
}