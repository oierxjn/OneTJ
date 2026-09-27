import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/app/session/session_controller.dart';

void main() {
  group('SessionController 状态转移', () {
    test('初始状态为 unknown', () {
      final SessionController controller = SessionController();

      expect(controller.status, AuthStatus.unknown);
      expect(controller.pendingLocation, isNull);
    });

    test('completeBoot 发布初始鉴权结果并通知监听者', () {
      final SessionController controller = SessionController();
      int notifications = 0;
      controller.addListener(() => notifications += 1);

      controller.completeBoot(AuthStatus.authenticated);

      expect(controller.status, AuthStatus.authenticated);
      expect(notifications, 1);
    });

    test('completeBoot 忽略 unknown，保持未完成引导', () {
      final SessionController controller = SessionController();

      controller.completeBoot(AuthStatus.unknown);

      expect(controller.status, AuthStatus.unknown);
    });

    test('引导期间的上报被忽略，避免启动页未结束就跳转', () {
      final SessionController controller = SessionController();

      controller.markUnauthenticated(reason: 'missing_token');

      expect(controller.status, AuthStatus.unknown);
    });

    test('引导完成后的失效上报会翻转状态', () {
      final SessionController controller = SessionController();
      controller.completeBoot(AuthStatus.authenticated);

      controller.markUnauthenticated(reason: 'http_401');

      expect(controller.status, AuthStatus.unauthenticated);
      expect(controller.lastReason, 'http_401');
    });

    test('状态未变化时不重复通知', () {
      final SessionController controller = SessionController();
      controller.completeBoot(AuthStatus.unauthenticated);
      int notifications = 0;
      controller.addListener(() => notifications += 1);

      controller.markSignedOut();

      expect(controller.status, AuthStatus.unauthenticated);
      expect(notifications, 0);
    });
  });

  group('SessionController 待回跳位置', () {
    test('remember 后可一次性取走', () {
      final SessionController controller = SessionController();

      controller.rememberPendingLocation('/home/timetable');

      expect(controller.pendingLocation, '/home/timetable');
      expect(controller.consumePendingLocation(), '/home/timetable');
      expect(controller.pendingLocation, isNull);
      expect(controller.consumePendingLocation(), isNull);
    });

    test('空位置被忽略', () {
      final SessionController controller = SessionController();

      controller.rememberPendingLocation('');

      expect(controller.pendingLocation, isNull);
    });

    test('会话失效时清空待回跳位置', () {
      final SessionController controller = SessionController();
      controller.completeBoot(AuthStatus.authenticated);
      controller.rememberPendingLocation('/home/timetable');

      controller.markUnauthenticated(reason: 'refresh_token_expired');

      expect(controller.pendingLocation, isNull);
    });

    test('登录成功时保留待回跳位置，供守卫消费', () {
      final SessionController controller = SessionController();
      controller.rememberPendingLocation('/home/grades');

      controller.markAuthenticated();

      expect(controller.status, AuthStatus.authenticated);
      expect(controller.pendingLocation, '/home/grades');
    });
  });
}
