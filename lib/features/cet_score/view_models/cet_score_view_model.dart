import 'package:onetj/app/presentation/session_aware_view_model.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/features/cet_score/application/cet_score_data_service.dart';
import 'package:onetj/features/cet_score/models/cet_score_view_data.dart';
import 'package:onetj/models/cet_score_data.dart';

class CetScoreViewModel extends SessionAwareViewModel<UiEvent> {
  CetScoreViewModel({
    required CetScoreDataSource dataSource,
    required super.sessionController,
  }) : _dataSource = dataSource;

  final CetScoreDataSource _dataSource;
  List<CetScoreViewRecord> _records = const <CetScoreViewRecord>[];

  List<CetScoreViewRecord> get records => _records;

  @override
  void clearPersonalData() {
    _records = const <CetScoreViewRecord>[];
  }

  @override
  Future<void> load() => _load(_dataSource.load, action: 'load');

  Future<void> refresh() => _load(_dataSource.refresh, action: 'refresh');

  Future<void> _load(
    Future<CetScoreData> Function() loader, {
    required String action,
  }) async {
    if (isGuest) {
      return;
    }
    loading = true;
    notifyListeners();
    try {
      final CetScoreData data = await loader();
      if (isGuest) {
        return;
      }
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
}
