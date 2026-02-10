import 'package:onetj/services/tongji.dart';
import 'package:onetj/repo/undergraduate_score_repository.dart';

class GradesModel {
  GradesModel({TongjiApi? api}) : _api = api ?? TongjiApi();

  final TongjiApi _api;

  Future<UndergraduateScoreData> fetchUndergraduateScore() {
    return _api.fetchUndergraduateScore();
  }

  Future<UndergraduateScoreData> getUndergraduateScore() async {
    final UndergraduateScoreRepository repo =
        UndergraduateScoreRepository.getInstance();
    return repo.getOrFetch(
      now: DateTime.now(),
      fetcher: fetchUndergraduateScore,
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
      fetcher: fetchUndergraduateScore,
    );
  }
}
