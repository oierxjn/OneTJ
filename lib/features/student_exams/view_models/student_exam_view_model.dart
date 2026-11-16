import 'dart:async';

import 'package:onetj/app/presentation/base_view_model.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/student_exams/application/student_exam_data_service.dart';
import 'package:onetj/features/student_exams/models/student_exam_view_data.dart';
import 'package:onetj/models/student_exam_data.dart';

class StudentExamFetchFailedEvent extends UiEvent {
  const StudentExamFetchFailedEvent({required this.showingCachedData});

  final bool showingCachedData;
}

class StudentExamViewModel extends BaseViewModel<UiEvent> {
  StudentExamViewModel({
    required StudentExamDataSource dataSource,
    required SessionController sessionController,
  })  : _dataSource = dataSource,
        _sessionController = sessionController {
    _sessionController.addListener(_onSessionChanged);
  }

  final StudentExamDataSource _dataSource;
  final SessionController _sessionController;
  List<StudentExamViewRecord> _records = const <StudentExamViewRecord>[];
  String _termName = '';

  List<StudentExamViewRecord> get records => _records;
  String get termName => _termName;

  bool get _isGuest => _sessionController.status == AuthStatus.guest;

  /// 登录成功后自动重载；进入游客态时清空内存中的考试安排。
  void _onSessionChanged() {
    final AuthStatus status = _sessionController.status;
    if (status == AuthStatus.authenticated) {
      unawaited(load());
    } else if (status == AuthStatus.guest) {
      _records = const <StudentExamViewRecord>[];
      _termName = '';
      notifyListeners();
    }
  }

  Future<void> load() => _load(_dataSource.load);

  Future<void> refresh() => _load(_dataSource.refresh);

  Future<void> _load(Future<StudentExamLoadResult> Function() loader) async {
    if (_isGuest) {
      return;
    }
    loading = true;
    notifyListeners();
    try {
      final StudentExamLoadResult result = await loader();
      if (_isGuest) {
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

  @override
  void dispose() {
    _sessionController.removeListener(_onSessionChanged);
    super.dispose();
  }
}
