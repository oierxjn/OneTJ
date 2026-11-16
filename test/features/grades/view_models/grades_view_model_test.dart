import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/grades/application/grades_data_service.dart';
import 'package:onetj/features/grades/view_models/grades_view_model.dart';
import 'package:onetj/models/undergraduate_score_data.dart';

/// 可注入结果与计数的成绩服务桩：区分缓存优先取数与强刷。
class _FakeGradesDataService implements GradesDataService {
  _FakeGradesDataService({this.result});

  UndergraduateScoreData? result;
  int loadCount = 0;
  int refreshCount = 0;

  @override
  Future<void> warmUpCache() async {}

  @override
  Future<UndergraduateScoreData> getUndergraduateScore() async {
    loadCount += 1;
    return result!;
  }

  @override
  Future<UndergraduateScoreData> fetchUndergraduateScore({int? calendarId}) =>
      throw UnimplementedError();

  @override
  Future<UndergraduateScoreData> refreshUndergraduateScore() async {
    refreshCount += 1;
    return result!;
  }

  @override
  Future<void> clearCachedData() async {}
}

void main() {
  group('GradesViewModel 会话感知', () {
    test('游客态 load 早退，不发起拉取', () async {
      final SessionController session = SessionController()
        ..completeBoot(AuthStatus.guest);
      final _FakeGradesDataService service = _FakeGradesDataService();
      final GradesViewModel viewModel = GradesViewModel(
        dataService: service,
        sessionController: session,
      );

      await viewModel.load();

      expect(service.loadCount, 0);
      expect(viewModel.viewData, isNull);
      expect(viewModel.loading, isFalse);
      viewModel.dispose();
    });

    test('登出进入游客态时清空内存中的成绩', () async {
      final SessionController session = SessionController()
        ..completeBoot(AuthStatus.guest);
      final _FakeGradesDataService service = _FakeGradesDataService(
        result: const UndergraduateScoreData(),
      );
      final GradesViewModel viewModel = GradesViewModel(
        dataService: service,
        sessionController: session,
      );
      session.markAuthenticated();
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.viewData, isNotNull);

      session.markSignedOut();

      expect(viewModel.viewData, isNull);
      expect(viewModel.selectedTermIndex, 0);
      viewModel.dispose();
    });

    test('重新登录成功后自动强刷（不走缓存优先取数）', () async {
      final SessionController session = SessionController()
        ..completeBoot(AuthStatus.guest);
      final _FakeGradesDataService service = _FakeGradesDataService(
        result: const UndergraduateScoreData(),
      );
      final GradesViewModel viewModel = GradesViewModel(
        dataService: service,
        sessionController: session,
      );
      await viewModel.load();
      expect(service.loadCount, 0);
      expect(service.refreshCount, 0);

      session.markAuthenticated();
      await Future<void>.delayed(Duration.zero);

      expect(service.refreshCount, 1);
      expect(service.loadCount, 0);
      expect(viewModel.viewData, isNotNull);
      viewModel.dispose();
    });

    test('冷启动判定已登录走缓存优先取数而非强刷', () async {
      final SessionController session = SessionController();
      final _FakeGradesDataService service = _FakeGradesDataService(
        result: const UndergraduateScoreData(),
      );
      final GradesViewModel viewModel = GradesViewModel(
        dataService: service,
        sessionController: session,
      );

      session.completeBoot(AuthStatus.authenticated);
      await Future<void>.delayed(Duration.zero);

      expect(service.loadCount, 1);
      expect(service.refreshCount, 0);
      viewModel.dispose();
    });
  });
}
