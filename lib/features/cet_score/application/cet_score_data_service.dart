import 'package:onetj/models/cet_score_data.dart';
import 'package:onetj/repo/cet_score_repository.dart';
import 'package:onetj/services/tongji.dart';

abstract interface class CetScoreDataSource {
  Future<CetScoreData> load();
  Future<CetScoreData> refresh();
}

class CetScoreDataService implements CetScoreDataSource {
  CetScoreDataService({
    required TongjiApi api,
    required CetScoreRepository repository,
    DateTime Function()? clock,
  })  : _api = api,
        _repository = repository,
        _clock = clock ?? DateTime.now;

  static const Duration _cacheTtl = Duration(days: 7);

  final TongjiApi _api;
  final CetScoreRepository _repository;
  final DateTime Function() _clock;

  @override
  Future<CetScoreData> load() async {
    await _repository.warmUp();
    final CetScoreData? cached = await _repository.getCached();
    try {
      return await _repository.getOrFetch(
        now: _clock(),
        ttl: _cacheTtl,
        fetcher: _api.fetchCetScores,
      );
    } catch (_) {
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  Future<void> clearCachedData() => _repository.clearCache();

  @override
  Future<CetScoreData> refresh() {
    return _repository.refresh(
      now: _clock(),
      fetcher: _api.fetchCetScores,
    );
  }
}
