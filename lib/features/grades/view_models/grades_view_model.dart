import 'dart:async';

import 'package:onetj/app/presentation/base_view_model.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/grades/application/grades_data_service.dart';
import 'package:onetj/features/grades/models/grades_view_data.dart';

class GradesViewModel extends BaseViewModel<UiEvent> {
  GradesViewModel({
    required GradesDataService dataService,
    required SessionController sessionController,
  })  : _dataService = dataService,
        _sessionController = sessionController {
    _sessionController.addListener(_onSessionChanged);
  }

  final GradesDataService _dataService;
  final SessionController _sessionController;
  GradesViewData? _viewData;
  int _selectedTermIndex = 0;

  GradesViewData? get viewData => _viewData;
  int get selectedTermIndex => _selectedTermIndex;

  bool get _isGuest => _sessionController.status == AuthStatus.guest;

  /// 登录成功后自动重载；进入游客态时清空内存中的成绩。
  void _onSessionChanged() {
    final AuthStatus status = _sessionController.status;
    if (status == AuthStatus.authenticated) {
      unawaited(load());
    } else if (status == AuthStatus.guest) {
      _viewData = null;
      _selectedTermIndex = 0;
      notifyListeners();
    }
  }

  GradesTerm? get selectedTerm {
    final GradesViewData? data = _viewData;
    if (data == null || data.terms.isEmpty) {
      return null;
    }
    final int index = _selectedTermIndex.clamp(0, data.terms.length - 1);
    return data.terms[index];
  }

  Future<void> load() async {
    if (_isGuest) {
      return;
    }
    loading = true;
    notifyListeners();
    try {
      await _dataService.warmUpCache();
    } catch (error) {
      emit(
        ShowSnackBarEvent(message: 'Failed to warm cache: $error'),
      );
    }
    try {
      final data = await _dataService.getUndergraduateScore();
      if (_isGuest) {
        return;
      }
      _viewData = GradesViewData.fromScoreData(data);
      _selectedTermIndex = 0;
    } catch (error) {
      emit(
        ShowSnackBarEvent(
            message: 'Failed to load grades: ${error.toString()}'),
      );
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_isGuest) {
      return;
    }
    loading = true;
    notifyListeners();
    try {
      final data = await _dataService.refreshUndergraduateScore();
      if (_isGuest) {
        return;
      }
      _viewData = GradesViewData.fromScoreData(data);
      _selectedTermIndex = 0;
    } catch (error) {
      emit(
        ShowSnackBarEvent(
            message: 'Failed to refresh grades: ${error.toString()}'),
      );
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void selectTerm(int index) {
    _selectedTermIndex = index;
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionController.removeListener(_onSessionChanged);
    super.dispose();
  }
}
