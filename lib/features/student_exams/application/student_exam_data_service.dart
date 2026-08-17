import 'package:onetj/models/student_exam_data.dart';
import 'package:onetj/repo/student_exam_repository.dart';
import 'package:onetj/services/tongji.dart';

class StudentExamLoadResult {
  const StudentExamLoadResult({
    required this.data,
    this.latestFetchFailed = false,
  });

  final StudentExamData data;
  final bool latestFetchFailed;
}

abstract interface class StudentExamDataSource {
  Future<StudentExamLoadResult> load();
  Future<StudentExamLoadResult> refresh();
}

class StudentExamDataService implements StudentExamDataSource {
  StudentExamDataService({
    required TongjiApi api,
    required StudentExamRepository repository,
    DateTime Function()? clock,
  })  : _api = api,
        _repository = repository,
        _clock = clock ?? DateTime.now;

  static const Duration _cacheTtl = Duration(hours: 6);

  final TongjiApi _api;
  final StudentExamRepository _repository;
  final DateTime Function() _clock;

  @override
  Future<StudentExamLoadResult> load() async {
    await _repository.warmUp();
    final StudentExamData? cached = await _repository.getCached();
    try {
      return StudentExamLoadResult(
        data: await _repository.getOrFetch(
          now: _clock(),
          ttl: _cacheTtl,
          fetcher: _api.fetchStudentExams,
        ),
      );
    } catch (_) {
      if (cached != null) {
        return StudentExamLoadResult(data: cached, latestFetchFailed: true);
      }
      rethrow;
    }
  }

  @override
  Future<StudentExamLoadResult> refresh() async {
    return StudentExamLoadResult(
      data: await _repository.refresh(
        now: _clock(),
        fetcher: _api.fetchStudentExams,
      ),
    );
  }

  Future<void> clearCachedData() => _repository.clearCache();
}
