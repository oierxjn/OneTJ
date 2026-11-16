import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/grades/application/grades_data_service.dart';
import 'package:onetj/features/grades/view_models/grades_view_model.dart';
import 'package:onetj/models/undergraduate_score_data.dart';

/// 可注入结果与计数的成绩服务桩。
class _FakeGradesDataService implements GradesDataService {
  _FakeGradesDataService({this.result});

  UndergraduateScoreData? result;
  int loadCount = 0;

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
    loadCount += 1;
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

    test('重新登录成功后自动重载', () async {
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

      session.markAuthenticated();
      await Future<void>.delayed(Duration.zero);

      expect(service.loadCount, 1);
      expect(viewModel.viewData, isNotNull);
      viewModel.dispose();
    });
  });
}
