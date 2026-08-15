import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/features/cet_score/application/cet_score_data_service.dart';
import 'package:onetj/features/cet_score/view_models/cet_score_view_model.dart';
import 'package:onetj/models/cet_score_data.dart';

class _FakeCetScoreDataSource implements CetScoreDataSource {
  _FakeCetScoreDataSource(
      {this.loadResult, this.loadError, this.refreshResult});

  CetScoreData? loadResult;
  Object? loadError;
  CetScoreData? refreshResult;

  @override
  Future<CetScoreData> load() async {
    if (loadError != null) throw loadError!;
    return loadResult!;
  }

  @override
  Future<CetScoreData> refresh() async => refreshResult ?? loadResult!;
}

CetScoreData buildCetScoreData({String score = '520'}) {
  return CetScoreData(
    records: <CetScoreRecordData>[
      CetScoreRecordData(
        cetType: '1',
        termName: '2025年12月',
        score: score,
        ticketNumber: '123456',
        studentName: '张三',
        studentId: '12345678',
        subjectName: '英语四级',
        oralScore: 'A',
      ),
    ],
  );
}

void main() {
  test('load maps query results to presentation data', () async {
    final CetScoreViewModel viewModel = CetScoreViewModel(
      dataSource: _FakeCetScoreDataSource(loadResult: buildCetScoreData()),
    );

    await viewModel.load();

    expect(viewModel.loading, isFalse);
    expect(viewModel.records, hasLength(1));
    expect(viewModel.records.single.levelLabel, 'CET-4');
    expect(viewModel.records.single.score, '520');
    viewModel.dispose();
  });

  test('refresh replaces the displayed records', () async {
    final CetScoreViewModel viewModel = CetScoreViewModel(
      dataSource: _FakeCetScoreDataSource(
        loadResult: buildCetScoreData(score: '520'),
        refreshResult: buildCetScoreData(score: '600'),
      ),
    );

    await viewModel.load();
    await viewModel.refresh();

    expect(viewModel.loading, isFalse);
    expect(viewModel.records.single.score, '600');
    viewModel.dispose();
  });
  test('load reports an error through UiEvent', () async {
    final CetScoreViewModel viewModel = CetScoreViewModel(
      dataSource: _FakeCetScoreDataSource(loadError: StateError('offline')),
    );
    final Future<UiEvent> event = viewModel.events.first;

    await viewModel.load();

    expect(viewModel.loading, isFalse);
    expect(viewModel.records, isEmpty);
    expect(await event, isA<ShowSnackBarEvent>());
    viewModel.dispose();
  });
}
