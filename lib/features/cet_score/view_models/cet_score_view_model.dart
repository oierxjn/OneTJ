import 'dart:async';

import 'package:onetj/app/presentation/base_view_model.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/cet_score/application/cet_score_data_service.dart';
import 'package:onetj/features/cet_score/models/cet_score_view_data.dart';
import 'package:onetj/models/cet_score_data.dart';

class CetScoreViewModel extends BaseViewModel<UiEvent> {
  CetScoreViewModel({
    required CetScoreDataSource dataSource,
    required SessionController sessionController,
  })  : _dataSource = dataSource,
        _sessionController = sessionController {
    _sessionController.addListener(_onSessionChanged);
  }

  final CetScoreDataSource _dataSource;
  final SessionController _sessionController;
  List<CetScoreViewRecord> _records = const <CetScoreViewRecord>[];

  List<CetScoreViewRecord> get records => _records;

  bool get _isGuest => _sessionController.status == AuthStatus.guest;

  /// 登录成功后自动重载；进入游客态时清空内存中的成绩。
  void _onSessionChanged() {
    final AuthStatus status = _sessionController.status;
    if (status == AuthStatus.authenticated) {
      unawaited(load());
    } else if (status == AuthStatus.guest) {
      _records = const <CetScoreViewRecord>[];
      notifyListeners();
    }
  }

  Future<void> load() => _load(_dataSource.load, action: 'load');

  Future<void> refresh() => _load(_dataSource.refresh, action: 'refresh');

  Future<void> _load(
    Future<CetScoreData> Function() loader, {
    required String action,
  }) async {
    if (_isGuest) {
      return;
    }
    loading = true;
    notifyListeners();
    try {
      final CetScoreData data = await loader();
      _records = data.records.map(CetScoreViewRecord.fromData).toList();
    } catch (error) {
      emit(
        ShowSnackBarEvent(
          message: 'Failed to $action CET scores: ${error.toString()}',
        ),
      );
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sessionController.removeListener(_onSessionChanged);
    super.dispose();
  }
}
