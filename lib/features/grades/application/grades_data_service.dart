import 'package:onetj/services/tongji.dart';
import 'package:onetj/models/undergraduate_score_data.dart';
import 'package:onetj/repo/undergraduate_score_repository.dart';

class GradesDataService {
  GradesDataService({
    required TongjiApi api,
    required UndergraduateScoreRepository repository,
  })  : _api = api,
        _repository = repository;

  final TongjiApi _api;
  final UndergraduateScoreRepository _repository;

  Future<UndergraduateScoreData> fetchUndergraduateScore({int? calendarId}) {
    return _api.fetchUndergraduateScore(calendarId: calendarId);
  }

  Future<UndergraduateScoreData> getUndergraduateScore() async {
    return _repository.getOrFetch(
      now: DateTime.now(),
      fetcher: () => fetchUndergraduateScore(calendarId: -1),
      ttl: const Duration(hours: 0),
    );
  }

  Future<void> warmUpCache() async {
    await _repository.warmUp();
  }

  /// 清空成绩缓存，供登出编排调用，避免游客看到上一账号的数据。
  Future<void> clearCachedData() => _repository.clearCache();

  Future<UndergraduateScoreData> refreshUndergraduateScore() async {
    return _repository.refresh(
      now: DateTime.now(),
      fetcher: () => fetchUndergraduateScore(calendarId: -1),
    );
  }
}
