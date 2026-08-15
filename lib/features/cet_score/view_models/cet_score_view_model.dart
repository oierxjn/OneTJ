import 'package:onetj/app/presentation/base_view_model.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/features/cet_score/application/cet_score_data_service.dart';
import 'package:onetj/features/cet_score/models/cet_score_view_data.dart';
import 'package:onetj/models/cet_score_data.dart';

class CetScoreViewModel extends BaseViewModel<UiEvent> {
  CetScoreViewModel({required CetScoreDataSource dataSource})
      : _dataSource = dataSource;

  final CetScoreDataSource _dataSource;
  List<CetScoreViewRecord> _records = const <CetScoreViewRecord>[];

  List<CetScoreViewRecord> get records => _records;

  Future<void> load() => _load(_dataSource.load, action: 'load');

  Future<void> refresh() => _load(_dataSource.refresh, action: 'refresh');

  Future<void> _load(
    Future<CetScoreData> Function() loader, {
    required String action,
  }) async {
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
}
