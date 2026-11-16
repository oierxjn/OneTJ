import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/app/session/session_controller.dart';

void main() {
  group('SessionController 状态转移', () {
    test('初始状态为 unknown', () {
      final SessionController controller = SessionController();

      expect(controller.status, AuthStatus.unknown);
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

    test('引导完成后的失效上报进入失效态（缓存保留）', () {
      final SessionController controller = SessionController();
      controller.completeBoot(AuthStatus.authenticated);

      controller.markUnauthenticated(reason: 'http_401');

      expect(controller.status, AuthStatus.expired);
      expect(controller.lastReason, 'http_401');
    });

    test('主动登出进入游客态', () {
      final SessionController controller = SessionController();
      controller.completeBoot(AuthStatus.authenticated);

      controller.markSignedOut();

      expect(controller.status, AuthStatus.guest);
      expect(controller.lastReason, 'sign_out');
    });

    test('状态未变化时不重复通知', () {
      final SessionController controller = SessionController();
      controller.completeBoot(AuthStatus.guest);
      int notifications = 0;
      controller.addListener(() => notifications += 1);

      controller.markSignedOut();

      expect(controller.status, AuthStatus.guest);
      expect(notifications, 0);
    });

    test('continueAsGuest 从失效态进入游客态', () {
      final SessionController controller = SessionController();
      controller.completeBoot(AuthStatus.expired);

      controller.continueAsGuest();

      expect(controller.status, AuthStatus.guest);
      expect(controller.lastReason, 'continue_as_guest');
    });

    test('continueAsGuest 已是游客时完全无副作用（幂等）', () {
      final SessionController controller = SessionController();
      controller.completeBoot(AuthStatus.guest);
      final String? reasonBefore = controller.lastReason;
      int notifications = 0;
      controller.addListener(() => notifications += 1);

      controller.continueAsGuest();

      expect(controller.status, AuthStatus.guest);
      expect(controller.lastReason, reasonBefore);
      expect(notifications, 0);
    });

    test('重复的失效上报不重复通知', () {
      final SessionController controller = SessionController()
        ..completeBoot(AuthStatus.authenticated);

      controller.markUnauthenticated(reason: 'first_401');
      int notifications = 0;
      controller.addListener(() => notifications += 1);
      controller.markUnauthenticated(reason: 'second_401');

      expect(controller.status, AuthStatus.expired);
      expect(notifications, 0);
    });

    test('登录成功翻转为已登录并通知', () {
      final SessionController controller = SessionController()
        ..completeBoot(AuthStatus.guest);
      int notifications = 0;
      controller.addListener(() => notifications += 1);

      controller.markAuthenticated();

      expect(controller.status, AuthStatus.authenticated);
      expect(controller.lastReason, 'login');
      expect(notifications, 1);
    });
  });

  group('SessionController 引导与显式事件的合并语义', () {
    test('引导期间的登录成功被忽略，completeBoot 正常发布结论', () {
      final SessionController controller = SessionController();
      int notifications = 0;
      controller.addListener(() => notifications += 1);

      controller.markAuthenticated();

      expect(controller.status, AuthStatus.unknown);
      expect(notifications, 0);

      controller.completeBoot(AuthStatus.guest);

      expect(controller.status, AuthStatus.guest);
      expect(notifications, 1);
    });

    test('引导期间的失效上报被忽略，completeBoot 正常发布结论', () {
      final SessionController controller = SessionController();

      controller.markUnauthenticated(reason: 'http_401');

      expect(controller.status, AuthStatus.unknown);

      controller.completeBoot(AuthStatus.authenticated);

      expect(controller.status, AuthStatus.authenticated);
      expect(controller.lastReason, 'boot');
    });

    test('completeBoot 不覆盖已登录状态，也不通知', () {
      final SessionController controller = SessionController()
        ..completeBoot(AuthStatus.authenticated);
      int notifications = 0;
      controller.addListener(() => notifications += 1);

      controller.completeBoot(AuthStatus.guest);
      controller.completeBoot(AuthStatus.expired);

      expect(controller.status, AuthStatus.authenticated);
      expect(controller.lastReason, 'boot');
      expect(notifications, 0);
    });

    test('completeBoot 不覆盖失效态与游客态', () {
      final SessionController expired = SessionController()
        ..completeBoot(AuthStatus.expired);
      expired.completeBoot(AuthStatus.authenticated);
      expect(expired.status, AuthStatus.expired);

      final SessionController guest = SessionController()
        ..completeBoot(AuthStatus.guest);
      guest.completeBoot(AuthStatus.authenticated);
      expect(guest.status, AuthStatus.guest);
    });

    test('completeBoot 重复发布相同结论不重复通知', () {
      final SessionController controller = SessionController();
      controller.completeBoot(AuthStatus.authenticated);
      int notifications = 0;
      controller.addListener(() => notifications += 1);

      controller.completeBoot(AuthStatus.authenticated);

      expect(controller.status, AuthStatus.authenticated);
      expect(notifications, 0);
    });
  });
}