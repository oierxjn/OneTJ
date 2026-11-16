import 'package:onetj/app/presentation/session_aware_view_model.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/features/student_exams/application/student_exam_data_service.dart';
import 'package:onetj/features/student_exams/models/student_exam_view_data.dart';
import 'package:onetj/models/student_exam_data.dart';

class StudentExamFetchFailedEvent extends UiEvent {
  const StudentExamFetchFailedEvent({required this.showingCachedData});

  final bool showingCachedData;
}

class StudentExamViewModel extends SessionAwareViewModel<UiEvent> {
  StudentExamViewModel({
    required StudentExamDataSource dataSource,
    required super.sessionController,
  }) : _dataSource = dataSource;

  final StudentExamDataSource _dataSource;
  List<StudentExamViewRecord> _records = const <StudentExamViewRecord>[];
  String _termName = '';

  List<StudentExamViewRecord> get records => _records;
  String get termName => _termName;

  @override
  void clearPersonalData() {
    _records = const <StudentExamViewRecord>[];
    _termName = '';
  }

  @override
  Future<void> load() => _load(_dataSource.load);

  Future<void> refresh() => _load(_dataSource.refresh);

  Future<void> _load(Future<StudentExamLoadResult> Function() loader) async {
    if (isGuest) {
      return;
    }
    loading = true;
    notifyListeners();
    try {
      final StudentExamLoadResult result = await loader();
      if (isGuest) {
        return;
      }
      _updateRecords(result.data);
      if (result.latestFetchFailed) {
        emit(const StudentExamFetchFailedEvent(showingCachedData: true));
      }
    } catch (_) {
      emit(const StudentExamFetchFailedEvent(showingCachedData: false));
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _updateRecords(StudentExamData data) {
    final List<StudentExamViewRecord> records = data.records
        .map(StudentExamViewRecord.fromData)
        .toList()
      ..sort(StudentExamViewRecord.compare);
    _records = records;
    _termName = records.isEmpty ? '' : records.first.termName;
  }
}
