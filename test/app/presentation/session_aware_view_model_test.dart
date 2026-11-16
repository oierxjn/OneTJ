import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/app/presentation/session_aware_view_model.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/app/session/session_controller.dart';

/// 记录基类钩子调用的假子类。
class _FakeSessionViewModel extends SessionAwareViewModel<UiEvent> {
  _FakeSessionViewModel({required super.sessionController});

  int loadCount = 0;
  int clearCount = 0;
  bool dataLoaded = false;
  bool disposed = false;

  /// 供测试断言 protected 的 isGuest。
  bool get guestFlagForTest => isGuest;

  @override
  Future<void> load() async {
    loadCount += 1;
    if (!isGuest) {
      dataLoaded = true;
    }
  }

  @override
  void clearPersonalData() {
    clearCount += 1;
    dataLoaded = false;
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

void main() {
  late SessionController session;
  late _FakeSessionViewModel viewModel;

  setUp(() {
    session = SessionController();
    viewModel = _FakeSessionViewModel(sessionController: session);
  });

  tearDown(() {
    if (!viewModel.disposed) {
      viewModel.dispose();
    }
  });

  group('SessionAwareViewModel 状态分发', () {
    test('登录成功自动 load', () async {
      session.completeBoot(AuthStatus.guest);

      session.markAuthenticated();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.loadCount, 1);
      expect(viewModel.dataLoaded, isTrue);
    });

    test('进入游客态清内存并通知一次', () {
      session.completeBoot(AuthStatus.authenticated);
      int notifications = 0;
      viewModel.addListener(() => notifications += 1);

      session.markSignedOut();

      expect(viewModel.clearCount, 1);
      expect(viewModel.dataLoaded, isFalse);
      expect(notifications, 1);
    });

    test('失效态不触发 load 也不清内存', () async {
      // completeBoot(authenticated) 本身会触发一次自动 load，先消化掉。
      session.completeBoot(AuthStatus.authenticated);
      await Future<void>.delayed(Duration.zero);
      final int loadsBefore = viewModel.loadCount;
      final int clearsBefore = viewModel.clearCount;

      session.markUnauthenticated(reason: 'http_401');
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.loadCount, loadsBefore);
      expect(viewModel.clearCount, clearsBefore);
      expect(viewModel.dataLoaded, isTrue);
    });

    test('引导期间（unknown）不做任何动作', () async {
      session.markUnauthenticated(reason: 'missing_token');
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.loadCount, 0);
      expect(viewModel.clearCount, 0);
    });

    test('isGuest 随会话状态同步', () {
      session.completeBoot(AuthStatus.guest);
      expect(viewModel.guestFlagForTest, isTrue);

      session.markAuthenticated();
      expect(viewModel.guestFlagForTest, isFalse);

      session.markSignedOut();
      expect(viewModel.guestFlagForTest, isTrue);
    });

    test('游客态 load 由子类护栏决定，基类不代劳', () async {
      session.completeBoot(AuthStatus.guest);

      await viewModel.load();

      // 假子类 load 在游客态不置 dataLoaded，模拟子类入口护栏。
      expect(viewModel.dataLoaded, isFalse);
    });
  });

  group('SessionAwareViewModel 监听配对', () {
    test('dispose 后不再响应会话变化', () async {
      session.completeBoot(AuthStatus.authenticated);
      await Future<void>.delayed(Duration.zero);
      final int loadsBefore = viewModel.loadCount;
      final int clearsBefore = viewModel.clearCount;
      viewModel.dispose();

      session.markSignedOut();
      session.markAuthenticated();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.clearCount, clearsBefore);
      expect(viewModel.loadCount, loadsBefore);
    });
  });
}