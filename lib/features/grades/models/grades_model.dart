import 'package:onetj/services/tongji.dart';
import 'package:onetj/repo/undergraduate_score_repository.dart';

class GradesModel {
  GradesModel({TongjiApi? api}) : _api = api ?? TongjiApi();

  final TongjiApi _api;

  Future<UndergraduateScoreData> fetchUndergraduateScore({int? calendarId}) {
    return _api.fetchUndergraduateScore(calendarId: calendarId);
  }

  Future<UndergraduateScoreData> getUndergraduateScore() async {
    final UndergraduateScoreRepository repo =
        UndergraduateScoreRepository.getInstance();
    return repo.getOrFetch(
      now: DateTime.now(),
      fetcher: () => fetchUndergraduateScore(calendarId: -1),
      ttl: const Duration(hours: 0),
    );
  }

  Future<void> warmUpCache() async {
    final UndergraduateScoreRepository repo =
        UndergraduateScoreRepository.getInstance();
    await repo.warmUp();
  }

  Future<UndergraduateScoreData> refreshUndergraduateScore() async {
    final UndergraduateScoreRepository repo =
        UndergraduateScoreRepository.getInstance();
    return repo.fetchAndSave(
      now: DateTime.now(),
      fetcher: () => fetchUndergraduateScore(calendarId: -1),
    );
  }
}
